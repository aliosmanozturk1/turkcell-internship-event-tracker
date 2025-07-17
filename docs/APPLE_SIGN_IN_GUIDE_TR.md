# Apple Sign In Entegrasyon Rehberi (Türkçe)

Bu belge, **Apple Sign In** özelliğini `Event Tracker` iOS projesine entegre etmek ve kullanmak için adım adım yönergeler sağlar. Yapılandırma adımlarını, kod açıklamalarını ve en iyi uygulamaları içerir.

## İçindekiler
1. [Ön Koşullar](#ön-koşullar)
2. [Apple Sign In'i Yapılandırma](#apple-sign-ini-yapılandırma)
3. [Uygulama Ayrıntıları](#uygulama-ayrıntıları)
4. [Kodun Satır Satır Açıklaması](#kodun-satır-satır-açıklaması)
   - [LoginViewModel.swift](#loginviewmodelswift)
   - [LoginView.swift](#loginviewswift)
   - [AuthService.swift](#authserviceswift)
   - [AppleSignInHelper.swift](#applesigninhelperswift)
5. [Kullanıcı Akışı](#kullanıcı-akışı)
6. [Hata Yönetimi](#hata-yönetimi)
7. [Test İpuçları](#test-ipuçları)
8. [Ek Kaynaklar](#ek-kaynaklar)

## Ön Koşullar
- iOS 17 SDK içeren Xcode 15 veya daha yenisi.
- Geçerli bir Apple Developer hesabı.
- [Apple Developer portalı](https://developer.apple.com/account/) üzerinde kayıtlı uygulama bundle identifier'ı.

## Apple Sign In'i Yapılandırma
1. **Xcode'da özelliği etkinleştirin**
   - `Event Tracker.xcodeproj` dosyasını açın.
   - *Event Tracker* hedefini seçip **Signing & Capabilities** bölümüne gidin.
   - **Sign In with Apple** yeteneğini ekleyin.
2. **Uygulamanın bundle identifier'ını güncelleyin**
   - Xcode'daki bundle identifier'ın Apple Developer portalında kayıtlı olanla eşleştiğinden emin olun.
3. **Hizmet Kimliği ve anahtarı yapılandırın**
   - Developer portalında Apple Sign In için yeni bir **Services ID** oluşturun.
   - **Keys** bölümünden bir özel anahtar oluşturun. Anahtar dosyasını (.p8) güvenli tutun ve `Key ID`, `Team ID` ve `Client ID` (Service ID) değerlerini not alın. Bu değerler sunucunuzun ID token'ı doğrulaması için gereklidir.
4. **Backend'i yapılandırın**
   - Apple Sign In, alınan yetkilendirme token'ını doğrulamak ve oturum oluşturmak için bir backend gerektirir. Backend'iniz Apple ID token'ını ve cihazda oluşturulan `nonce` değerini işleyen bir uç nokta sağlamalıdır. Bu projede `AuthService.signInWithApple` yöntemi bu iletişimi gerçekleştirir.

## Uygulama Ayrıntıları
Apple Sign In, SwiftUI tabanlı kimlik doğrulama özelliği içinde uygulanmıştır.

### Nonce Oluşturma
[`Core/Helpers/AppleSignInHelper.swift`](../Event%20Tracker/Event%20Tracker/Core/Helpers/AppleSignInHelper.swift) dosyasında güvenli nonce oluşturma ve SHA256 ile karma alma fonksiyonları bulunur:
```swift
func randomNonceString(length: Int = 32) -> String { ... }
func sha256(_ input: String) -> String { ... }
```
Yetkilendirme isteği başlatılmadan önce kriptografik bir nonce oluşturulur ve SHA256 ile karma hâline getirilir. Apple, kimlik doğrulama sonrasında bu nonce'ı geri döndürür, böylece backend isteği doğrulayabilir.

### ViewModel Mantığı
[`LoginViewModel.swift`](../Event%20Tracker/Event%20Tracker/Features/Authentication/Login/LoginViewModel.swift) dosyasında iki ana yöntem bulunur:
```swift
func loginWithApple(request: ASAuthorizationAppleIDRequest)
func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async
```
- `loginWithApple`, isteğin scope'larını ayarlar ve hashed nonce'ı ekler.
- `handleAppleSignInResult`, sonucu alır, ID token'ı `AuthService.signInWithApple` ile backend'e gönderir ve görünüm durumunu günceller (örn. `isLogin` veya `errorMessage`).

### SwiftUI Entegrasyonu
[`LoginView.swift`](../Event%20Tracker/Event%20Tracker/Features/Authentication/Login/LoginView.swift) içinde oturum açma ekranına bir `SignInWithAppleButton` yerleştirilmiştir:
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
Bu buton kimlik doğrulama akışını tetikler ve geri dönüşleri view model'e iletir.

## Kodun Satır Satır Açıklaması

### LoginViewModel.swift
```swift
func loginWithApple(request: ASAuthorizationAppleIDRequest) {
    let nonce = randomNonceString()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)

    // Nonce'ı daha sonra kullanmak üzere sakla
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
            errorMessage = "Apple ile giriş başarısız oldu"
            isLoading = false
            return
        }

        do {
            let user = try await AuthService.shared.signInWithApple(idToken: idTokenString, nonce: nonce)
            email = user.email ?? ""
            isLogin = true
            currentNonce = nil
        } catch {
            isLogin = false
            if let error = error as? AuthService.AuthError {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }

    case .failure(let error):
        isLogin = false
        errorMessage = error.localizedDescription
    }

    isLoading = false
}
```
1. `func loginWithApple(request: ASAuthorizationAppleIDRequest)` – Sign In düğmesi yetkilendirme başlattığında tetiklenir.
2. `let nonce = randomNonceString()` – Yanıtı doğrulamak için rastgele bir değer üretir.
3. `request.requestedScopes = [.fullName, .email]` – Kullanıcının adını ve e-postasını ister.
4. `request.nonce = sha256(nonce)` – Nonce'ı Apple'a göndermeden önce karma hâline getirir.
5. `currentNonce = nonce` – Doğrulama için nonce'ı saklar.
6. `func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async` – Apple'dan dönen sonucu işler.
7. `isLoading = true` – Yükleniyor durumunu gösterir.
8. `errorMessage = nil` – Önceki hataları temizler.
9. `switch result` – Başarı veya hata durumunu değerlendirir.
10. `case .success(let authorization):` – Yetkilendirme başarılı olduğunda çalışır.
11. `guard let appleIDCredential ...` – Kimlik bilgilerini çıkarır ve nonce ile ID token'ın varlığını kontrol eder.
12. `isLogin = false` ... `return` – Geçersiz sonuçları işler ve erken çıkar.
13. `let user = try await AuthService.shared.signInWithApple` – Token'ı backend'e gönderir ve kullanıcıyı döndürür.
14. `email = user.email ?? ""` – Varsa kullanıcının e-postasını kaydeder.
15. `isLogin = true` – Kimlik doğrulamanın başarılı olduğunu belirtir.
16. `currentNonce = nil` – Saklanan nonce'ı temizler.
17. `catch { ... }` – Backend veya ağ hatalarını yakalar ve `errorMessage` olarak kaydeder.
18. `case .failure(let error):` – Yetkilendirme denetleyicisinden gelen hataları işler.
19. `isLoading = false` – İşlem sonunda yükleme göstergesini kaldırır.

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
1. `SignInWithAppleButton( .continue,` – Apple'ın sistem giriş düğmesini gösterir.
2. `onRequest: { request in` – Yetkilendirme başlamadan önce çağrılır.
3. `viewModel.loginWithApple(request: request)` – Scope'ları ve nonce'ı ayarlar.
4. `onCompletion: { result in` – Yetkilendirme bittikten sonra çağrılır.
5. `Task { await viewModel.handleAppleSignInResult(result) }` – Sonucu eşzamansız olarak işler.
6. `.signInWithAppleButtonStyle(.black)` – Düğmenin stilini belirler.
7. `.frame(maxWidth: .infinity)` – Düğmeyi yatayda genişletir.
8. `.frame(height: 50)` – Sabit bir yükseklik tanımlar.
9. `.clipShape(RoundedRectangle(cornerRadius: 10))` – Köşeleri yuvarlar.
10. `.disabled(viewModel.isLoading)` – Yükleme sırasında birden fazla tıklamayı engeller.

### AuthService.swift
```swift
func signInWithApple(idToken: String, nonce: String) async throws -> User {
    let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idToken, rawNonce: nonce)
    let authResult = try await auth.signIn(with: credential)
    return authResult.user
}
```
1. `func signInWithApple(idToken: String, nonce: String) async throws -> User` – Backend doğrulaması için giriş noktasıdır.
2. `let credential = OAuthProvider.credential...` – Apple ID token ve nonce ile bir Firebase kimliği oluşturur.
3. `let authResult = try await auth.signIn(with: credential)` – Kullanıcıyı Firebase ile oturum açtırır.
4. `return authResult.user` – Kimliği doğrulanmış kullanıcı nesnesini döndürür.

### AppleSignInHelper.swift
```swift
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError(
            "Nonce oluşturulamadı. SecRandomCopyBytes OSStatus \(errorCode) ile başarısız oldu"
        )
    }

    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    let nonce = randomBytes.map { byte in
        // Karakter setinden rastgele bir karakter seç
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
1. `func randomNonceString(length: Int = 32)` – Rastgele alfasayısal bir dize oluşturur.
2. `precondition(length > 0)` – Geçerli bir uzunluk sağlar.
3. `var randomBytes = [UInt8](repeating: 0, count: length)` – Bayt dizisi ayrılır.
4. `SecRandomCopyBytes` diziyi güvenli rastgele verilerle doldurur.
5. `fatalError` rastgele oluşturma başarısız olursa uygulamayı sonlandırır.
6. `let charset: [Character] = ...` – Nonce için izin verilen karakterler.
7. `let nonce = randomBytes.map { ... }` – Her baytı karakter setindeki bir karaktere dönüştürür.
8. `return String(nonce)` – Oluşturulan nonce'ı döndürür.
9. `func sha256(_ input: String) -> String` – Bir diziyi SHA-256 ile karmalar.
10. `let inputData = Data(input.utf8)` – Girdiyi veriye çevirir.
11. `let hashedData = SHA256.hash(data: inputData)` – Özeti hesaplar.
12. `let hashString = ...` – Özeti onaltılık bir dizeye dönüştürür.
13. `return hashString` – Karma çıktısını döndürür.

## Kullanıcı Akışı
1. Kullanıcı **Apple ile Devam Et** düğmesine dokunur.
2. `loginWithApple` nonce üretir ve isteği yapılandırır.
3. Apple yerel giriş ekranını gösterir.
4. Başarılı olursa `handleAppleSignInResult` ID token'ı alır, `AuthService` aracılığıyla doğrular ve kullanıcı oturumunu saklar.
5. Görünüm güncellenir (örneğin `isLogin` `true` olduğunda `RootView` ana içeriğe geçer).

## Hata Yönetimi
- Oturum açma sırasında herhangi bir hata, `LoginViewModel` içindeki `errorMessage` değişkenine atanır.
- Arayüz bu mesajı kullanıcıya gösterebilir.
- İşlem tamamlandığında saklanan nonce'ı temizlemeyi (`currentNonce = nil`) unutmayın.

## Test İpuçları
- Mümkünse gerçek bir cihaz kullanın; bazı simülatör yapılandırmalarında giriş akışı çalışmayabilir.
- Apple Developer kimlik bilgilerinizin ve Service ID'nizin hem Xcode'da hem backend'de doğru ayarlandığından emin olun.

## Ek Kaynaklar
- [Apple Developer Documentation – Sign in with Apple](https://developer.apple.com/documentation/sign_in_with_apple)
- [ASAuthorizationAppleIDProvider](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidprovider)
- [AuthenticationServices Framework](https://developer.apple.com/documentation/authenticationservices)
