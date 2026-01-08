# Firebase Cloud Functions Setup

This folder provides a minimal Cloud Functions implementation for grade
notifications. You still need to initialize Firebase in your environment.

Steps:
1) Install Firebase CLI and log in.
2) Run `firebase init functions` in the `firebase` directory and choose Node 18.
3) Replace the generated `functions/index.js` and `functions/package.json`
   with the versions in this folder.
4) Deploy with `firebase deploy --only functions`.
5) Copy the deployed functions base URL into `lib/shared/constants.dart`
   as `firebaseFunctionsBaseUrl`.

Notes:
- The function uses the session cookies uploaded from the app to fetch grades.
- When the session expires, it sends a "session expired" notification so the
  user can open the app and refresh the session.
