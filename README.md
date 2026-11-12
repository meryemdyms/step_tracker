
# StepPulse – Adım Takip ve Yürüyüş Uygulaması

StepPulse, Flutter ve Dart kullanılarak Android ve iOS platformları için geliştirilen bir adım takip ve yürüyüş aktivitesi uygulamasıdır.

Uygulama; kullanıcıların günlük adım sayılarını takip etmelerini, yürüyüş aktivitelerini kaydetmelerini, kişisel hedefler oluşturmalarını ve fiziksel aktivite geçmişlerini incelemelerini sağlar.

StepPulse'ın temel amacı, ek bir akıllı saat veya giyilebilir cihaz zorunluluğu olmadan, kullanıcıların günlük hareket alışkanlıklarını geliştirmelerine yardımcı olmaktır.

## Projenin Amacı

Günlük fiziksel aktiviteyi takip etmek, sağlıklı yaşam alışkanlıkları oluşturmanın önemli adımlarından biridir.

StepPulse, günlük adım takibi ile aktif yürüyüş kaydını tek uygulamada birleştirir.

Uygulama iki temel kullanım senaryosuna odaklanır:

1. Pasif takip: Kullanıcı, günlük adım ve aktivite verilerini uygulama üzerinden görüntüler.
2. Aktif yürüyüş: Kullanıcı bir yürüyüş seansı başlatarak GPS üzerinden rotasını, yürüyüş süresini ve mesafesini takip eder.

GPS yalnızca konum gerektiren yürüyüş ve rota özelliklerinde kullanılır. Günlük adım sayısının temel kaynağı GPS değildir.

## Özellikler

### 1. Günlük Adım Takibi

- Günlük adım sayısını görüntüleme
- Kişiselleştirilebilir günlük adım hedefi
- Hedef ilerlemesini görsel olarak takip etme
- Tahmini kalori hesaplama
- Tahmini yürüyüş mesafesi
- Cihaz sensörleri ve desteklenen sağlık servislerinden veri okuma

### 2. Aktif Yürüyüş Takibi

- Yürüyüş seansı başlatma ve durdurma
- GPS ile konum takibi
- Harita üzerinde yürüyüş rotasını görüntüleme
- Yürüyüş süresini takip etme
- Kat edilen mesafeyi hesaplama
- Geçmiş yürüyüş aktivitelerini inceleme

### 3. Aktivite İstatistikleri

- Günlük aktivite özeti
- Haftalık adım istatistikleri
- Aylık aktivite istatistikleri
- Geçmiş aktivite verilerini görüntüleme
- Aktivite ilerlemesini grafiklerle inceleme

### 4. Kullanıcı Profili

- Kullanıcı bilgilerini kaydetme
- Yaş, boy, kilo ve cinsiyet bilgileri
- Günlük adım hedefi belirleme
- Profil bilgilerini güncelleme
- Uygulama tercihlerini yönetme

Kullanıcı profili, kişiselleştirilmiş aktivite verilerinin ve tahmini kalori hesaplamalarının oluşturulmasında kullanılır.

### 5. Bildirim Sistemi

- Günlük yürüyüş hatırlatıcıları
- Hatırlatma saatlerini ayarlama
- Adım hedefi tamamlama bildirimleri
- Bildirim izinlerini yönetme
- Yerel bildirim desteği

### 6. Kullanıcı Arayüzü

- Açık tema
- Koyu tema
- Özel uygulama logosu
- Splash ekranı
- Onboarding ekranı
- Kullanıcı bilgi alma ekranı
- Ana sayfa
- Yürüyüş ekranı
- Harita ekranı
- İstatistik ekranı
- Profil ve ayarlar ekranları

## Kullanılan Teknolojiler

| Teknoloji | Kullanım Amacı |
|---|---|
| Flutter | Çapraz platformlu mobil uygulama geliştirme |
| Dart | Uygulama programlama dili |
| Drift | SQLite tabanlı yerel veritabanı |
| Health | Apple HealthKit ve Android Health Connect |
| Pedometer | Cihaz adım sensörlerinden veri okuma |
| Geolocator | GPS ve konum servisleri |
| Flutter Map | Harita ve rota görselleştirme |
| LatLong2 | Coğrafi koordinat işlemleri |
| GoRouter | Ekranlar arası navigasyon |
| SharedPreferences | Yerel kullanıcı tercihleri |
| Flutter Local Notifications | Yerel bildirim yönetimi |
| Flutter Timezone | Saat dilimi işlemleri |
| Build Runner | Kod üretimi |

lib/
├── core/
│   └── Uygulama genelinde kullanılan ortak yapılar
│
├── routes/
│   └── Sayfa yönlendirmeleri
│
├── screens/
│   └── Kullanıcı arayüzü ekranları
│
├── widgets/
│   └── Yeniden kullanılabilir arayüz bileşenleri
│
├── models/
│   └── Veri modelleri
│
├── repositories/
│   └── Veri erişim katmanı
│
├── services/
│   └── Sensör, sağlık, GPS ve bildirim servisleri
│
└── main.dart
    └── Uygulama başlangıç noktası

## Adım Takibi ve Veri Yönetimi

StepPulse, cihaz sensörleri ile platform sağlık servislerini birlikte değerlendiren hibrit bir veri yönetimi yaklaşımına sahiptir.

### 1. Cihaz Sensörleri

Desteklenen cihazlarda pedometre sensörlerinden adım verileri alınabilir.

### 2. Sağlık Servisleri

