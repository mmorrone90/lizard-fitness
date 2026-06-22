// Seed Firestore without a service-account key. Stubs firebase-admin, captures
// every batch.set() from ../seed_data.js, and writes via the Firestore REST API
// using the Firebase CLI's OAuth token. Run after `firebase login`:
//   node scripts/seed_rest.js            (uses lizard-fitness-app)
//   FIREBASE_PROJECT_ID=other node scripts/seed_rest.js
const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');

const PROJECT = process.env.FIREBASE_PROJECT_ID || 'lizard-fitness-app';
const cfg = JSON.parse(fs.readFileSync(
  path.join(os.homedir(), '.config/configstore/firebase-tools.json'), 'utf8'));

// Mint a fresh cloud-platform token from the CLI's refresh token; the stored
// access_token expires and Firestore rejects it (ACCESS_TOKEN_TYPE_UNSUPPORTED).
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
      res.on('end', () => { const j = JSON.parse(out); j.access_token ? resolve(j.access_token) : reject(new Error(out)); });
    });
    r.on('error', reject); r.write(body); r.end();
  });
}
let TOKEN = '';

const TS = { __serverTimestamp: true };
function randId(n = 20) {
  const c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let s = ''; for (let i = 0; i < n; i++) s += c[Math.floor(Math.random() * c.length)];
  return s;
}

// JS value -> Firestore REST Value
function toValue(v) {
  if (v === TS) return { timestampValue: new Date().toISOString() };
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number')
    return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(toValue) } };
  if (typeof v === 'object') return { mapValue: { fields: toFields(v) } };
  return { stringValue: String(v) };
}
function toFields(obj) {
  const f = {};
  for (const k of Object.keys(obj)) f[k] = toValue(obj[k]);
  return f;
}

function commitWrites(writes) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ writes });
    const req = https.request({
      hostname: 'firestore.googleapis.com',
      path: `/v1/projects/${PROJECT}/databases/(default)/documents:commit`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    }, (res) => {
      let data = ''; res.on('data', (d) => data += d);
      res.on('end', () => res.statusCode < 300
        ? resolve(data)
        : reject(new Error(`HTTP ${res.statusCode}: ${data}`)));
    });
    req.on('error', reject);
    req.write(body); req.end();
  });
}

// Fake admin
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
            const writes = ops.map(({ ref, data }) => ({
              update: {
                name: `projects/${PROJECT}/databases/(default)/documents/${ref._col}/${ref._id}`,
                fields: toFields(data),
              },
            }));
            // Firestore commit caps at 500 writes; our batches are small.
            await commitWrites(writes);
          },
        };
      },
      collection(name) {
        return { doc(id) { return { _col: name, _id: id || randId() }; } };
      },
    };
  },
};
fakeAdmin.firestore.FieldValue = { serverTimestamp: () => TS };

const Module = require('module');
const origLoad = Module._load;
Module._load = function (request, parent, isMain) {
  if (request === 'firebase-admin') return fakeAdmin;
  return origLoad.apply(this, arguments);
};

freshToken().then((t) => {
  TOKEN = t;
  require(path.join(__dirname, '..', 'seed_data.js'));
}).catch((e) => { console.error('Token refresh failed:', e.message); process.exit(1); });
