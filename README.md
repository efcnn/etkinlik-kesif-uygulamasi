# Event Discovery App (Etkinlik Keşif Uygulaması) 🎟️✨

MOBILAB Task API kullanılarak geliştirilmiş, üniversite ve topluluk etkinliklerini keşfetmeyi, aramayı, kategorilere göre süzmeyi, detaylarını incelemeyi ve yerel olarak favorilere eklemeyi sağlayan modern bir Flutter mobil uygulaması.

> [!NOTE]  
> Bu uygulama bir bilet satış veya ödeme uygulaması **değildir**. Fiyat, sepet veya bilet satın alma öğeleri içermez; etkinlikleri sergileme, inceleme ve kişisel favori listesi oluşturma amacıyla tasarlanmıştır.

---

## 🚀 Başlangıç ve Çalıştırma

### Gereksinimler
- **Flutter SDK**: 3.47.x (veya Dart 3.13+)
- **Platform**: Android / iOS cihaz veya emülatör

### Komutlar
```bash
# 1. Bağımlılıkları yükleyin
flutter pub get

# 2. Kod analizi yapın (0 hata / 0 uyarı)
dart analyze .

# 3. Testleri koşturun (36 test)
flutter test

# 4. Uygulamayı başlatın
flutter run
```

> [!TIP]  
> Windows işletim sisteminde Türkçe karakter içeren dosya yollarında (`Masaüstü` vb.) Flutter LSP'sinin UTF-8 byte stream kısıtlamasına takılmamak için doğrudan CLI tabanlı `dart analyze .` komutu tercih edilmiştir.

---

## 📁 Mimari ve Klasör Yapısı (Feature-Based Architecture)

Proje; genişletilebilir, bakımı kolay ve modüler **Özellik ve Katman Tabanlı (Feature-Based Architecture)** bir yaklaşımla organize edilmiştir:

```
lib/
├── core/                         # Uygulama genelinde paylaşılan çekirdek altyapı
│   ├── constants/                # API adresleri ve uç noktalar (api_endpoints.dart)
│   ├── network/                  # HTTP istemcisi (timeout, auto-retry) ve hata hiyerarşisi
│   ├── storage/                  # shared_preferences soyutlaması
│   ├── theme/                    # Renkler, tipografi ve tema tanımları
│   └── utils/                    # intl Türkçe tarih/saat formatlayıcıları
│
├── features/                     # Özellik modülleri
│   ├── events/                   # Etkinlikler modülü
│   │   ├── data/
│   │   │   ├── models/           # EventModel, EventListResponse (null-safe)
│   │   │   └── repositories/     # EventRepository
│   │   └── presentation/
│   │       ├── providers/        # EventListProvider, EventDetailProvider
│   │       ├── screens/          # EventListScreen, EventDetailScreen, MainNavigationScreen
│   │       └── widgets/          # EventListTile, CategoryChips, SearchField, StateViews
│   │
│   └── favorites/                # Favoriler modülü
│       ├── data/                 # FavoritesLocalStorage (JSON persistence)
│       └── presentation/
│           ├── providers/        # FavoritesProvider
│           └── screens/          # FavoritesScreen
│
├── shared/                       # Ortak kullanılan arayüz bileşenleri
└── main.dart                     # MultiProvider ve uygulama başlangıç noktası
```

