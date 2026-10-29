# Event Discovery App (Etkinlik Keşif Uygulaması) 🎟️✨
![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white)
![State Management](https://img.shields.io/badge/State_Management-Provider-7F52FF)
![Architecture](https://img.shields.io/badge/Architecture-Feature--First-2EA44F)
![Tests](https://img.shields.io/badge/Tests-48_Passing-brightgreen)

MOBILAB Task API kullanılarak geliştirilmiş; üniversite ve topluluk etkinliklerini keşfetmeyi, aramayı, kategorilere göre filtrelemeyi, detaylarını incelemeyi ve çevrimdışı (offline) kalıcı olarak favorilere eklemeyi sağlayan modern bir Flutter mobil uygulaması.

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- **Flutter SDK**: 3.24+ (Dart 3.5+)
- **Hedef Platform**: Android / iOS cihaz, emülatör veya masaüstü ortamı

### Adımlar
```bash
# 1. Projeyi klonlayın ve proje dizinine gidin
git clone <repo-url>
cd etkinlik_kesif_uygulamasi

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Statik kod analizini çalıştırın
flutter analyze

# 4. Birim ve widget testlerini çalıştırın (48 test)
flutter test

# 5. Uygulamayı başlatın
flutter run
```

---

## 🎨 Tasarım Sistemi ve UI/UX Yaklaşımı

Uygulama, modern etkinlik keşif arayüzlerinden ilham alan özel bir tasarım sistemiyle geliştirilmiştir:

- **Birincil Koyu Tema (Dark Theme)**: Derin mor-siyah arka plan (`#14111F`), katmanlı kart yüzeyleri (`#1E1A2B` / `#272238`), yüksek kontrastlı nane/limon yeşili birincil vurgu (`#C5F5A3`) ve pastel mor ikincil vurgu (`#8B6FD1`).
- **Uyarlanabilir Açık Tema (Light Theme)**: Lavanta-beyaz arka plan (`#F6F5FA`), saf beyaz kart yüzeyleri (`#FFFFFF`) ve `SharedPreferences` ile kalıcı olarak saklanan tek dokunuşlu tema değiştirme butonu.
- **Tipografi**: `google_fonts` üzerinden **Plus Jakarta Sans** yazı ailesi ve merkezi `AppTypography` hiyerarşisi.
- **Yüzen Alt Navigasyon Çubuğu (`FloatingNavBar`)**: Koyu hap (pill) formunda, aktif sekmesi nane yeşili daireyle vurgulanan ve favori sayısını dinamik rozet (badge) olarak gösteren özel alt bar.
- **İkili Keşif Yerleşimi**: Ana ekranda yatay kaydırılabilir **"Öne Çıkanlar"** (`FeaturedEventCard`) karuseli ve altında sonsuz kaydırma (infinite scroll) destekli **"Tüm Etkinlikler"** (`EventListTile`) listesi.

---

## 📁 Mimari ve Klasör Yapısı (Feature-Based Architecture)

Proje; genişletilebilir, bakımı kolay ve modüler **Özellik ve Katman Tabanlı (Feature-Based Architecture)** bir yaklaşımla organize edilmiştir:

```
lib/
├── core/                         # Uygulama genelinde paylaşılan çekirdek altyapı
│   ├── constants/                # API adresleri ve uç noktalar (api_endpoints.dart)
│   ├── network/                  # HTTP istemcisi (timeout, auto-retry) ve hata hiyerarşisi
│   ├── theme/                    # AppColors, AppTypography, AppTheme (Dark/Light), ThemeProvider
│   └── utils/                    # intl Türkçe tarih/saat formatlayıcıları (date_formatter.dart)
│
├── features/                     # Özellik modülleri
│   ├── events/                   # Etkinlikler modülü
│   │   ├── data/
│   │   │   ├── models/           # EventModel, EventListResponse (null-safe)
│   │   │   └── repositories/     # EventRepository
│   │   └── presentation/
│   │       ├── providers/        # EventListProvider (pagination, debounce, stale guard), EventDetailProvider
│   │       ├── screens/          # EventListScreen, EventDetailScreen, MainNavigationScreen
│   │       └── widgets/          # FeaturedEventCard, EventListTile, CategoryChips, SearchField,
│   │                             # EventSkeletonView (pure Flutter shimmer), StateViews
│   │
│   └── favorites/                # Favoriler modülü
│       ├── data/                 # FavoritesLocalStorage (Offline JSON persistence)
│       └── presentation/
│           ├── providers/        # FavoritesProvider
│           └── screens/          # FavoritesScreen
│
├── shared/                       # Ortak kullanılan arayüz bileşenleri
│   └── widgets/                  # FloatingNavBar, EventNetworkImage, AnimatedFavoriteButton
└── main.dart                     # MultiProvider ve uygulama başlangıç noktası
```

### Neden Bu Mimari Seçildi?
- **Sorumlulukların Ayrılması (Separation of Concerns)**: Arayüz (UI), durum yönetimi (`ChangeNotifier` Provider'lar) ve veri kaynakları (`EventRepository`, `FavoritesLocalStorage`, `ApiClient`) birbirinden tamamen bağımsızdır.
- **Yeniden Kullanılabilirlik (Reusability)**: Kartlar, kategori çipleri, görsel yükleyici (`EventNetworkImage`), animasyonlu kalp butonu (`AnimatedFavoriteButton`) ve durum ekranları (`EventSkeletonView`, `ErrorView`, `EmptyView`) modüler bileşenler olarak tasarlanmıştır.
- **Test Edilebilirlik (Testability)**: Tüm bağımlılıklar yapıcı metot (constructor injection) üzerinden enjekte edildiği için sahte servislerle (Mock/Fake) %100 izole şekilde test edilebilir.

---

## 🛠️ Teknoloji Tercihleri ve Gerekçeleri

### 1. Durum Yönetimi: **Provider**
- Flutter ekibinin resmi olarak önerdiği, yalın ve öngörülebilir durum yönetimidir.
- `ChangeNotifier` ve `Consumer` yapısı sayesinde yalnızca ilgili alt bileşenlerin yeniden çizilmesini sağlar.
- `build_runner` veya kod üretimi (codegen) gerektirmez; derleme süresini hızlandırır ve mimariyi sade tutar.

### 2. Yerel Depolama: **shared_preferences (Tam JSON Serileştirme)**
- Sadece etkinlik ID'leri yerine etkinliğin tam özet JSON nesnesi (`EventModel.toJson()` / `fromJson()`) yerel hafızada saklanır.
- Bu sayede **Favoriler ekranı internetsiz (offline) ortamda veya API sunucusu hata verdiğinde bile anında ve eksiksiz çalışır**.
- Bozuk (corrupted) JSON kayıtlarına karşı savunmacı ayrıştırma içerir; hatalı kayıtları atlayarak uygulamanın açılışta çökmesini engeller.

### 3. Ağ İstemcisi: **http + Otomatik Retry & Timeout Sarmalayıcısı**
- API'ye yapılan her istekte **10 saniyelik zaman aşımı (`timeoutDuration`)** uygulanır.
- Sunucunun rastgele döndüğü **HTTP 500** hatalarında ve zaman aşımlarında kullanıcıya hata göstermeden önce **2 kez otomatik yeniden deneme (auto-retry)** yapılır.

---

## 🌟 Öne Çıkan ve Bonus Özellikler

1. **Sonsuz Kaydırma ile Sayfalama (Infinite Scroll Pagination)**:
   - Etkinlikler `page` ve `limit=6` parametreleriyle parçalı olarak çekilir.
   - Kullanıcı listenin sonuna yaklaştığında (`ScrollNotification`) sonraki sayfa otomatik yüklenir.
   - Sonraki sayfalar yüklenirken hata oluşursa mevcut liste korunur ve listenin en altında izole bir **"Tekrar Dene"** çubuğu gösterilir.
2. **Anlamlı Animasyonlar (Meaningful Animations)**:
   - **Çakışmasız `Hero` Geçişleri**: Öne çıkanlar karuseli, tüm etkinlikler listesi, filtrelenmiş liste ve favoriler listesindeki kartlara benzersiz `heroTag` önekleri atanarak detay ekranına pürüzsüz görsel geçiş animasyonu sağlandı.
   - **`AnimatedFavoriteButton`**: Kalp ikonuna dokunulduğunda `AnimatedSwitcher` + `ScaleTransition` (`Curves.easeOutBack`) ile yaylanan ölçek animasyonu.
   - **Saf Flutter Shimmer (`EventSkeletonView`)**: Harici paket kullanmadan `AnimationController` ve `Color.lerp` ile ana ekran yerleşimini birebir yansıtan iskelet yükleme ekranı.
   - **`AnimatedSize` & Giriş Animasyonları**: Detay ekranında "Daha Fazla Göster" metin genişlemesi ve liste kartlarının yumuşak giriş animasyonu.
3. **Açık / Koyu Tema Desteği (Light & Dark Mode Toggle)**:
   - Ana ekran başlığındaki tema butonu ile Koyu ve Açık tema arasında anında geçiş ve `SharedPreferences` ile kalıcılık.
4. **GitHub Actions CI (`.github/workflows/ci.yml`)**:
   - Her `push` ve `pull_request` işleminde otomatik olarak `flutter pub get`, `flutter analyze` ve `flutter test` adımlarını koşturan CI iş akışı.

---

## 🛡️ Ele Alınan Uç Durumlar (Edge Cases)

- **API Yavaşlığı ve Gecikmeler**: Ağ istekleri `timeout` ile sınırlandırıldı; yükleme sırasında `EventSkeletonView` gösterilir.
- **Geçici Sunucu Hataları (500)**: Otomatik 2 tekrar denemeden sonra başarısız olursa kullanıcıya anlaşılır Türkçe mesaj ve **"Tekrar Dene"** butonu sunulur.
- **Stale Response Koruması**: Hızlı arama veya kategori değişiminde geciken eski ağ yanıtlarının yeni sonuçları ezmesi `_latestRequestId` sıra sayacı ile engellenmiştir.
- **İzole Detay Ekranı Hata Yönetimi**: Liste ekranından gelen etkinlik verisi detay ekranında **anında** çizilir; yalnızca `/events/{id}` açıklama çağrısı başarısız olursa sadece açıklama bölümünde tekrar deneme butonu gösterilir, ekranın geri kalanı bozulmaz.
- **Search Debounce**: Arama kutusuna hızlı yazıldığında sunucuya her tuş vuruşunda istek gitmesi **400 ms debounce** ile engellenmiştir.
- **Null Safety ve Eksik Görseller**: API'den gelebilecek `null`/boş `imageUrl`, `location`, `organizer`, `tags`, `capacity` değerleri güvenli varsayılanlarla ve `EventNetworkImage` gradyan yedek görünümüyle karşılanır.
- **Küçük Ekran (320×568) Taşma Koruması**: Çok uzun etkinlik başlıkları, kategori isimleri ve konum metinleri `Expanded`/`Flexible`, `Wrap` ve `TextOverflow.ellipsis` ile korunmuş ve 320 piksel genişlikte widget testleriyle doğrulanmıştır.

---

## 🧪 Test Kapsamı (48 Test - %100 Başarı)

| Modül / Katman | Test Dosyası | Kapsanan Durumlar |
| :--- | :--- | :--- |
| **Model** | `test/unit/event_model_test.dart` | Tam JSON parse, null/eksik alan toleransı, JSON serileştirme/kalıcılık, `copyWith` |
| **Tarih Formatı** | `test/unit/date_formatter_test.dart` | `intl` Türkçe ay ve gün isimleri, saat aralığı, timezone normalizasyonu |
| **Repository** | `test/unit/event_repository_test.dart` | Kategori listeleme, sorgu parametreleri, detay getirme, hata fırlatma |
| **Liste State** | `test/unit/event_list_provider_test.dart` | Yükleniyor, başarı, hata, boş liste, stale response koruması, debounce, sayfalama (`loadMoreEvents`) ve izole sayfa 2 hatası |
| **Detay State** | `test/unit/event_detail_provider_test.dart` | İlk veriyi koruma, izole açıklama yükleme, retry, metin açma/kapatma |
| **Depolama** | `test/unit/favorites_storage_test.dart` | Kalıcı JSON saklama, okuma, silme, bozuk JSON atlama |
| **Favori State** | `test/unit/favorites_provider_test.dart` | Favori açıp kapatma, sayaç kontrolü, varlık sorgusu |
| **Tema & Tasarım** | `test/unit/app_theme_test.dart` | `AppColors` tokenları, `AppTypography`, `darkTheme`, `lightTheme`, `ThemeProvider` kalıcılığı |
| **Liste UI** | `test/widget/event_list_screen_test.dart` | Hata ekranı ve retry butonu tıklaması, arama ve kategori çipleri |
| **Detay UI** | `test/widget/event_detail_screen_test.dart` | Anında çizim, izole hata kutusu ve retry butonu |
| **Favori UI** | `test/widget/favorites_screen_test.dart` | Boş durum ekranı, favori kartı çizimi ve kalp tıklamasıyla kaldırma |
| **UI Cilası & 320px** | `test/widget/ui_polish_test.dart` | `EventSkeletonView`, `EventNetworkImage` fallback, `AnimatedFavoriteButton`, 320×568 küçük ekranda uzun metin taşma (`overflow`) kontrolü |
