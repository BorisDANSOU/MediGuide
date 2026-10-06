import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const PROJECT_ID = 'mediguide-1d550';
const REFERENCE_FILE = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../assets/data/maternity_reference.json',
);
const COLLECTIONS = [
  ['vaccines', 'maternity_vaccines', 'recommendedMonth'],
  ['cpnSchedules', 'maternity_cpn_schedules', 'recommendedWeek'],
];

export async function readReferences(filePath = REFERENCE_FILE) {
  const parsed = JSON.parse(await readFile(filePath, 'utf8'));
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new TypeError('Maternity seed data must be a JSON object.');
  }

  for (const [key, , scheduleField] of COLLECTIONS) {
    const records = parsed[key];
    if (!Array.isArray(records)) {
      throw new TypeError(`Maternity seed data is missing "${key}".`);
    }
    const ids = new Set();
    for (const record of records) {
      if (
        !record ||
        typeof record.id !== 'string' ||
        record.id.length === 0 ||
        record.id.includes('/') ||
        ids.has(record.id) ||
        typeof record.name !== 'string' ||
        !Number.isInteger(record[scheduleField]) ||
        record[scheduleField] < 0
      ) {
        throw new TypeError(`Invalid record in maternity seed list "${key}".`);
      }
      ids.add(record.id);
    }
  }
  return parsed;
}

export function createSeedPlan(references) {
  return COLLECTIONS.flatMap(([key, collection]) =>
    references[key].map(({ id, ...fields }) => ({
      collection,
      id,
      fields,
    })),
  );
}

export async function seedReferences({
  references,
  apply = false,
  db,
  log = console.log,
}) {
  const plan = createSeedPlan(references);
  if (!apply) {
    log(JSON.stringify({ mode: 'dry-run', projectId: PROJECT_ID, plan }, null, 2));
    return { applied: false, count: plan.length };
  }
  if (!db) {
    throw new Error('Admin Firestore is required when --apply is specified.');
  }

  const batch = db.batch();
  for (const item of plan) {
    batch.set(
      db.collection(item.collection).doc(item.id),
      item.fields,
      { merge: true },
    );
  }
  await batch.commit();
  log(`Applied ${plan.length} maternity reference documents to ${PROJECT_ID}.`);
  return { applied: true, count: plan.length };
}

async function main(args) {
  const unknownArgs = args.filter((argument) => argument !== '--apply');
  if (unknownArgs.length > 0 || args.filter((arg) => arg === '--apply').length > 1) {
    throw new Error('Usage: npm run seed [-- --apply]');
  }
  const apply = args.includes('--apply');
  const references = await readReferences();
  let db;
  if (apply) {
    const app =
      getApps().find((existing) => existing.options.projectId === PROJECT_ID) ??
      initializeApp({ projectId: PROJECT_ID });
    db = getFirestore(app);
  }
  await seedReferences({ references, apply, db });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main(process.argv.slice(2)).catch((error) => {
    console.error(`Maternity seed failed: ${error.message}`);
    process.exitCode = 1;
  });
}
