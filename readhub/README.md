<div align="center">

# 📚 ReadHub

**Kitap severlerin buluşma noktası — okuma takibi, topluluk tartışmaları ve kişiselleştirilmiş öneriler.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## 🌟 Uygulama Hakkında

**ReadHub**, Flutter ile geliştirilmiş, Firebase altyapısı üzerine inşa edilmiş modern bir kitap takip ve topluluk uygulamasıdır. Kullanıcılar kitap arayabilir, okuma durumlarını takip edebilir, diğer okuyucularla spoilerli veya spoilersiz yorumlar paylaşabilir ve kişiselleştirilmiş kitap önerileri alabilir.

---

## 📱 Ekran Görüntüleri

> Uygulamayı yerel olarak çalıştırarak ekran görüntülerini görebilirsiniz.

---

## ✨ Özellikler

### 🏠 Ana Sayfa (Home)
- **Şu an Okunanlar:** Okuma durumu "Okuyorum" olarak işaretlenen kitaplar anlık olarak listelenir.
- **Kişiselleştirilmiş Öneriler:** Okuduğunuz yazarlara ve kategorilere göre dinamik kitap önerileri.
- **Popüler Kitaplar:** Genel popülerlik sıralamasına göre kitap listesi.
- **Canlı Senkronizasyon:** Firestore Stream ile veriler sayfa yenilenmeden anlık güncellenir.

### 🔍 Kitap Arama
- **Google Books API** entegrasyonu ile milyonlarca kitap arasında arama.
- Kitap kapağı, yazar, puan ve açıklama bilgileri.
- Anlık arama sonuçları, shimmer yüklenme animasyonları.

### 📖 Kitap Detayı
- Kitap kapağı, başlık, yazar, puan, sayfa sayısı ve açıklama.
- **Okuma Durumu Takibi:**
  - 📌 Okumak İstiyorum
  - 📖 Okuyorum
  - ✅ Bitti
- Topluluk tartışmalarına hızlı erişim butonu.
- Okuma durumu değiştiğinde Ana Sayfa **anında** güncellenir.

### 💬 Topluluk (Community)
- Kitap bazlı tartışma odaları — Her kitabın kendi topluluk sayfası vardır.
- **Bölüm bazlı yorumlar:** Genel, Bölüm 1, Bölüm 2, Bölüm 3, Son Değerlendirme.
- **Spoiler koruması:** Spoilerli yorumlar otomatik olarak gizlenir, kullanıcı görmek istediğinde açar.
- **Yanıtlar (Replies):** Yorumların altına yanıt yazabilme.
- **Beğeni sistemi:** Yorum ve yanıtları beğenebilme (dolu kırmızı kalp animasyonu).
- **Bildirimler:** Yorumunuz beğenildiğinde veya yanıtlandığında bildirim alırsınız.
- Canlı topluluk akışı (Aktif tartışmalar listesi).

### 👤 Profil
- Kullanıcı adı ve profil fotoğrafı.
- **Okuma İstatistikleri:** Tamamlanan kitap sayısı, okunan toplam sayfa.
- **Kitaplık sekmeleri:** Okuyorum / Tamamladım / Okumak İstiyorum.
- **Yorumlarım:** Tüm kitaplara yapılan yorumlar tek bir akışta, anlık güncelleme ile.
- Profil fotoğrafı güncellendiğinde Ana Sayfa dahil tüm ekranlar anında yansır.
- Değişken avatar sistemi (harf baş harfleri ile renk kodlu avatarlar).

### 🔔 Bildirimler
- Yorum beğeni bildirimleri.
- Yanıt bildirimleri.
- Bildirim geçmişi ekranı.

### ⚙️ Ayarlar
- **Karanlık / Aydınlık mod** geçişi.
- Hesap bilgilerini düzenleme.
- Çıkış yapma.

### 🔐 Kimlik Doğrulama
- E-posta ve şifre ile **Kayıt & Giriş**.
- Premium gradyan logolu, modern giriş ekranı.
- Firebase Authentication entegrasyonu.
- Oturum durumuna göre otomatik yönlendirme.

---

## 🏗️ Mimari & Teknoloji

### Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| **Framework** | Flutter 3.x + Dart 3.x |
| **State Management** | Provider + ChangeNotifier |
| **Navigasyon** | GoRouter |
| **Backend** | Firebase (Firestore, Auth) |
| **Kitap API** | Google Books API |
| **UI Kütüphaneleri** | Lucide Icons, Google Fonts, Shimmer |
| **Yerel Depolama** | Shared Preferences |

