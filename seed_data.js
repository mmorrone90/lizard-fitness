// Seed script — run with:
// node firebase/seed_data.js
// Requires: npm install firebase-admin
// Set GOOGLE_APPLICATION_CREDENTIALS env var to your service account JSON

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: process.env.FIREBASE_PROJECT_ID || 'YOUR_PROJECT_ID',
});

const db = admin.firestore();
const now = admin.firestore.FieldValue.serverTimestamp();

// ── Exercises ──────────────────────────────────────────────────────────────────

const exercises = [
  {
    name: 'Bench Press',
    primaryMuscle: 'chest',
    secondaryMuscles: ['shoulders', 'triceps'],
    equipment: ['barbell', 'bench'],
    difficulty: 'intermediate',
    instructions: [
      'Lie flat on the bench with eyes under the bar.',
      'Grip the bar slightly wider than shoulder-width.',
      'Unrack and lower to mid-chest with control.',
      'Press explosively back to start.',
      'Keep your feet flat on the floor and back slightly arched.',
    ],
    formTips: [
      'Retract and depress your shoulder blades before unracking.',
      'Keep wrists straight — don\'t let them bend back.',
      'Drive through your legs for stability.',
    ],
    safetyTips: [
      'Always use a spotter for heavy sets.',
      'Never bounce the bar off your chest.',
      'Use collars to secure the plates.',
    ],
    commonMistakes: [
      'Flaring elbows to 90 degrees — keep them at 45-75 degrees.',
      'Bouncing the bar off the chest.',
      'Losing shoulder blade retraction mid-set.',
    ],
    videoUrl: null,
  },
  {
    name: 'Squat',
    primaryMuscle: 'quads',
    secondaryMuscles: ['glutes', 'hamstrings', 'core'],
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Set up with bar on upper traps, feet shoulder-width apart.',
      'Brace your core and take a big breath.',
      'Push your knees out and sit back and down.',
      'Descend until hips are at or below knee level.',
      'Drive through your heels to return to start.',
    ],
    formTips: [
      'Keep your chest up throughout the movement.',
      'Push your knees out in line with your toes.',
      'Brace your core like you\'re about to be punched.',
    ],
    safetyTips: [
      'Start light and build up gradually.',
      'Use a squat rack with safety bars set appropriately.',
      'Don\'t hyperextend your lower back at the top.',
    ],
    commonMistakes: [
      'Knees caving inward (valgus collapse).',
      'Heels rising off the floor.',
      'Forward lean excessive — usually a mobility issue.',
    ],
    videoUrl: null,
  },
  {
    name: 'Deadlift',
    primaryMuscle: 'back',
    secondaryMuscles: ['hamstrings', 'glutes', 'core', 'forearms'],
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Stand with feet hip-width, bar over mid-foot.',
      'Hinge at hips, grip bar just outside legs.',
      'Flatten your back, chest up, lats engaged.',
      'Push the floor away — drive hips forward at the top.',
      'Lower with control by hinging at hips first.',
    ],
    formTips: [
      'Think "push the floor away" not "pull the bar up".',
      'Keep the bar close to your body throughout.',
      'Lock out hips and knees simultaneously at the top.',
    ],
    safetyTips: [
      'Never round your lower back under load.',
      'Start with lighter weights to master the hip hinge.',
      'Use a belt for heavier loads once technique is solid.',
    ],
    commonMistakes: [
      'Rounding the lower back.',
      'Bar drifting away from the body.',
      'Jerking the weight off the floor.',
    ],
    videoUrl: null,
  },
  {
    name: 'Shoulder Press',
    primaryMuscle: 'shoulders',
    secondaryMuscles: ['triceps', 'core'],
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Stand or sit with bar at collarbone level.',
      'Grip slightly wider than shoulder-width.',
      'Press bar overhead in a straight line.',
      'Lock out at the top without hyperextending your lower back.',
      'Lower under control to starting position.',
    ],
    formTips: [
      'Tuck your chin slightly as the bar passes your face.',
      'Squeeze your glutes to protect your lower back.',
      'Don\'t use your legs to help (that\'s a push press).',
    ],
    safetyTips: [
      'Warm up rotator cuffs before heavy pressing.',
      'Don\'t press behind the neck — high injury risk.',
    ],
    commonMistakes: [
      'Excessive lower back arch.',
      'Pressing forward instead of straight up.',
      'Not locking out at the top.',
    ],
    videoUrl: null,
  },
  {
    name: 'Lat Pulldown',
    primaryMuscle: 'back',
    secondaryMuscles: ['biceps', 'shoulders'],
    equipment: ['cable', 'machine'],
    difficulty: 'beginner',
    instructions: [
      'Sit at lat pulldown machine, thighs secured.',
      'Grip bar wider than shoulder-width, palms facing away.',
      'Lean back slightly, pull bar to upper chest.',
      'Squeeze lats at bottom of movement.',
      'Control the bar back up to full arm extension.',
    ],
    formTips: [
      'Initiate the pull with your elbows, not your hands.',
      'Think about pulling your elbows into your back pockets.',
      'Keep your chest up throughout.',
    ],
    safetyTips: [
      'Don\'t pull behind the neck — puts excessive stress on the cervical spine.',
      'Don\'t lean back excessively — this becomes a row.',
    ],
    commonMistakes: [
      'Using momentum to swing the weight down.',
      'Not achieving full range of motion at the top.',
      'Pulling with biceps instead of lats.',
    ],
    videoUrl: null,
  },
  {
    name: 'Barbell Row',
    primaryMuscle: 'back',
    secondaryMuscles: ['biceps', 'shoulders', 'core'],
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Stand with feet hip-width, hinge forward to ~45 degrees.',
      'Grip bar slightly wider than shoulder-width.',
      'Pull bar to lower chest/upper stomach.',
      'Squeeze shoulder blades together at top.',
      'Lower under control.',
    ],
    formTips: [
      'Keep your back flat — don\'t round it.',
      'Lead with your elbows, keeping them close to your body.',
      'Engage lats before you pull.',
    ],
    safetyTips: [
      'Never row with a rounded lower back.',
      'Start with lighter weight to master the hinge position.',
    ],
    commonMistakes: [
      'Rowing with a rounded back.',
      'Using momentum to heave the weight up.',
      'Pulling to the wrong part of the body.',
    ],
    videoUrl: null,
  },
  {
    name: 'Leg Press',
    primaryMuscle: 'quads',
    secondaryMuscles: ['glutes', 'hamstrings'],
    equipment: ['machine'],
    difficulty: 'beginner',
    instructions: [
      'Sit in machine with back flat against pad.',
      'Place feet shoulder-width on platform.',
      'Release safety handles and lower weight slowly.',
      'Don\'t let knees collapse — keep them in line with toes.',
      'Press back up without locking out knees hard.',
    ],
    formTips: [
      'Higher foot placement emphasises glutes and hamstrings.',
      'Lower foot placement emphasises quads.',
      'Don\'t allow your lower back to peel off the pad.',
    ],
    safetyTips: [
      'Never lock out your knees aggressively — keep a slight bend.',
      'Don\'t allow your lower back to round at the bottom.',
    ],
    commonMistakes: [
      'Lowering weight too far causing lower back lift.',
      'Knees caving in.',
      'Using too much weight with poor range of motion.',
    ],
    videoUrl: null,
  },
  {
    name: 'Romanian Deadlift',
    primaryMuscle: 'hamstrings',
    secondaryMuscles: ['glutes', 'back'],
    equipment: ['barbell'],
    difficulty: 'intermediate',
    instructions: [
      'Stand holding bar at hip level, feet hip-width.',
      'Push hips back and lower bar along legs.',
      'Feel a stretch in hamstrings — go as far as flexibility allows.',
      'Drive hips forward to return to start.',
      'Keep the bar close to your legs throughout.',
    ],
    formTips: [
      'Think about "closing a car door with your butt".',
      'Maintain a neutral spine — don\'t round lower back.',
      'Bar should drag down your shins to your ankles.',
    ],
    safetyTips: [
      'Never round your lower back under load.',
      'Go only as low as your hamstring flexibility allows.',
    ],
    commonMistakes: [
      'Bending knees too much — this becomes a deadlift.',
      'Rounding the lower back.',
      'Bar drifting forward away from the body.',
    ],
    videoUrl: null,
  },
  {
    name: 'Biceps Curl',
    primaryMuscle: 'biceps',
    secondaryMuscles: ['forearms'],
    equipment: ['dumbbell', 'barbell'],
    difficulty: 'beginner',
    instructions: [
      'Stand or sit with weight in hand, palms facing forward.',
      'Keep elbows tucked at your sides.',
      'Curl weight toward shoulders without swinging.',
      'Squeeze at the top of the movement.',
      'Lower under control.',
    ],
    formTips: [
      'Keep upper arms stationary throughout.',
      'Supinate (rotate) your wrist at the top for full contraction.',
      'Full range of motion matters more than heavy weight.',
    ],
    safetyTips: [
      'Don\'t use momentum — no swinging.',
      'Don\'t hyperextend elbows at the bottom.',
    ],
    commonMistakes: [
      'Swinging the torso to heave the weight up.',
      'Not reaching full flexion at the top.',
      'Elbows drifting forward — should stay at sides.',
    ],
    videoUrl: null,
  },
  {
    name: 'Triceps Pushdown',
    primaryMuscle: 'triceps',
    secondaryMuscles: [],
    equipment: ['cable'],
    difficulty: 'beginner',
    instructions: [
      'Stand at cable machine, grip rope or bar attachment.',
      'Elbows tucked at sides, forearms parallel to floor.',
      'Push attachment down until arms fully extend.',
      'Squeeze triceps at full extension.',
      'Return under control to start.',
    ],
    formTips: [
      'Keep elbows locked at your sides throughout.',
      'The movement should only happen at the elbow joint.',
      'Lean slightly forward from the hips.',
    ],
    safetyTips: [
      'Don\'t use excessive weight that causes elbows to flare.',
      'Keep wrists straight throughout.',
    ],
    commonMistakes: [
      'Elbows flaring out to the sides.',
      'Using momentum by bending forward at the hips.',
      'Not achieving full extension.',
    ],
    videoUrl: null,
  },
  {
    name: 'Plank',
    primaryMuscle: 'core',
    secondaryMuscles: ['shoulders', 'glutes'],
    equipment: ['bodyweight'],
    difficulty: 'beginner',
    instructions: [
      'Start in push-up position, lower to forearms.',
      'Body should be straight from head to heels.',
      'Engage core, glutes, and quads.',
      'Hold for target duration, breathing normally.',
      'Don\'t let hips sag or pike.',
    ],
    formTips: [
      'Squeeze everything — it\'s a full body exercise.',
      'Press through your forearms to create tension through your back.',
      'Keep your neck neutral — don\'t look up or down.',
    ],
    safetyTips: [
      'Don\'t hold your breath.',
      'Stop if you feel lower back pain — your hips may be sagging.',
    ],
    commonMistakes: [
      'Hips sagging toward the floor.',
      'Hips piking too high.',
      'Holding breath.',
    ],
    videoUrl: null,
  },
  {
    name: 'Hip Thrust',
    primaryMuscle: 'glutes',
    secondaryMuscles: ['hamstrings', 'core'],
    equipment: ['barbell', 'bench'],
    difficulty: 'beginner',
    instructions: [
      'Sit on floor with upper back against bench, bar over hips.',
      'Feet flat on floor, hip-width apart.',
      'Drive hips up until body is parallel to floor.',
      'Squeeze glutes hard at the top.',
      'Lower hips to floor under control.',
    ],
    formTips: [
      'Use a pad on the bar for comfort.',
      'Drive through your heels, not your toes.',
      'Keep chin tucked to maintain neutral spine.',
    ],
    safetyTips: [
      'Ensure the bench is secure before starting.',
      'Don\'t hyperextend your lower back at the top.',
    ],
    commonMistakes: [
      'Not achieving full hip extension at the top.',
      'Feet too far or too close — experiment with placement.',
      'Ribs flaring up instead of hips extending.',
    ],
    videoUrl: null,
  },
  {
    name: 'Lunges',
    primaryMuscle: 'quads',
    secondaryMuscles: ['glutes', 'hamstrings'],
    equipment: ['bodyweight', 'dumbbell'],
    difficulty: 'beginner',
    instructions: [
      'Stand tall, step forward with one foot.',
      'Lower back knee toward the floor.',
      'Front knee should be directly above front ankle.',
      'Push through front heel to return to start.',
      'Alternate legs for each rep.',
    ],
    formTips: [
      'Keep your torso upright throughout.',
      'Take a long enough step — short steps shift load to quads only.',
      'Control the descent — don\'t crash your knee.',
    ],
    safetyTips: [
      'Don\'t let front knee cave inward.',
      'Don\'t let the back knee slam the floor.',
    ],
    commonMistakes: [
      'Front knee travelling past toes (usually due to step being too short).',
      'Leaning forward excessively.',
      'Losing balance — use dumbbells carefully until stable.',
    ],
    videoUrl: null,
  },
  {
    name: 'Pull-Up',
    primaryMuscle: 'back',
    secondaryMuscles: ['biceps', 'shoulders', 'core'],
    equipment: ['pullupBar', 'bodyweight'],
    difficulty: 'intermediate',
    instructions: [
      'Hang from bar with overhand grip, wider than shoulders.',
      'Engage lats and core before pulling.',
      'Pull chest toward bar, elbows driving down and back.',
      'Chin clears the bar at the top.',
      'Lower under control to dead hang.',
    ],
    formTips: [
      'Initiate with lat engagement, not arm strength.',
      'Aim to get chest to bar, not just chin.',
      'Dead hang at the bottom provides full range of motion.',
    ],
    safetyTips: [
      'If you can\'t do a full pull-up, use assisted machine or bands.',
      'Don\'t kip unless you\'re trained in that movement.',
    ],
    commonMistakes: [
      'Using momentum and kipping.',
      'Not reaching full extension at the bottom.',
      'Pulling with arms instead of lats.',
    ],
    videoUrl: null,
  },
  {
    name: 'Push-Up',
    primaryMuscle: 'chest',
    secondaryMuscles: ['triceps', 'shoulders', 'core'],
    equipment: ['bodyweight'],
    difficulty: 'beginner',
    instructions: [
      'Start in high plank with hands slightly wider than shoulders.',
      'Body in a straight line from head to heels.',
      'Lower chest to just above the floor.',
      'Press back up explosively.',
      'Keep core engaged throughout.',
    ],
    formTips: [
      'Elbows at 45 degrees to body — not straight out.',
      'Look at the floor 6 inches in front — keeps neck neutral.',
      'Squeeze chest at the top of each rep.',
    ],
    safetyTips: [
      'Don\'t let hips sag — maintain a rigid plank.',
      'If wrists hurt, try doing push-ups on fists.',
    ],
    commonMistakes: [
      'Flaring elbows to 90 degrees — high shoulder impingement risk.',
      'Not achieving full range of motion.',
      'Hips sagging.',
    ],
    videoUrl: null,
  },
];

