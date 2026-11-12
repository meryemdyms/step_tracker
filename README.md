
# StepPulse – Adım Takip ve Yürüyüş Uygulaması

StepPulse, Flutter ve Dart kullanılarak Android ve iOS platformları için geliştirilen, günlük adım takibi ve yürüyüş aktivitelerini tek platformda birleştiren bir mobil uygulamadır.

Uygulama; kullanıcıların günlük adım sayılarını takip etmelerini, yürüyüş aktivitelerini kaydetmelerini, kişisel hedefler belirlemelerini ve fiziksel aktivite geçmişlerini incelemelerini sağlar.

StepPulse'ın temel amacı, ek bir akıllı saat veya giyilebilir cihaz zorunluluğu olmadan kullanıcıların günlük hareket alışkanlıklarını geliştirmelerine yardımcı olmaktır.

## Projenin Amacı

Günlük fiziksel aktiviteyi takip etmek, sağlıklı yaşam alışkanlıkları oluşturmanın önemli adımlarından biridir.

StepPulse, günlük adım takibi ile aktif yürüyüş kaydını tek bir uygulamada birleştirir.

Uygulama iki temel kullanım senaryosuna odaklanır:

1. **Pasif takip:** Kullanıcı, günlük adım ve aktivite verilerini uygulama üzerinden görüntüler.
2. **Aktif yürüyüş:** Kullanıcı bir yürüyüş seansı başlatarak GPS üzerinden rotasını, yürüyüş süresini ve mesafesini takip eder.

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

- Açık ve koyu tema desteği
- Özel uygulama logosu ve ikonu
- Splash ekranı
- Onboarding ekranı
- Kullanıcı bilgi alma ekranı
- Ana sayfa
- Yürüyüş ekranı
- Harita ekranı
- İstatistik ekranı
- Aktivite geçmişi ekranı
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

## Proje Mimarisi

StepPulse, **Feature-First (Özellik Odaklı Mimari)** yaklaşımını benimser.

Bu mimaride uygulama genelinde kullanılan ortak altyapı bileşenleri `core/` klasöründe, belirli bir işleve ait ekranlar ve bileşenler ise `features/` klasöründe organize edilir.

Bu yaklaşım, uygulamanın modüler, okunabilir, sürdürülebilir ve genişletilebilir olmasını hedefler.

### Klasör Yapısı

```text
lib/
├── core/
│   ├── constants/       # Uygulama genelindeki sabit değerler
│   ├── database/        # Drift ve yerel veritabanı işlemleri
│   ├── router/          # GoRouter ile sayfa yönlendirmeleri
│   ├── services/        # Sensör, sağlık, GPS ve bildirim servisleri
│   ├── theme/           # Açık/koyu tema ve renk tanımları
│   ├── utils/           # Yardımcı fonksiyonlar
│   └── widgets/         # Ortak ve yeniden kullanılabilir bileşenler
│
├── features/
│   ├── history/         # Geçmiş yürüyüş ve aktivite kayıtları
│   ├── home/
│   │   ├── screens/     # Ana sayfa ekranları
│   │   └── widgets/     # Ana sayfaya özel bileşenler
│   ├── onboarding/      # İlk açılış ve kullanıcı karşılama
│   ├── profile/         # Kullanıcı profili ve kişisel ayarlar
│   ├── statistics/      # Günlük, haftalık ve aylık istatistikler
│   └── walking/         # Aktif yürüyüş, GPS ve rota takibi
│
└── main.dart            # Uygulamanın başlangıç noktası
```

### 1. Core – Ortak Altyapı

`core/` klasörü, uygulamanın birden fazla özelliği tarafından kullanılan ortak yapıları içerir.

- `constants/`: Uygulama genelinde kullanılan sabit değerler.
- `database/`: Drift ile SQLite veritabanı yönetimi.
- `router/`: GoRouter aracılığıyla ekranlar arası navigasyon.
- `services/`: Sensör, sağlık verileri, GPS ve bildirim servisleri.
- `theme/`: Açık ve koyu tema yapılandırmaları.
- `utils/`: Ortak yardımcı fonksiyonlar.
- `widgets/`: Birden fazla ekranda kullanılabilen arayüz bileşenleri.

### 2. Features – Özellik Modülleri

`features/` klasörü, uygulamanın kullanıcıya sunduğu işlevleri birbirinden ayırır.

