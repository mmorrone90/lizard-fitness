// Set a videoUrl on every exercise via the Firestore REST :commit endpoint
// using the Firebase CLI token (no service account). Reuses ../seed_data.js to
// enumerate exercises, but writes ONLY the videoUrl field (updateMask).
// Replace PLACEHOLDERS / VIDEO_BY_NAME with real demos, then re-run:
//   node scripts/set_exercise_videos.js
const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');

const PROJECT = process.env.FIREBASE_PROJECT_ID || 'lizard-fitness-app';
const cfg = JSON.parse(fs.readFileSync(
  path.join(os.homedir(), '.config/configstore/firebase-tools.json'), 'utf8'));

// Mint a fresh cloud-platform access token from the Firebase CLI's stored
// refresh token (the stored access_token expires and Firestore rejects it).
function freshToken() {
  return new Promise((resolve, reject) => {
    const body = new URLSearchParams({
      client_id: '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
      client_secret: 'j9iVZfS8kkCEFUPaAeJV0sAi',
      grant_type: 'refresh_token',
      refresh_token: cfg.tokens.refresh_token,
    }).toString();
    const r = https.request({
      hostname: 'oauth2.googleapis.com', path: '/token', method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': Buffer.byteLength(body) },
    }, (res) => {
      let out = ''; res.on('data', (d) => out += d);
      res.on('end', () => {
        const j = JSON.parse(out);
        j.access_token ? resolve(j.access_token) : reject(new Error(out));
      });
    });
    r.on('error', reject); r.write(body); r.end();
  });
}
let TOKEN = '';

// Real per-exercise demo URLs keyed by exact exercise name.
const VIDEO_BY_NAME = {};
// Placeholder pool so the player works on each exercise until real demos exist.
// Official Flutter video_player test assets — reliably playable on iOS/Android.
const PLACEHOLDERS = [
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
];

function commit(writes) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ writes });
    const r = https.request({
      hostname: 'firestore.googleapis.com',
      path: `/v1/projects/${PROJECT}/databases/(default)/documents:commit`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    }, (res) => {
      let out = ''; res.on('data', (d) => out += d);
      res.on('end', () => res.statusCode < 300 ? resolve(out) : reject(new Error(`HTTP ${res.statusCode}: ${out}`)));
    });
    r.on('error', reject);
    r.write(body); r.end();
  });
}

let idx = 0;
const fakeAdmin = {
  initializeApp() {},
  credential: { applicationDefault: () => ({}) },
  firestore() {
    return {
      batch() {
        const ops = [];
        return {
          set(ref, data) { ops.push({ ref, data }); },
          async commit() {
            const ex = ops.filter((o) => o.ref._col === 'exercises');
            if (ex.length === 0) return; // skip templates/challenges
            const writes = ex.map(({ ref, data }) => {
              const url = VIDEO_BY_NAME[data.name] || PLACEHOLDERS[idx++ % PLACEHOLDERS.length];
              return {
                update: {
                  name: `projects/${PROJECT}/databases/(default)/documents/exercises/${ref._id}`,
                  fields: { videoUrl: { stringValue: url } },
                },
                updateMask: { fieldPaths: ['videoUrl'] },
              };
            });
            await commit(writes);
            console.log(`✓ ${writes.length} exercises got a videoUrl`);
          },
        };
      },
      collection(name) { return { doc(id) { return { _col: name, _id: id }; } }; },
    };
  },
};
fakeAdmin.firestore.FieldValue = { serverTimestamp: () => null };

const Module = require('module');
const origLoad = Module._load;
Module._load = function (request) {
  if (request === 'firebase-admin') return fakeAdmin;
  return origLoad.apply(this, arguments);
};

freshToken().then((t) => {
  TOKEN = t;
  require(path.join(__dirname, '..', 'seed_data.js'));
}).catch((e) => { console.error('Token refresh failed:', e.message); process.exit(1); });
