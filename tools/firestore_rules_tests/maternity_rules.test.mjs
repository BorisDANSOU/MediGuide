import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

const emulatorHost = process.env.FIRESTORE_EMULATOR_HOST;
const directory = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(directory, '../..');

test('maternity rules restrict reference and progress writes', {
  skip: !emulatorHost && 'Set FIRESTORE_EMULATOR_HOST to run Firestore rules tests.',
}, async () => {
  const [host, portText] = emulatorHost.split(':');
  const environment = await initializeTestEnvironment({
    projectId: 'mediguide-rules-test',
    firestore: {
      host,
      port: Number(portText),
      rules: await readFile(path.join(repositoryRoot, 'firestore.rules'), 'utf8'),
    },
  });

  try {
    const ownerDb = environment.authenticatedContext('owner-a').firestore();
    const otherDb = environment.authenticatedContext('owner-b').firestore();
    const guestDb = environment.unauthenticatedContext().firestore();

    await assertSucceeds(
      getDoc(doc(ownerDb, 'maternity_vaccines/bcg')),
    );
    await assertFails(
      setDoc(doc(ownerDb, 'maternity_vaccines/bcg'), { name: 'Changed' }),
    );
    await assertSucceeds(
      setDoc(doc(ownerDb, 'users/owner-a/vaccine_progress/bcg'), {
        completed: true,
      }),
    );
    await assertFails(
      getDoc(doc(otherDb, 'users/owner-a/vaccine_progress/bcg')),
    );
    await assertFails(
      setDoc(doc(otherDb, 'users/owner-a/maternity_tasks/cpn1'), {
        isCompleted: true,
      }),
    );
    await assertFails(
      getDoc(doc(guestDb, 'users/owner-a/cpn_progress/cpn1')),
    );
  } finally {
    await environment.cleanup();
  }
});