// ── Workout Templates ──────────────────────────────────────────────────────────

const templates = [
  {
    title: 'Beginner Full Body A',
    description: 'A simple full body workout for beginners. Focus on compound movements and learning proper form.',
    planType: 'Beginner Full Body',
    goal: 'generalFitness',
    difficulty: 'beginner',
    targetMuscles: ['fullBody'],
    equipment: ['barbell', 'dumbbell', 'bench'],
    estimatedDuration: 45,
    recommendedFor: ['beginner', '2-3 days/week'],
    exercises: [
      { exerciseId: 'squat', exerciseName: 'Squat', sets: 3, reps: 8, weight: 40, restSeconds: 120 },
      { exerciseId: 'bench_press', exerciseName: 'Bench Press', sets: 3, reps: 8, weight: 30, restSeconds: 90 },
      { exerciseId: 'barbell_row', exerciseName: 'Barbell Row', sets: 3, reps: 8, weight: 30, restSeconds: 90 },
      { exerciseId: 'shoulder_press', exerciseName: 'Shoulder Press', sets: 3, reps: 8, weight: 20, restSeconds: 90 },
      { exerciseId: 'plank', exerciseName: 'Plank', sets: 3, reps: 30, weight: null, restSeconds: 60, notes: 'Hold for 30 seconds' },
    ],
  },
  {
    title: 'Beginner Full Body B',
    description: 'Alternate with Full Body A. Same principles, different exercise variations.',
    planType: 'Beginner Full Body',
    goal: 'generalFitness',
    difficulty: 'beginner',
    targetMuscles: ['fullBody'],
    equipment: ['barbell', 'dumbbell', 'bench'],
    estimatedDuration: 45,
    recommendedFor: ['beginner', '2-3 days/week'],
    exercises: [
      { exerciseId: 'deadlift', exerciseName: 'Deadlift', sets: 3, reps: 6, weight: 50, restSeconds: 120 },
      { exerciseId: 'pushup', exerciseName: 'Push-Up', sets: 3, reps: 10, weight: null, restSeconds: 60 },
      { exerciseId: 'lat_pulldown', exerciseName: 'Lat Pulldown', sets: 3, reps: 10, weight: 40, restSeconds: 90 },
      { exerciseId: 'lunge', exerciseName: 'Lunges', sets: 3, reps: 10, weight: null, restSeconds: 60 },
      { exerciseId: 'biceps_curl', exerciseName: 'Biceps Curl', sets: 2, reps: 12, weight: 10, restSeconds: 60 },
    ],
  },
  {
    title: 'Upper Body — Push',
    description: 'Push day: chest, shoulders, triceps. Part of Push/Pull/Legs split.',
    planType: 'Push/Pull/Legs',
    goal: 'muscleGain',
    difficulty: 'intermediate',
    targetMuscles: ['chest', 'shoulders', 'triceps'],
    equipment: ['barbell', 'dumbbell', 'cable', 'bench'],
    estimatedDuration: 55,
    recommendedFor: ['intermediate', 'advanced', '5-6 days/week'],
    exercises: [
      { exerciseId: 'bench_press', exerciseName: 'Bench Press', sets: 4, reps: 8, weight: 70, restSeconds: 120 },
      { exerciseId: 'shoulder_press', exerciseName: 'Shoulder Press', sets: 3, reps: 10, weight: 50, restSeconds: 90 },
      { exerciseId: 'triceps_pushdown', exerciseName: 'Triceps Pushdown', sets: 3, reps: 12, weight: 30, restSeconds: 60 },
      { exerciseId: 'pushup', exerciseName: 'Push-Up', sets: 3, reps: 15, weight: null, restSeconds: 60 },
    ],
  },
  {
    title: 'Upper Body — Pull',
    description: 'Pull day: back, biceps. Part of Push/Pull/Legs split.',
    planType: 'Push/Pull/Legs',
    goal: 'muscleGain',
    difficulty: 'intermediate',
    targetMuscles: ['back', 'biceps'],
    equipment: ['barbell', 'cable', 'pullupBar'],
    estimatedDuration: 55,
    recommendedFor: ['intermediate', 'advanced', '5-6 days/week'],
    exercises: [
      { exerciseId: 'pullup', exerciseName: 'Pull-Up', sets: 4, reps: 6, weight: null, restSeconds: 120 },
      { exerciseId: 'barbell_row', exerciseName: 'Barbell Row', sets: 4, reps: 8, weight: 60, restSeconds: 90 },
      { exerciseId: 'lat_pulldown', exerciseName: 'Lat Pulldown', sets: 3, reps: 10, weight: 50, restSeconds: 90 },
      { exerciseId: 'biceps_curl', exerciseName: 'Biceps Curl', sets: 3, reps: 12, weight: 15, restSeconds: 60 },
    ],
  },
  {
    title: 'Leg Day',
    description: 'Leg day: quads, hamstrings, glutes. Part of Push/Pull/Legs or Upper/Lower split.',
    planType: 'Push/Pull/Legs',
    goal: 'muscleGain',
    difficulty: 'intermediate',
    targetMuscles: ['quads', 'hamstrings', 'glutes'],
    equipment: ['barbell', 'machine'],
    estimatedDuration: 60,
    recommendedFor: ['intermediate', 'advanced'],
    exercises: [
      { exerciseId: 'squat', exerciseName: 'Squat', sets: 4, reps: 8, weight: 80, restSeconds: 180 },
      { exerciseId: 'romanian_deadlift', exerciseName: 'Romanian Deadlift', sets: 3, reps: 10, weight: 60, restSeconds: 120 },
      { exerciseId: 'leg_press', exerciseName: 'Leg Press', sets: 3, reps: 12, weight: 120, restSeconds: 90 },
      { exerciseId: 'hip_thrust', exerciseName: 'Hip Thrust', sets: 3, reps: 12, weight: 60, restSeconds: 90 },
      { exerciseId: 'lunge', exerciseName: 'Lunges', sets: 3, reps: 10, weight: 20, restSeconds: 60 },
    ],
  },
  {
    title: 'Strength — 5x5',
    description: 'Classic 5x5 strength programme. Focus on adding weight each session on the big lifts.',
    planType: 'Strength',
    goal: 'strength',
    difficulty: 'intermediate',
    targetMuscles: ['fullBody'],
    equipment: ['barbell'],
    estimatedDuration: 50,
    recommendedFor: ['intermediate', '3 days/week'],
    exercises: [
      { exerciseId: 'squat', exerciseName: 'Squat', sets: 5, reps: 5, weight: 80, restSeconds: 240 },
      { exerciseId: 'bench_press', exerciseName: 'Bench Press', sets: 5, reps: 5, weight: 60, restSeconds: 180 },
      { exerciseId: 'barbell_row', exerciseName: 'Barbell Row', sets: 5, reps: 5, weight: 60, restSeconds: 180 },
    ],
  },
  {
    title: 'HIIT Conditioning',
    description: 'High intensity circuit for fat loss and conditioning. Keep rest short, intensity high.',
    planType: 'HIIT',
    goal: 'hiit',
    difficulty: 'intermediate',
    targetMuscles: ['fullBody', 'cardio'],
    equipment: ['bodyweight'],
    estimatedDuration: 30,
    recommendedFor: ['intermediate', 'advanced', 'fat loss'],
    exercises: [
      { exerciseId: 'pushup', exerciseName: 'Push-Up', sets: 4, reps: 15, weight: null, restSeconds: 30 },
      { exerciseId: 'lunge', exerciseName: 'Lunges', sets: 4, reps: 20, weight: null, restSeconds: 30 },
      { exerciseId: 'plank', exerciseName: 'Plank', sets: 4, reps: 45, weight: null, restSeconds: 30, notes: 'Hold 45s' },
      { exerciseId: 'hip_thrust', exerciseName: 'Hip Thrust', sets: 4, reps: 20, weight: null, restSeconds: 30 },
    ],
  },
  {
    title: 'Upper/Lower — Upper',
    description: 'Upper body day in a 4-day upper/lower split.',
    planType: 'Upper/Lower Split',
    goal: 'muscleGain',
    difficulty: 'intermediate',
    targetMuscles: ['chest', 'back', 'shoulders', 'biceps', 'triceps'],
    equipment: ['barbell', 'dumbbell', 'cable'],
    estimatedDuration: 55,
    recommendedFor: ['intermediate', '4 days/week'],
    exercises: [
      { exerciseId: 'bench_press', exerciseName: 'Bench Press', sets: 4, reps: 8, weight: 65, restSeconds: 120 },
      { exerciseId: 'barbell_row', exerciseName: 'Barbell Row', sets: 4, reps: 8, weight: 55, restSeconds: 120 },
      { exerciseId: 'shoulder_press', exerciseName: 'Shoulder Press', sets: 3, reps: 10, weight: 40, restSeconds: 90 },
      { exerciseId: 'lat_pulldown', exerciseName: 'Lat Pulldown', sets: 3, reps: 10, weight: 45, restSeconds: 90 },
      { exerciseId: 'triceps_pushdown', exerciseName: 'Triceps Pushdown', sets: 3, reps: 12, weight: 25, restSeconds: 60 },
      { exerciseId: 'biceps_curl', exerciseName: 'Biceps Curl', sets: 3, reps: 12, weight: 12, restSeconds: 60 },
    ],
  },
];

