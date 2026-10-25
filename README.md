# Event Discovery App (Etkinlik Keşif Uygulaması) 🎟️✨

MOBILAB Task API (`https://mobilab-task-api.vercel.app`) kullanılarak geliştirilmiş, üniversite ve topluluk etkinliklerini keşfetmeyi, aramayı, kategorilere göre süzmeyi, detaylarını incelemeyi ve çevrimdışı (offline) kalıcı olarak favorilere eklemeyi sağlayan modern bir Flutter mobil uygulaması.

> [!NOTE]  
> Bu uygulama bir bilet satış veya ödeme uygulaması **değildir**. Fiyat, sepet veya bilet satın alma öğeleri içermez; etkinlikleri duyurma, sergileme, inceleme ve kişisel favori listesi oluşturma amacıyla tasarlanmıştır.

---

## 🚀 Başlangıç ve Çalıştırma

### Gereksinimler
- **Flutter SDK**: 3.24+ / 3.47.x (Dart 3.5+)
- **Platform**: Android / iOS cihaz, emülatör veya masaüstü hedefi

### Komutlar
```bash
# 1. Bağımlılıkları yükleyin
flutter pub get

# 2. Kod analizi yapın (0 hata / 0 uyarı)
dart analyze .

# 3. Tüm birim ve widget testlerini koşturun (48 test)
flutter test

# 4. Uygulamayı başlatın
flutter run
```

> [!TIP]  
> Windows işletim sisteminde Türkçe karakter içeren dosya yollarında (`Masaüstü` vb.) Flutter LSP'sinin UTF-8 byte stream kısıtlamasına takılmamak için yerel ortamda doğrudan CLI tabanlı `dart analyze .` komutu tercih edilmiştir. GitHub Actions CI ortamında (`ubuntu-latest`) standart `flutter analyze` otomatik çalışmaktadır.

---

## 🎨 Tasarım Sistemi ve UI/UX Yaklaşımı

Uygulama, modern etkinlik keşif arayüzlerinden (Dribbble referansı) ilham alan özel bir tasarım diliyle geliştirilmiştir:

