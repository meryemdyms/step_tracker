# StepPulse

**StepPulse**, Android ve iOS için Flutter ile geliştirilmiş, çapraz platformlu bir adım sayma ve yürüyüş aktivitesi uygulamasıdır.

Uygulama, kullanıcıların günlük fiziksel aktivitelerini takip etmelerine, yürüyüş seanslarını kaydetmelerine, kişisel adım hedefleri belirlemelerine ve ilerlemelerini sade ve kullanımı kolay bir arayüz üzerinden incelemelerine yardımcı olur.

StepPulse, akıllı saat veya ek giyilebilir cihaz gerektirmeden erişilebilir bir yürüyüş deneyimi sunmaya odaklanır.

## Özellikler

### Adım Takibi
- Günlük adım sayısı takibi
- Özelleştirilebilir günlük adım hedefleri
- Görsel hedef ilerleme göstergesi
- Tahmini kalori ve mesafe bilgisi
- Desteklenen cihaz sağlık verileriyle entegrasyon

### Yürüyüş Aktivitesi
- GPS tabanlı yürüyüş seansı takibi
- Etkileşimli harita üzerinde yürüyüş rotası görselleştirme
- Yürüyüş seanslarını başlatma ve durdurma
- Yürüyüş süresi ve mesafe takibi
- Yürüyüş aktivite geçmişi

### Aktivite İstatistikleri
- Günlük aktivite özeti
- Haftalık aktivite istatistikleri
- Aylık aktivite istatistikleri
- Geçmiş adım verilerinin görselleştirilmesi

### Kişisel Profil
- Kişisel bilgi yönetimi
- Boy, kilo ve yaş bilgileri
- Özel günlük adım hedefleri
- Uygulama tercihleri

### Bildirimler
- Günlük yürüyüş hatırlatıcıları
- Yapılandırılabilir hatırlatma saatleri
- Günlük adım hedefi tamamlama bildirimleri
- Bildirim izni yönetimi

### Görünüm
- Açık ve koyu tema desteği
- Özel uygulama ikonu ve açılış ekranı (splash screen)
- Duyarlı (responsive) Flutter arayüzü

## Teknoloji Yığını

| Teknoloji | Amaç |
|---|---|
| Flutter & Dart | Çapraz platformlu mobil geliştirme |
| Drift (SQLite) | Yerel veri saklama |
| Health | HealthKit ve Health Connect entegrasyonu |
| Pedometer | Cihaz adım sensörü entegrasyonu |
| Geolocator | GPS konum takibi |
| Flutter Map | Etkileşimli harita görselleştirme |
| GoRouter | Navigasyon ve yönlendirme |
| SharedPreferences | Kullanıcı ayarları ve tercihleri |
| Flutter Local Notifications | Yerel bildirimler |
| Timezone | Saat dilimine duyarlı zamanlama |

## Mimari

StepPulse, sorumlulukların ayrıldığı modüler bir Flutter proje yapısını takip eder.

```text
lib/
├── core/
├── routes/
├── screens/
├── widgets/
├── models/
├── repositories/
├── services/
└── main.dart
```

Uygulama; kullanıcı arayüzü bileşenlerini, navigasyonu, veri erişimini ve platforma özgü servisleri birbirinden ayırarak sürdürülebilirliği ve okunabilirliği artırır.

### Veri Yönetimi

StepPulse, adım takibi için hibrit bir yaklaşım kullanır:

- Cihaz sensörleri, desteklendiği durumlarda adım bilgisi sağlar.
- Platform sağlık servisleri, mevcut geçmiş aktivite verilerine erişim sağlar.
- Drift, yerel uygulama verilerini yönetir.
- SharedPreferences, hafif tercihleri ve ayarları saklar.

Sağlık verilerinin kullanılabilirliği; cihaz desteğine, izinlere ve platform kısıtlamalarına bağlıdır.

## Başlarken

### Gereksinimler

- Flutter SDK
- Dart SDK
- Android Studio veya Visual Studio Code
- iOS geliştirme için Xcode
- Android emülatörü veya fiziksel cihaz / iOS simülatörü veya fiziksel iPhone

### Kurulum

Depoyu klonlayın:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
cd YOUR_REPOSITORY
```

Bağımlılıkları yükleyin:

```bash
flutter pub get
```

Gerekli dosyaları oluşturun:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Uygulamayı çalıştırın:

```bash
flutter run
```

Bağlı bir iPhone üzerinde release derlemesi için:

```bash
flutter run --release
```

## İzinler

Platforma ve etkinleştirilen özelliklere bağlı olarak StepPulse şu izinleri isteyebilir:

- Fiziksel aktivite veya hareket izinleri
- Yürüyüş rotaları için konum izinleri
- Sağlık verisi okuma izinleri
- Bildirim izinleri

Sağlık servisi entegrasyonu, desteklenen yerlerde isteğe bağlıdır. Bazı işlevler izinlerin kullanılabilirliğine bağlı olabilir.

## Proje Durumu

StepPulse şu anda aktif geliştirme aşamasındadır.

### Planlanan İyileştirmeler

- Kişiselleştirilmiş adım hedefi önerileri
- Daha ayrıntılı aktivite içgörüleri
- Geliştirilmiş yürüyüş alışkanlığı takibi
- Ek aktivite ilerleme özetleri
- Gelişmiş arka plan aktivite yönetimi

## Platform Desteği

| Platform | Hedef |
|---|---|
| Android | Desteklenen geliştirme hedefi |
| iOS | Desteklenen geliştirme hedefi |
| Web | Hedeflenmiyor |
| macOS | Üretim için hedeflenmiyor |

## Lisans

Bu proje için herhangi bir açık kaynak lisansı belirtilmemiştir.

---

Flutter ve Dart ile geliştirilmiştir.