// ── Gym Challenges ─────────────────────────────────────────────────────────────

const gymChallenges = [
  {
    title: '30-Day Consistency Challenge',
    description: 'Train at least 3x per week for 30 days straight. Build the habit that builds the physique.',
    type: 'consistency',
    goal: 'Complete 12+ workouts in 30 days',
    startDate: null,
    endDate: null,
  },
  {
    title: '100kg Bench Press Club',
    description: 'Hit a 100kg bench press. The classic gym milestone. Track your progress every push day.',
    type: 'strength',
    goal: 'Bench press 100kg for 1 rep',
    startDate: null,
    endDate: null,
  },
  {
    title: '1,000kg Week',
    description: 'Lift 1,000kg total volume in a single week. Log every set and watch the numbers add up.',
    type: 'volume',
    goal: 'Accumulate 1,000kg total volume in 7 days',
    startDate: null,
    endDate: null,
  },
  {
    title: 'First Pull-Up',
    description: 'If you can\'t do a pull-up yet, this challenge will get you there. Train lat pulldowns and negatives consistently.',
    type: 'skill',
    goal: 'Complete your first unassisted pull-up',
    startDate: null,
    endDate: null,
  },
];

// ── Seed ──────────────────────────────────────────────────────────────────────

async function seed() {
  console.log('Seeding exercises...');
  const exerciseBatch = db.batch();
  for (const exercise of exercises) {
    const slug = exercise.name.toLowerCase().replace(/\s+/g, '_');
    const ref = db.collection('exercises').doc(slug);
    exerciseBatch.set(ref, { ...exercise, createdAt: now, updatedAt: now });
  }
  await exerciseBatch.commit();
  console.log(`✓ ${exercises.length} exercises seeded`);

  console.log('Seeding workout templates...');
  const templateBatch = db.batch();
  for (const template of templates) {
    const ref = db.collection('workoutTemplates').doc();
    templateBatch.set(ref, { ...template, createdAt: now, updatedAt: now });
  }
  await templateBatch.commit();
  console.log(`✓ ${templates.length} workout templates seeded`);

  console.log('Seeding gym challenges...');
  const challengeBatch = db.batch();
  for (const challenge of gymChallenges) {
    const ref = db.collection('gymChallenges').doc();
    challengeBatch.set(ref, { ...challenge, createdAt: now });
  }
  await challengeBatch.commit();
  console.log(`✓ ${gymChallenges.length} gym challenges seeded`);

  console.log('Done! 🦎');
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