- **Birincil Koyu Tema (Dark Theme)**: Derin mor-siyah arka plan (`#14111F`), kart yüzeyleri (`#1E1A2B` / `#272238`), yüksek kontrastlı nane/limon yeşili birincil vurgu (`#C5F5A3`) ve pastel mor ikincil vurgu (`#8B6FD1`).
- **Uyarlanabilir Açık Tema (Light Theme)**: Lavanta-beyaz arka plan (`#F6F5FA`), saf beyaz kart yüzeyleri (`#FFFFFF`) ve `SharedPreferences` ile kalıcı olarak saklanan tek dokunuşlu tema değiştirme butonu.
- **Tipografi**: `google_fonts` üzerinden **Plus Jakarta Sans** yazı ailesi ve merkezi `AppTypography` hiyerarşisi.
- **Yüzen Alt Navigasyon Çubuğu (`FloatingNavBar`)**: Koyu hap (pill) formunda, aktif sekmesi nane yeşili daireyle vurgulanan ve favori sayısını rozet (badge) olarak gösteren özel alt bar.
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
- **Sorumlulukların Ayrılması (Separation of Concerns)**: UI, iş mantığı (`ChangeNotifier` Provider'lar) ve veri kaynakları (`EventRepository`, `FavoritesLocalStorage`, `ApiClient`) birbirinden tamamen bağımsızdır.
- **Yeniden Kullanılabilirlik (Reusability)**: Kartlar, kategori çipleri, görsel yükleyici (`EventNetworkImage`), animasyonlu kalp butonu (`AnimatedFavoriteButton`) ve durum ekranları (`EventSkeletonView`, `ErrorView`, `EmptyView`) modüler bileşenler olarak tasarlanmıştır.
- **Test Edilebilirlik (Testability)**: Tüm bağımlılıklar yapıcı metot (constructor injection) üzerinden enjekte edildiği için sahte servislerle (Mock/Fake) %100 izole test edilebilir.

---

## 🛠️ Teknoloji Tercihleri ve Gerekçeleri

### 1. Durum Yönetimi: **Provider**
- Flutter ekibinin resmi olarak önerdiği, yalın ve öngörülebilir durum yönetimidir.
- `ChangeNotifier` ve `Consumer` reaktivitesi sayesinde yalnızca ilgili alt bileşenlerin yeniden çizilmesini sağlar.
- `build_runner` veya kod üretimi (codegen) gerektirmez; derleme süresini hızlandırır ve mimariyi şeffaf tutar.

### 2. Yerel Depolama: **shared_preferences (Tam JSON Serileştirme)**
- Sadece etkinlik ID'leri yerine etkinliğin tam özet JSON nesnesi (`EventModel.toJson()` / `fromJson()`) yerel hafızada saklanır.
- Bu sayede **Favoriler ekranı internetsiz (offline) ortamda veya API sunucusu hata verdiğinde bile anında ve eksiksiz çalışır**.
- Bozuk (corrupted) JSON kayıtlarına karşı savunmacı ayrıştırma içerir; hatalı kayıtları atlayarak uygulamanın açılışta çökmesini engeller.

### 3. Ağ İstemcisi: **http + Otomatik Retry & Timeout Sarmalayıcısı**
- API'ye yapılan her istekte **10 saniyelik zaman aşımı (`timeoutDuration`)** uygulanır.
- Sunucunun kasıtlı olarak rastgele döndüğü **HTTP 500** hatalarında ve zaman aşımlarında kullanıcıya hata göstermeden önce **2 kez otomatik yeniden deneme (auto-retry)** yapılır.

---

## 🌟 Bonus Özellikler (Faz 3)

1. **Sonsuz Kaydırma ile Sayfalama (Infinite Scroll Pagination)**:
   - Etkinlikler `page` ve `limit=6` parametreleriyle parçalı olarak çekilir.
   - Kullanıcı listenin sonuna yaklaştığında (`ScrollNotification`) sonraki sayfa otomatik yüklenir.
   - 2. veya 3. sayfa yüklenirken hata oluşursa mevcut liste korunur ve listenin en altında izole bir **"Tekrar Dene"** çubuğu gösterilir.
2. **Anlamlı Animasyonlar (Meaningful Animations)**:
   - **Çakışmasız `Hero` Geçişleri**: Öne çıkanlar karuseli, tüm etkinlikler listesi, filtrelenmiş liste ve favoriler listesindeki kartlara benzersiz `heroTag` önekleri atanarak detay ekranına pürüzsüz görsel uçuş animasyonu sağlandı.
   - **`AnimatedFavoriteButton`**: Kalp ikonuna dokunulduğunda `AnimatedSwitcher` + `ScaleTransition` (`Curves.easeOutBack`) ile yaylanan ölçek animasyonu.
   - **Saf Flutter Shimmer (`EventSkeletonView`)**: Harici paket kullanmadan `AnimationController` ve `Color.lerp` ile ana ekran yerleşimini birebir yansıtan iskelet yükleme ekranı.
   - **`AnimatedSize` & Giriş Animasyonları**: Detay ekranında "Daha Fazla Göster" metin genişlemesi ve liste kartlarının yumuşak giriş animasyonu.
3. **Açık / Koyu Tema Desteği (Light & Dark Mode Toggle)**:
   - Ana ekran başlığındaki tema butonu ile Koyu ve Açık tema arasında anında geçiş ve `SharedPreferences` ile kalıcılık.
4. **GitHub Actions CI (`.github/workflows/ci.yml`)**:
   - Her `push` ve `pull_request` işleminde otomatik olarak `flutter pub get`, `flutter analyze` ve `flutter test` adımlarını koşturan CI iş akışı.

---

## 🛡️ Ele Alınan Uç Durumlar (Edge Cases)

- **Simüle Edilen API Yavaşlığı ve Gecikmeler**: Ağ istekleri `timeout` ile sınırlandırıldı, yükleme sırasında `EventSkeletonView` gösterilir.
- **Rastgele Sunucu Hataları (500)**: Otomatik 2 tekrar denemeden sonra başarısız olursa kullanıcıya anlaşılır Türkçe mesaj ve **"Tekrar Dene"** butonu sunulur.
- **Stale Response Koruması**: Hızlı arama veya kategori değişiminde geciken eski ağ yanıtlarının yeni sonuçları ezmesi `_latestRequestId` sıra sayacı ile engellenmiştir.
- **İzole Detay Ekranı Hata Yönetimi**: Liste ekranından gelen etkinlik verisi detay ekranında **anında** render edilir; yalnızca `/events/{id}` açıklama çağrısı başarısız olursa sadece açıklama bölümünde retry butonu gösterilir, ekranın geri kalanı bozulmaz.
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

---

## 🤖 Yapay Zeka (AI) Kullanım Günlüğü

Bu proje Google Deepmind **Antigravity** yapay zeka asistanı ile eşli programlama (pair programming) yöntemiyle adım adım geliştirilmiştir.

### Temel Kurallar ve Yönergeler
- Mimari ve uygulama planı kod yazılmadan önce detaylandırıldı ve her milestone sonunda kullanıcı onayıyla (`devam`) ilerlendi.
- Kodlar, dosya adları ve tanımlayıcılar İngilizce; açıklamalar ve eğitim adımları Türkçe olarak kurgulandı.
- Önce temel işlevsellik (Faz 1: Milestone 1–7), ardından UI/UX yeniden tasarımı (Faz 2: Milestone 8–10), bonus özellikler (Faz 3: Milestone 11–14) ve final dokümantasyon (Faz 4: Milestone 15) sırası izlendi.
- API'nin kasıtlı simüle edilen hataları (500 internal error) ve yavaşlığı için savunmacı programlama (defensive programming) uygulandı.

### Kullanılan İstem Günlüğü (Prompt Log)
1. `/plan ... (Proje gereksinimleri, Swagger API analizi, Dribbble görsel dili yönergeleri, 4 fazlı geliştirme planı)`
2. `Plan onaylandı, şu değişikliklerle Milestone 1'den başla: 1. Faz 1'de limit=50, 2. favorilerde özet JSON saklama, 3. detay ekranında liste verisiyle anında render ve izole açıklama hatası, 4. stale response koruması + debounce, 5. 500 hatasında otomatik 1-2 tekrar, 6. Türkçe intl formatı, 7. null-safe model testleri.`
3. `devam (Milestone 2 - Veri ve API Katmanı & Null-Safe Modeller)`
4. `devam (Milestone 3 - Etkinlik Listesi Ekranı & Provider & State Views)`
5. `devam (Milestone 4 - Etkinlik Detay Ekranı & İzole Açıklama Yükleme)`
6. `devam (Milestone 5 - Arama Debounce & Dinamik Kategori Filtreleme)`
7. `devam (Milestone 6 - Favoriler & Offline JSON Persistence & Bottom Nav)`
8. `devam (Milestone 7 - Test Kapsamı & Analiz & Faz 1 Doğrulaması)`
9. `devam (Milestone 8 - Faz 2: Tasarım Sistemi, AppColors, AppTypography ve AppTheme)`
10. `devam (Milestone 9 - Faz 2: FloatingNavBar, FeaturedEventCard ve Tüm Ekranların Dribbble Tasarımına Dönüştürülmesi)`
11. `devam (Milestone 10 - Faz 2: Saf Flutter Skeleton Shimmer, EventNetworkImage ve 320x568 Küçük Ekran Overflow Testleri)`
12. `devam (Milestone 11 - Faz 3: Sonsuz Kaydırma / Sayfalama ve İzole Sayfa Yükleme Hatası Yönetimi)`
13. `devam (Milestone 12 - Faz 3: Hero Görsel Geçişleri, AnimatedFavoriteButton ve Liste Animasyonları)`
14. `devam (Milestone 13 - Faz 3: Uyarlanabilir Açık Tema, ThemeProvider Kalıcılığı ve Tema Değiştirme Butonu)`
15. `devam (Milestone 14 - Faz 3: GitHub Actions CI İş Akışı)`
16. `devam (Milestone 15 - Faz 4: Kapsamlı Final README.md ve Teslim Hazırlığı)`
