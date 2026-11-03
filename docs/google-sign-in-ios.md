# iOS Google Sign-In — configured 2026-11-03

## Configuration applied

- Runner bundle ID: `com.joytech.hexcy` in Debug/Profile/Release, matching Android and the provided iOS OAuth plist.
- RunnerTests: `com.joytech.hexcy.RunnerTests`.
- `ios/Runner/Info.plist` now contains `GIDClientID` = `976257170411-b88g3kgv47qltau9r79as3oovocph0b5.apps.googleusercontent.com`.
- `CFBundleURLTypes` registers callback scheme `com.googleusercontent.apps.976257170411-b88g3kgv47qltau9r79as3oovocph0b5`.
- Client values came from the user's downloaded OAuth plist; its BUNDLE_ID matches Runner.
- The confirmed iOS client ID is also passed to the Dart constructor on iOS, together with serverClientId. In google_sign_in_ios 5.9.0, passing only serverClientId without a runtime clientId or GoogleService plist produces no runtime GIDConfiguration; the SDK falls back to Info.plist and ignores that Dart server client ID. Passing both IDs fixes this audience configuration. No iOS Dart define is required.
- The existing backend Web client remains supplied through Dart serverClientId. Default: `976257170411-ilje208fkdmfdsou1ko0ccqr10vkru96.apps.googleusercontent.com`. GOOGLE_SERVER_CLIENT_ID can override it. A duplicate GIDServerClientID entry is unnecessary.
- The downloaded OAuth plist is a configuration reference, not a Firebase runtime dependency; it was not copied into Runner or added to Xcode resources.

## Existing authentication

`google_sign_in` resolves to 6.3.0; its iOS implementation resolves to 5.9.0. Existing APIs match these versions.

Google sign-in returns an ID token, which is posted as `{"id_token": token}` to `api/v1/auth/google`. The backend access token is saved in secure storage. This is custom backend authentication; no Firebase Authentication dependency or initialization is required.

Cancellation exits without a backend request; empty tokens are rejected. Password and Google login prevent overlapping login requests. Logout removes the backend access token only; Google account selection on subsequent sign-in may reuse the previous account.

## Run on an iOS simulator

```sh
cd /Users/user/Documents/flutter/mobile_hexy
flutter pub get
open -a Simulator
flutter devices
flutter run
```

Select the iOS simulator if prompted. Fully stop and rebuild the app after these Info.plist changes; hot reload is insufficient. No GOOGLE_IOS_CLIENT_ID argument is needed.

Test browser consent, return to app, backend session, cancellation, logout/re-login and session restoration after restarting. An iPhone is not required for this simulator test.

## Verification and remaining external checks

Plist syntax and values, bundle matching, and diff whitespace were checked. Dart formatting was checked. Flutter analysis/tests/build and an actual Google login have not been completed: the project has no generated package configuration and Flutter's SDK cache write was denied by the session's filesystem restrictions. The initial simulator query also could not connect to CoreSimulatorService under those restrictions.

Google Cloud consent/test-user settings, the Web client's type/ownership, Apple registration/signing, and backend audience verification remain unverified. Matching numeric client prefixes alone does not verify console configuration. The backend must verify signature, issuer, expiry and audience against the Web client ID, using verified sub as identity. Never log tokens.

## References

- https://pub.dev/packages/google_sign_in_ios/versions/5.9.0
- https://developers.google.com/identity/sign-in/ios/start-integrating
- https://codelabs.developers.google.com/codelabs/sign-in-with-google-ios

## Audience error fix

The previous plist-only client configuration could issue an ID token for the iOS client instead of the backend Web client. Both IDs are now supplied at runtime on iOS. The callback scheme remains in Info.plist. Fully stop/rebuild the app and sign in again to obtain a fresh token. Backend accepted audiences remain unverified; if the error persists compare the actual token aud with the backend allowlist without logging or sharing the full token. Do not disable audience validation.