### Proje Yapısı

```
lib/
├── core/
│   ├── routing/         # GoRouter navigasyon
│   ├── theme/           # AppTheme, AppColors
│   └── widgets/         # Paylaşılan widget'lar (BottomNav, BookCover vb.)
│
└── features/
    ├── auth/            # Giriş & Kayıt ekranları + ViewModel
    ├── home/            # Ana sayfa, arama, kitap repository
    ├── book_detail/     # Kitap detay + okuma durumu
    ├── community/       # Topluluk tartışmaları, yorumlar, beğeniler
    └── profile/         # Profil, bildirimler, ayarlar
```

### Veri Mimarisi (Firestore)

```
users/
  {uid}/
    reading_states/   → Okuma durumu kayıtları
    my_comments/      → Anlık profil sync için yorumlar (denormalize)

books/
  {bookId}/
    comments/
      {commentId}/
        replies/      → Yoruma yanıtlar
```

### Anlık Senkronizasyon (Reactive)

- **Ana Sayfa:** `reading_states` koleksiyonu stream ile dinlenir → durum değişince sayfa otomatik güncellenir.
- **Profil Yorumları:** `my_comments` koleksiyonu stream ile dinlenir → yorum yapılınca profil anında güncellenir.
- **Topluluk:** Yorumlar ve yanıtlar stream ile canlı aktarılır.

---

## 🚀 Kurulum

### Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.x)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android Studio veya VS Code
- Bir Firebase projesi

### Adımlar

```bash
# 1. Repoyu klonlayın
git clone https://github.com/kullanici-adiniz/readhub.git
cd readhub

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Firebase yapılandırması
# Firebase Console'dan google-services.json (Android) veya
# GoogleService-Info.plist (iOS) dosyasını ilgili klasöre koyun

# 4. Uygulamayı çalıştırın
flutter run
```

### Firebase Ayarları

Aşağıdaki Firebase servislerini aktif etmeniz gerekmektedir:

- ✅ **Authentication** → E-posta/Şifre sağlayıcısı
- ✅ **Cloud Firestore** → Veritabanı (test modunda başlatın)

#### Firestore Güvenlik Kuralları (Geliştirme)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📦 Kullanılan Paketler

| Paket | Versiyon | Amaç |
|---|---|---|
| `provider` | ^6.1.5 | State management |
| `go_router` | ^17.1.0 | Navigasyon |
| `google_fonts` | ^8.0.2 | Tipografi |
| `lucide_icons` | ^0.257.0 | Modern ikonlar |
| `firebase_core` | ^4.6.0 | Firebase başlatma |
| `firebase_auth` | ^6.3.0 | Kimlik doğrulama |
| `cloud_firestore` | ^6.2.0 | Gerçek zamanlı veritabanı |
| `http` | ^1.6.0 | Google Books API istekleri |
| `shared_preferences` | ^2.5.5 | Yerel ayarlar (tema vb.) |
| `shimmer` | ^3.0.0 | Yüklenme animasyonları |

---

## 🎨 Tasarım Prensipleri

- **Floating Bottom Navigation Bar** — Yuvarlak köşeli, gölgeli, modern alt menü
- **Karanlık / Aydınlık Mod** — Tam tema desteği
- **Gradyan Logo** — Premium marka kimliği
- **Shimmer Animasyonlar** — Yüklenme süreçlerinde pürüzsüz deneyim
- **Spoiler Koruma** — Okuyucu deneyimi odaklı tasarım
- **Anlık Geri Bildirim** — Her etkileşimde anlık UI güncellemesi

---

## 📋 Yol Haritası

- [ ] Sonsuz kaydırma (pagination)
- [ ] Kitap okuma ilerlemesi (şu anki sayfa)
- [ ] Sosyal takip sistemi (kullanıcıları takip et)
- [ ] Kitaplık içi arama ve filtreleme
- [ ] Push bildirimleri (Firebase Cloud Messaging)
- [ ] Offline destek (Firestore cache)

---

## 🤝 Katkıda Bulunma

Pull request ve issue açmaktan çekinmeyin!

1. Fork'a tıklayın
2. Yeni bir branch açın (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: yeni özellik eklendi'`)
4. Branch'inizi pushlayın (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) kapsamında lisanslanmıştır.

---

<div align="center">
  <b>ReadHub</b> — Kitaplarla dolu bir dünya 📖
</div>