| Modül | Sorumluluk |
|---|---|
| `home/` | Günlük adım, kalori, mesafe ve hedef bilgileri |
| `walking/` | Aktif yürüyüş, GPS ve rota takibi |
| `history/` | Geçmiş yürüyüş ve aktivite kayıtları |
| `statistics/` | Günlük, haftalık ve aylık istatistikler |
| `profile/` | Kullanıcı profili ve kişisel tercihler |
| `onboarding/` | İlk kullanım ve kullanıcı bilgilendirme akışı |

Her özellik kendi ekranlarını ve yalnızca o özelliğe ait arayüz bileşenlerini barındırabilir.

### Neden Feature-First?

Bu mimarinin tercih edilmesinin temel nedenleri:

- Her özelliğin kendi klasöründe geliştirilebilmesi
- Proje büyüdükçe dosya yönetiminin kolaylaşması
- Bir özelliğe ait dosyaların birlikte tutulması
- Ortak bileşenlerin tekrar kullanılabilmesi
- Kodun okunabilirliğinin artırılması
- Yeni özelliklerin daha kolay eklenebilmesi
- Test ve bakım süreçlerinin kolaylaştırılması

Feature-First yaklaşımı, gereksiz mimari katmanlar oluşturmadan uygulamanın büyümesini destekler.

## Adım Takibi ve Veri Yönetimi

StepPulse, cihaz sensörleri ile platform sağlık servislerini birlikte değerlendiren hibrit bir veri yönetimi yaklaşımını hedefler.

### 1. Cihaz Sensörleri

Desteklenen cihazlarda pedometre sensörlerinden adım verileri alınabilir.

Bu yaklaşım, ek bir akıllı saat veya giyilebilir cihaz olmadan adım takibini destekler.

### 2. Sağlık Servisleri

Platforma göre aşağıdaki servislerle entegrasyon hedeflenmektedir:

- **iOS:** Apple HealthKit
- **Android:** Health Connect

Bu servisler aracılığıyla, gerekli izinler verildiğinde mevcut ve geçmiş aktivite kayıtlarına erişilebilir.

Sağlık verilerinin kullanılabilirliği, işletim sistemi ve cihaz özelliklerine bağlıdır.

### 3. Yerel Veritabanı

Drift kullanılarak uygulamaya ait yapılandırılmış veriler cihaz üzerinde saklanabilir.

SQLite tabanlı bu yaklaşım:

- Yerel veri yönetimini
- Aktivite kayıtlarının saklanmasını
- Geçmiş verilerin sorgulanmasını
- İnternet bağlantısı gerektirmeyen yerel veri işlemlerini

destekler.

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
- iOS geliştirme için macOS ve Xcode

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

Tema yapılandırmaları `core/theme/` altında merkezi olarak yönetilir.

Bu yaklaşım sayesinde:

- Uygulama genelinde ortak renk sistemi kullanılır.
- Ekranlar arasında görsel tutarlılık sağlanır.
- Tema değişiklikleri merkezi olarak yönetilebilir.
- Kullanıcı deneyimi farklı görünüm tercihlerine uyarlanabilir.

## Proje Durumu

StepPulse aktif geliştirme aşamasındadır.

### Mevcut Geliştirme Kapsamı

- Flutter proje altyapısı
- Feature-First klasör mimarisi
- GoRouter ile navigasyon altyapısı
- Splash ve onboarding tasarımı
- Kullanıcı profili
- Açık ve koyu tema
- Drift veritabanı altyapısı
- Adım ve sağlık verisi entegrasyonu
- Yürüyüş ve harita modülleri
- Aktivite geçmişi ve istatistik ekranları
- Bildirim yönetimi

Özelliklerin platformlar üzerindeki davranışları cihaz desteğine, izinlere ve geliştirme durumuna göre değişebilir.

## Planlanan Geliştirmeler

- Adım verilerinin daha tutarlı senkronizasyonu
- Arka planda aktivite takibinin iyileştirilmesi
- Daha ayrıntılı haftalık ve aylık analizler
- Kişiselleştirilmiş aktivite hedefleri
- Yürüyüş geçmişinin geliştirilmesi
- Pil tüketimi optimizasyonu
- Unit ve Widget testleri
- Performans iyileştirmeleri
- Kullanıcı deneyimi geliştirmeleri

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
- Bazı özellikler kullanıcı izinlerine bağlıdır.
- StepPulse tıbbi teşhis veya tedavi amacıyla geliştirilmemiştir.

## Lisans

Proje için henüz açık kaynak lisansı tanımlanmamıştır.

---

StepPulse – Her Adımda İlerle

Flutter ve Dart ile geliştirilmiştir.