Platforma göre aşağıdaki servislerle entegrasyon hedeflenmektedir:

- iOS: Apple HealthKit
- Android: Health Connect

Bu servisler aracılığıyla, gerekli izinler verildiğinde geçmiş aktivite kayıtlarına erişilebilir.

### 3. Yerel Veritabanı

Drift kullanılarak uygulamaya ait yapılandırılmış veriler cihaz üzerinde saklanabilir.

SQLite tabanlı bu yaklaşım, yerel veri sorgulama ve yönetimini destekler.

### 4. Kullanıcı Tercihleri

SharedPreferences üzerinden aşağıdaki gibi hafif ayarlar saklanabilir:

- Tema tercihi
- Günlük adım hedefi
- Bildirim tercihleri
- Uygulama ayarları

Veri erişimi; cihaz desteğine, kullanıcı izinlerine, işletim sistemi kısıtlamalarına ve ilgili servislerin kullanılabilirliğine bağlıdır.

## Yürüyüş ve GPS Yönetimi

StepPulse, günlük adım takibi ile GPS tabanlı yürüyüş kaydını birbirinden ayırır.

Günlük adım takibi için sürekli GPS kullanılması hedeflenmez.

GPS aşağıdaki işlemlerde kullanılır:

- Aktif yürüyüş sırasında konum alma
- Yürüyüş rotasını oluşturma
- Harita üzerinde konumları gösterme
- GPS noktalarından yürüyüş mesafesi hesaplama

Bu ayrım, gereksiz konum kullanımını azaltmayı ve pil tüketimini daha kontrollü yönetmeyi amaçlar.

## Kurulum

### Gereksinimler

- Flutter SDK
- Dart SDK
- Android Studio veya Visual Studio Code
- Git
- Android Emulator veya fiziksel Android cihaz
- iOS için macOS ve Xcode

### 1. Projeyi Klonlayın

```bash
git clone https://github.com/meryemdyms/step_tracker.git
```

### 2. Proje Klasörüne Geçin

```bash
cd step_tracker
```

### 3. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 4. Gerekli Kodları Oluşturun

Drift tarafından kullanılan üretilmiş dosyalar için:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Bağlı Cihazları Listeleyin

```bash
flutter devices
```

### 6. Uygulamayı Başlatın

```bash
flutter run
```

### iOS Üzerinde Çalıştırma

iOS bağımlılıklarının kurulması gerekiyorsa:

```bash
cd ios
pod install
cd ..
```

Ardından:

```bash
flutter run
```

Fiziksel iPhone üzerinde çalıştırmak için Xcode üzerinden uygun geliştirme ekibi ve kod imzalama ayarları yapılandırılmalıdır.

## Uygulama İzinleri

StepPulse, kullanılan özelliklere göre işletim sisteminden belirli izinler talep edebilir.

| İzin | Kullanım Amacı |
|---|---|
| Fiziksel aktivite | Adım sensörü verileri |
| Sağlık verileri | Geçmiş aktivite kayıtları |
| Konum | GPS tabanlı yürüyüş takibi |
| Bildirim | Hatırlatıcılar ve hedef bildirimleri |

İzinler, ilgili özelliklerin kullanılabilmesi için gerektiğinde talep edilir.

## Tema Yönetimi

StepPulse, açık ve koyu tema desteği sunacak şekilde tasarlanmıştır.

Tema sistemi, uygulamanın farklı ekranlarında ortak renk ve stil kullanımını destekler.

Bu yaklaşım sayesinde kullanıcı arayüzünün tutarlı ve sürdürülebilir olması hedeflenir.

## Proje Durumu

StepPulse aktif geliştirme aşamasındadır.

Mevcut geliştirme kapsamı:

- Flutter proje altyapısı
- Uygulama klasör mimarisi
- Ekran ve navigasyon yapısı
- Splash ve onboarding tasarımı
- Kullanıcı profili
- Açık ve koyu tema
- Drift veritabanı altyapısı
- Adım ve sağlık verisi entegrasyonu
- Yürüyüş ve harita modülleri
- Bildirim yönetimi

Özelliklerin platformlar üzerindeki davranışları cihaz desteğine ve geliştirme durumuna göre değişebilir.

## Planlanan Geliştirmeler

- Adım verilerinin daha tutarlı senkronizasyonu
- Arka planda aktivite takibinin iyileştirilmesi
- Daha ayrıntılı haftalık ve aylık analizler
- Kişiselleştirilmiş aktivite hedefleri
- Yürüyüş geçmişinin geliştirilmesi
- Pil tüketimi optimizasyonu
- Kapsamlı uygulama testleri
- Kullanıcı deneyimi iyileştirmeleri

## Platform Desteği

| Platform | Durum |
|---|---|
| Android | Hedef platform |
| iOS | Hedef platform |
| Web | Hedeflenmiyor |
| macOS | Üretim hedefi değil |

## Önemli Notlar

- Kalori değerleri tahminidir.
- Mesafe hesaplamaları kullanılan veri kaynağına göre değişebilir.
- Sensör ve sağlık verileri cihazdan cihaza farklılık gösterebilir.
- GPS doğruluğu çevresel koşullardan etkilenebilir.
- StepPulse tıbbi teşhis veya tedavi amacıyla geliştirilmemiştir.

## Lisans

Proje için henüz açık kaynak lisansı tanımlanmamıştır.

---

StepPulse – Her Adımda İlerle

Flutter ve Dart ile geliştirilmiştir.
