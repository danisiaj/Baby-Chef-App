/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

const adminCode = defineSecret("ADMIN_CODE");
const clinicianCode = defineSecret("CLINICIAN_CODE");

/**
 * Validates password policy requirements.
 * @param {string} password The password to validate.
 * @return {boolean} True when the password meets policy requirements.
 */
function isValidPassword(password: string): boolean {
  if (password.length < 8 || password.length > 12) return false;
  if (!/[A-Z]/.test(password)) return false;
  if (!/\d/.test(password)) return false;
  if (!/[!@#$%^&*()_\-=[\]{};:'"\\|,.<>/?]/.test(password)) return false;
  return true;
}

export const createUserWithCode = onCall(
  {secrets: [adminCode, clinicianCode]},
  async (request) => {
    const {email, password, username, firstName, lastName, code} =
      request.data || {};

    if (!email || !password || !username || !firstName || !lastName) {
      throw new HttpsError("invalid-argument", "Missing required fields.");
    }

    if (!isValidPassword(password)) {
      throw new HttpsError("invalid-argument", "Password does not meet policy");
    }

    let role = "Clinician";
    if (code && code === adminCode.value()) {
      role = "Admin";
    } else if (code && code === clinicianCode.value()) {
      role = "Clinician";
    }

    try {
      const user = await admin.auth().createUser({
        email,
        password,
        displayName: `${firstName} ${lastName}`.trim(),
      });

      await admin.database().ref(`users/${user.uid}`).set({
        firstName,
        lastName,
        username,
        email,
        role,
        createdAt: admin.database.ServerValue.TIMESTAMP,
      });

      return {uid: user.uid, role};
    } catch (err: unknown) {
      if (err instanceof Error && "code" in err) {
        const code = (err as {code?: string}).code;
        if (code === "auth/email-already-exists") {
          throw new HttpsError("already-exists", "Email already in use.");
        }
      }
      throw new HttpsError("internal", "Failed to create user.");
    }
  }
);
