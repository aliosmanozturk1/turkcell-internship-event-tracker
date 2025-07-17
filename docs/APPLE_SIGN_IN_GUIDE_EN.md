# Apple Sign In Integration Guide

This document provides a detailed walkthrough for integrating and using **Apple Sign In** with the `Event Tracker` iOS project. It covers configuration steps, code reference, and best practices so you can reproduce and extend the feature easily.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Configuring Apple Sign In](#configuring-apple-sign-in)
3. [Implementation Details](#implementation-details)
4. [Line-by-Line Code Breakdown](#line-by-line-code-breakdown)
   - [LoginViewModel.swift](#loginviewmodelswift)
   - [LoginView.swift](#loginviewswift)
   - [AuthService.swift](#authserviceswift)
   - [AppleSignInHelper.swift](#applesigninhelperswift)
5. [User Flow](#user-flow)
6. [Error Handling](#error-handling)
7. [Testing Tips](#testing-tips)
8. [Further Reading](#further-reading)

## Prerequisites
- Xcode 15 or newer with iOS 17 SDK.
- A valid Apple Developer account.
- Your app's bundle identifier registered in the [Apple Developer portal](https://developer.apple.com/account/).

## Configuring Apple Sign In
1. **Enable capability in Xcode**
   - Open `Event Tracker.xcodeproj`.
   - Select the *Event Tracker* target and navigate to **Signing & Capabilities**.
   - Add the **Sign In with Apple** capability.

2. **Update the app's bundle identifier**
   - Ensure that the bundle identifier in Xcode matches the one you registered on the Apple Developer portal.

3. **Configure the service ID and key**
   - In the Developer portal, create a new **Services ID** for Apple Sign In.
   - Create a private key from the **Keys** section. Keep the key file (.p8) secure and note the `Key ID`, `Team ID`, and `Client ID` (the Service ID). These values are needed by your server to verify the ID token.

4. **Configure your backend**
   - Apple Sign In requires a backend to verify the received authorization token and create sessions. Ensure your backend exposes an endpoint to process the Apple ID token and `nonce` generated on the device. In this project, the `AuthService.signInWithApple` method handles that communication.
@@ -47,50 +51,52 @@ A cryptographic nonce is generated before starting the sign-in request and hashe
### ViewModel Logic
The view model [`LoginViewModel.swift`](../Event%20Tracker/Event%20Tracker/Features/Authentication/Login/LoginViewModel.swift) provides two key methods:
```swift
func loginWithApple(request: ASAuthorizationAppleIDRequest)
func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async
```
- `loginWithApple` configures the request's scopes and attaches the hashed nonce.
- `handleAppleSignInResult` extracts the ID token from the result, communicates with `AuthService.signInWithApple`, and updates view state accordingly (e.g., sets `isLogin` or `errorMessage`).

### SwiftUI Integration
Within [`LoginView.swift`](../Event%20Tracker/Event%20Tracker/Features/Authentication/Login/LoginView.swift), a `SignInWithAppleButton` is embedded in the login screen:
```swift
SignInWithAppleButton(.continue,
    onRequest: { request in viewModel.loginWithApple(request: request) },
    onCompletion: { result in
        Task { await viewModel.handleAppleSignInResult(result) }
    }
)
.signInWithAppleButtonStyle(.black)
.frame(maxWidth: .infinity, height: 50)
```
This button triggers the authentication flow and calls back to the view model.

## Line-by-Line Code Breakdown

### LoginViewModel.swift

The snippet below comes from [`LoginViewModel.swift`](../Event%20Tracker/Event%20Tracker/Features/Authentication/Login/LoginViewModel.swift) and orchestrates Apple authentication.

```swift
func loginWithApple(request: ASAuthorizationAppleIDRequest) {
    let nonce = randomNonceString()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)

    // Store nonce for later use
    currentNonce = nonce
}

func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
    isLoading = true
    errorMessage = nil

    switch result {
    case .success(let authorization):
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idToken = appleIDCredential.identityToken,
              let idTokenString = String(data: idToken, encoding: .utf8),
              let nonce = currentNonce else {
            isLogin = false
            errorMessage = "Apple Sign-In failed"
            isLoading = false
@@ -118,47 +124,142 @@ func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {

    isLoading = false
}
```

1. `func loginWithApple(request: ASAuthorizationAppleIDRequest)` – triggered when the Sign In button begins authorization.
2. `let nonce = randomNonceString()` – generates a random value used to validate the response.
3. `request.requestedScopes = [.fullName, .email]` – asks for the user's name and email.
4. `request.nonce = sha256(nonce)` – hashes the nonce before sending it to Apple.
5. `currentNonce = nonce` – stores the original nonce for later verification.
6. `func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async` – processes the response from Apple.
7. `isLoading = true` – displays a loading state.
8. `errorMessage = nil` – clears any previous error.
9. `switch result` – handles success or failure.
10. `case .success(let authorization):` – executed when the authorization succeeds.
11. `guard let appleIDCredential ...` – extracts the credential and ensures the nonce and ID token exist.
12. `isLogin = false` ... `return` – handles invalid results and exits early.
13. `let user = try await AuthService.shared.signInWithApple` – sends the token to the backend for verification and returns a user.
14. `email = user.email ?? ""` – saves the user's email if provided.
15. `isLogin = true` – marks authentication as successful.
16. `currentNonce = nil` – clears the stored nonce.
17. `catch { ... }` – captures backend or network errors and exposes them via `errorMessage`.
18. `case .failure(let error):` – handles errors coming from the authorization controller.
19. `isLoading = false` – removes the loading indicator at the end of the process.

### LoginView.swift

```swift
SignInWithAppleButton( .continue,
    onRequest: { request in
        viewModel.loginWithApple(request: request)
    },
    onCompletion: { result in
        Task {
            await viewModel.handleAppleSignInResult(result)
        }
    }
)
.signInWithAppleButtonStyle(.black)
.frame(maxWidth: .infinity)
.frame(height: 50)
.clipShape(RoundedRectangle(cornerRadius: 10))
.disabled(viewModel.isLoading)
```

1. `SignInWithAppleButton( .continue,` – displays Apple's system sign-in button.
2. `onRequest: { request in` – callback before starting authorization.
3. `viewModel.loginWithApple(request: request)` – configures scopes and nonce.
4. `onCompletion: { result in` – called after authorization finishes.
5. `Task { await viewModel.handleAppleSignInResult(result) }` – processes the result asynchronously.
6. `.signInWithAppleButtonStyle(.black)` – sets the button's visual style.
7. `.frame(maxWidth: .infinity)` – expands the button horizontally.
8. `.frame(height: 50)` – defines a consistent height.
9. `.clipShape(RoundedRectangle(cornerRadius: 10))` – rounds the button corners.
10. `.disabled(viewModel.isLoading)` – prevents multiple taps while loading.

### AuthService.swift

```swift
func signInWithApple(idToken: String, nonce: String) async throws -> User {
    let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idToken, rawNonce: nonce)
    let authResult = try await auth.signIn(with: credential)
    return authResult.user
}
```

1. `func signInWithApple(idToken: String, nonce: String) async throws -> User` – entry point for backend verification.
2. `let credential = OAuthProvider.credential...` – creates a Firebase credential using the Apple ID token and nonce.
3. `let authResult = try await auth.signIn(with: credential)` – signs the user in with Firebase.
4. `return authResult.user` – returns the authenticated user object.

### AppleSignInHelper.swift

```swift
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError(
            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
    }

    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
    }

    return String(nonce)
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()

    return hashString
}
```

1. `func randomNonceString(length: Int = 32)` – creates a random alphanumeric string.
2. `precondition(length > 0)` – ensures a valid length.
3. `var randomBytes = [UInt8](repeating: 0, count: length)` – allocates a byte array.
4. `SecRandomCopyBytes` fills the array with secure random data.
5. `fatalError` terminates if random generation fails.
6. `let charset: [Character] = ...` – allowed characters for the nonce.
7. `let nonce = randomBytes.map { ... }` – maps each byte to a character in the charset.
8. `return String(nonce)` – outputs the final nonce value.
9. `func sha256(_ input: String) -> String` – hashes a string using SHA-256.
10. `let inputData = Data(input.utf8)` – converts the input to data.
11. `let hashedData = SHA256.hash(data: inputData)` – computes the digest.
12. `let hashString = ...` – turns the digest into a hex string.
13. `return hashString` – returns the hashed output.

## User Flow
1. User taps **Continue with Apple**.
2. `loginWithApple` generates a nonce and configures the request.
3. Apple presents the native sign-in sheet.
4. Upon success, `handleAppleSignInResult` obtains the ID token, verifies it via `AuthService`, and stores the user session.
5. The view updates (e.g., `RootView` switches to the main content when `isLogin` becomes `true`).

## Error Handling
- Any failure during sign-in sets `errorMessage` inside `LoginViewModel`.
- The UI can present this message to inform the user.
- Always clear the stored nonce (`currentNonce = nil`) after the process completes.

## Testing Tips
- Use a real device when possible, as the sign-in flow may not function with all simulator configurations.
- Ensure your Apple Developer credentials and service ID are correctly set in both Xcode and the backend.

## Further Reading
- [Apple Developer Documentation – Sign in with Apple](https://developer.apple.com/documentation/sign_in_with_apple)
- [ASAuthorizationAppleIDProvider](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider)
- [AuthenticationServices Framework](https://developer.apple.com/documentation/authenticationservices)