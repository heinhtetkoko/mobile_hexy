# Google Sign-In for Android / Google Play

## Verified project configuration

- Published Android application ID and namespace: `com.joytech.hexcy` (not `com.joytech.hexy`). Do not rename an existing Play app.
- `google_sign_in` resolves to 6.3.0; Android implementation resolves to 6.2.1. The existing constructor/signIn/authentication APIs match these versions. Flutter's plugin loader registers the Android plugin automatically; no manual native registration or extra Google activity is required. A 7.x migration is separate work.
- `AuthViewModel.loginWithGoogle` requests an ID token using `serverClientId`, then sends `{"id_token": ...}` to `api/v1/auth/google`. This is custom backend authentication, not Firebase Authentication.
- Current default server client ID: `976257170411-ilje208fkdmfdsou1ko0ccqr10vkru96.apps.googleusercontent.com`. Its ownership, client type and backend configuration cannot be verified from this repository. Confirm it is a **Web application** OAuth client. Never pass an Android client ID here.
- Override when needed with `--dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com`. Keep the existing default if it is the correct production Web client; changing it without updating the backend audience can break login.
- No `google-services.json`, Google Services Gradle plugin, `firebase_core`, or `firebase_auth` is present. This is valid with the explicit server client ID. Adding a JSON file alone would not register a signing certificate or fix OAuth.
- Release signing already uses `android/key.properties` and its configured keystore, with no debug signing fallback. The configured keystore exists and its certificate was readable. Signing properties and keystores are ignored by `android/.gitignore`; keep them private and preserve backups. Relative `storeFile` paths resolve from `android/app` with the current Gradle setup.
- Main manifest already declares INTERNET and Flutter embedding v2.

## Local release certificate (inspected November 1, 2026)

This is the certificate in the locally configured release keystore. It is not proof of the certificate Google Play uses.

```text
SHA-1:   23:26:80:3F:0E:A5:C5:56:72:2C:CC:E0:BA:B4:CA:54:48:85:77:4D
SHA-256: 08:9F:5D:52:EE:B2:9C:C2:96:28:FD:27:31:27:8A:8A:E6:24:A9:1A:F1:8D:A1:F1:98:A0:77:DD:71:4B:3A:E6
```

## Required Google Play and Google Cloud work

1. Open the existing app in Play Console and find **Play app signing / App integrity**. Copy the **app signing key certificate** SHA-1 and SHA-256. The upload certificate authenticates your uploaded bundle; Google signs distributed APKs with the app signing key. Do not assume the upload SHA equals the app signing SHA.
2. In the Google Cloud project containing the Web client above (or its confirmed replacement), inspect Credentials / OAuth clients. Ensure an **Android** OAuth client exists for package `com.joytech.hexcy` and the **Play app signing SHA-1**. Create a separate Android client for each required package/SHA-1 pair, including the local release SHA-1 above if testing sideloaded releases, and debug SHA-1 if testing debug builds. Register all applicable old/new app signing certificates if Play key upgrades serve different certificates to different Android versions. Internal App Sharing can use a separate signing certificate; register it when using that distribution path.
3. SHA-1 is the fingerprint used by the Android OAuth client registration. SHA-256 does not replace it. If managing the Android app through Firebase, register both SHA-1 and SHA-256 in its project settings.
4. Confirm the server Web OAuth client and Android OAuth clients belong to the same intended Cloud project. Configure Google Auth Platform branding/audience and required consent information. For an External app in Testing, add test users; configure the production publishing status for general users. Confirm an Internal audience is intentional if it restricts login to your organization.
5. The backend must verify the Google token signature, issuer, expiration, and `aud` against the configured **Web client ID**, then use verified `sub` as the Google identity. Do not disable audience checks to work around release failures. Confirm the production backend accepts the same audience requested by this build. No backend source was inspected here.

## If Firebase manages your OAuth configuration

Use the same Firebase/Google Cloud project, register the Android app with `com.joytech.hexcy`, and add the Play app signing SHA-1/SHA-256 plus the local/debug certificates you need. Check the resulting Android OAuth clients in Cloud Credentials.

If you actually use Firebase Authentication, enable Google under Authentication / Sign-in method. The current app does not sign in to Firebase, so enabling this provider is not by itself required by the existing backend flow.

If choosing Gradle-based configuration instead of the current explicit client ID, download the updated real `google-services.json` after console configuration, place it at `android/app/google-services.json`, declare a compatible `com.google.gms.google-services` plugin in `android/settings.gradle.kts`, and apply it in `android/app/build.gradle.kts`. Verify the JSON has the matching package and a Web OAuth entry (`client_type: 3`). An explicit Dart `serverClientId` takes precedence, so ensure it agrees with the desired Web client. No placeholder JSON or Firebase dependency was added in this inspection.

## Build and acceptance test

```sh
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
# For a different confirmed Web client:
# flutter build appbundle --release --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Upload the signed AAB to a Play internal testing track and install it through Google Play with an enrolled tester. Test Google login, cancellation, logout/login, and the production backend session. A successful local APK login does not validate Play signing registration. Check the backend audience when Google account selection succeeds but the API rejects the token. Legacy `ApiException: 10` usually indicates OAuth configuration (package, signing SHA, or client IDs); compare all three first.

Console settings, the Play signing fingerprints, and a successful Play-installed login remain unverified until someone with console/device access completes these steps.

## References

- https://developers.google.com/android/guides/client-auth
- https://support.google.com/googleplay/android-developer/answer/9842756
- https://developers.google.com/identity/sign-in/android/backend-auth
- https://pub.dev/packages/google_sign_in_android/versions/6.2.1
- https://firebase.google.com/docs/auth/android/google-signin
