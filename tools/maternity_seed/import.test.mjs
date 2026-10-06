import assert from 'node:assert/strict';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';

import {
  createSeedPlan,
  readReferences,
  seedReferences,
} from './import.mjs';

test('dry-run emits deterministic IDs without touching Firestore', async () => {
  const references = await readReferences();
  const writes = [];
  const result = await seedReferences({
    references,
    log: (message) => writes.push(message),
  });

  assert.equal(result.applied, false);
  assert.equal(result.count, 15);
  assert.equal(writes.length, 1);
  assert.match(writes[0], /"mode": "dry-run"/);
  assert.deepEqual(createSeedPlan(references).slice(0, 2).map(({ id }) => id), [
    'bcg',
    'polio0',
  ]);
});

test('--apply performs merge writes only after explicit opt-in', async () => {
  const references = await readReferences();
  const writes = [];
  const db = {
    batch() {
      return {
        set(reference, fields, options) {
          writes.push({ collection: reference.collection, id: reference.id, fields, options });
        },
        async commit() {},
      };
    },
    collection(collection) {
      return { doc: (id) => ({ collection, id }) };
    },
  };

  const result = await seedReferences({ references, apply: true, db, log() {} });
  assert.equal(result.applied, true);
  assert.equal(writes.length, 15);
  assert.ok(writes.every((write) => write.options.merge === true));
  assert.ok(writes.every((write) => !('completed' in write.fields)));
});

test('rejects malformed and duplicate reference records', async () => {
  const directory = await mkdtemp(path.join(os.tmpdir(), 'maternity-seed-'));
  const filePath = path.join(directory, 'invalid.json');
  try {
    await writeFile(
      filePath,
      JSON.stringify({
        vaccines: [{ id: 'same', name: 'A', recommendedMonth: 0 }, { id: 'same', name: 'B', recommendedMonth: 1 }],
        cpnSchedules: [],
      }),
    );
    await assert.rejects(readReferences(filePath), /Invalid record/);
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
});