### Neden Bu Mimari Seçildi?
- **Sorumlulukların Ayrılması (Separation of Concerns)**: UI, iş mantığı (Provider'lar) ve veri kaynakları (Repositories, Local Storage, API Client) birbirinden tamamen bağımsızdır.
- **Yeniden Kullanılabilirlik (Reusability)**: Kartlar, çipler, durum bileşenleri (`LoadingView`, `ErrorView`, `EmptyView`) küçük ve modüler widget'lar olarak kurgulanmıştır.
- **Test Edilebilirlik (Testability)**: Bağımlılıklar parametre olarak geçilebildiği için (Dependency Injection) sahte servislerle (Mock/Fake) %100 izole test edilebilir.

---

## 🛠️ Teknoloji Tercihleri ve Gerekçeleri

### 1. Durum Yönetimi: **Provider**
- Flutter ekibinin resmi olarak önerdiği, öğrenmesi en kolay ve temiz durum yönetimidir.
- `ChangeNotifier` ve `Consumer` reaktivitesi sayesinde gereksiz yeniden çizimleri önler.
- `build_runner` veya kod üretimi gerektirmez, başlangıç dostudur ve projeyi şişirmez.

### 2. Yerel Depolama: **shared_preferences (JSON Serialization)**
- Sadece etkinlik ID'leri yerine etkinliğin tam özet JSON verisi (`toJson()` / `fromJson()`) saklanır.
- Bu sayede **Favoriler ekranı internetsiz ortamda veya API sunucusu kapalıyken bile anında açılır**.
- Hive veya SQLite gibi ağır veritabanlarının gerektirdiği binary şema adaptörleri ve platform uyumsuzlukları riskini ortadan kaldırır.

### 3. Ağ İstemcisi: **http + Özel Retry & Timeout Sarmalayıcısı**
- API'ye yapılan her istekte 10 saniyelik zaman aşımı (`timeoutDuration`) uygulanır.
- Sunucunun rastgele döndüğü 500 hatalarında kullanıcıya hata yansıtılmadan önce **1-2 kez otomatik tekrar deneme** yapılır.

---

## 🛡️ Ele Alınan Uç Durumlar (Edge Cases)

- **Simüle Edilen API Yavaşlığı ve Gecikmeler**: Ağ istekleri `timeout` ile sınırlandırıldı, ekranlar donmaz.
- **Rastgele Sunucu Hataları (500)**: Otomatik tekrar denemelerden sonra başarısız olursa kullanıcıya anlaşılır Türkçe mesaj ve **"Tekrar Dene"** butonu sunulur.
- **Stale Response Koruması**: Hızlı arama veya kategori değişiminde geciken eski isteklerin yeni sonuçları ezmesi engellenmiştir (`_latestRequestId` sayacı).
- **İzole Detay Ekranı Hata Yönetimi**: Liste ekranından gelen veriler detay ekranında hemen render edilir; yalnızca `/events/{id}` açıklama çağrısı başarısız olursa sadece o bölümde retry butonu gösterilir, ana ekran bozulmaz.
- **Search Debounce**: Arama kutusuna hızlı yazıldığında sunucuya her harfte istek gitmesi 400 ms debounce ile engellenmiştir.
- **Null Safety ve Eksik Alanlar**: API'den gelebilecek eksik `imageUrl`, `location`, `organizer`, `tags`, `capacity` değerleri güvenli varsayılanlarla karşılanır, uygulama asla çökmez.
- **Korumalı JSON Depolama**: Yerel hafızadaki bozuk veriler atlanır, uygulamanın açılışı kilitlenmez.

---

## 🧪 Test Kapsamı (36 Test - %100 Başarı)

| Modül / Katman | Test Dosyası | Kapsanan Durumlar |
| :--- | :--- | :--- |
| **Model** | `test/unit/event_model_test.dart` | Tam JSON parse, null/eksik alan toleransı, JSON serileştirme/kalıcılık, copyWith |
| **Tarih Formatı** | `test/unit/date_formatter_test.dart` | `intl` Türkçe ay ve gün isimleri, saat aralığı, timezone normalizasyonu |
| **Repository** | `test/unit/event_repository_test.dart` | Kategori listeleme, sorgu parametreleri, detay getirme, hata fırlatma |
| **Liste State** | `test/unit/event_list_provider_test.dart` | Yükleniyor, başarı, hata, boş liste, stale response koruması, debounce, filtre temizleme |
| **Detay State** | `test/unit/event_detail_provider_test.dart` | İlk veriyi koruma, izole açıklama yükleme, retry, metin açma/kapatma |
| **Depolama** | `test/unit/favorites_storage_test.dart` | Kalıcı saklama, okuma, silme, bozuk JSON atlama |
| **Favori State** | `test/unit/favorites_provider_test.dart` | Favori açıp kapatma, sayaç kontrolü, varlık sorgusu |
| **Liste UI** | `test/widget/event_list_screen_test.dart` | Hata ekranı ve retry butonu tıklaması, arama ve kategori çipleri |
| **Detay UI** | `test/widget/event_detail_screen_test.dart` | Anında çizim, izole hata kutusu ve retry butonu |
| **Favori UI** | `test/widget/favorites_screen_test.dart` | Boş durum ekranı, favori kartı çizimi ve kalp tıklamasıyla kaldırma |

---

## 🤖 Yapay Zeka (AI) Kullanım Günlüğü

Bu proje Google Deepmind **Antigravity** yapay zeka asistanı ile eşli programlama (pair programming) yöntemiyle adım adım geliştirilmiştir.

### Temel Kurallar ve Yönergeler
- Mimari ve uygulama planı kod yazılmadan önce detaylandırıldı ve adım adım kullanıcı onayıyla ilerlendi.
- Kodlar, dosya adları ve tanımlayıcılar İngilizce; açıklamalar ve eğitim adımları Türkçe olarak kurgulandı.
- Önce temel işlevsellik (Faz 1), ardından UI cilalaması (Faz 2), bonus özellikler (Faz 3) ve dokümantasyon (Faz 4) sırası izlendi.
- API'nin kasıtlı simüle edilen hataları (500 internal error) ve yavaşlığı için savunmacı programlama (defensive programming) uygulandı.

### Kullanılan İstem Günlüğü (Prompt Log)
1. `/plan ... (Proje gereksinimleri, Swagger API analizi, Dribbble görsel dili yönergeleri)`
2. `Plan onaylandı, şu değişikliklerle Milestone 1'den başla: 1. limit=50, 2. favorilerde özet JSON saklama, 3. detay ekranında liste verisiyle anında render, 4. stale response koruması, 5. 500 hatasında otomatik 1-2 tekrar, 6. Türkçe intl formatı, 7. null-safe model testleri.`
3. `devam (Milestone 2 - Veri ve API Katmanı)`
4. `devam (Milestone 3 - Etkinlik Listesi Ekranı & Provider & State Views)`
5. `devam (Milestone 4 - Etkinlik Detay Ekranı & İzole Açıklama Yükleme)`
6. `devam (Milestone 5 - Arama & Dinamik Kategori Filtreleme)`
7. `devam (Milestone 6 - Favoriler & Offline JSON Persistence & Bottom Nav)`
8. `devam (Milestone 7 - Test Kapsamı & Analiz & Faz 1 Doğrulaması)`
