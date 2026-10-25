# Event Discovery App (Etkinlik Keşif Uygulaması) 🎟️✨

MOBILAB Task API kullanılarak geliştirilmiş, üniversite ve topluluk etkinliklerini keşfetmeyi, incelemeyi ve favorilere eklemeyi sağlayan modern bir Flutter mobil uygulaması.

> [!NOTE]  
> Bu uygulama bir bilet satış veya ödeme uygulaması **değildir**. Etkinlikleri sergileme, arama/filtreleme, detaylarını inceleme ve kişisel favoriler listesi oluşturma amacıyla tasarlanmıştır.

---

## 🚀 Başlangıç ve Çalıştırma

### Gereksinimler
- **Flutter SDK**: 3.47.x (veya Dart 3.13+)
- **Platform**: Android / iOS cihaz veya emülatör

### Komutlar
```bash
# 1. Bağımlılıkları yükleyin
flutter pub get

# 2. Kod analizi yapın
dart analyze .

# 3. Testleri çalıştırın
flutter test

# 4. Uygulamayı başlatın
flutter run
```

---

## 📁 Mimari ve Klasör Yapısı (Feature-Based Architecture)

Proje; genişletilebilir, bakımı kolay ve ekip çalışmasına uygun **Özellik ve Katman Tabanlı (Feature-Based Architecture)** bir yaklaşımla organize edilmiştir:

```
lib/
├── core/                         # Uygulama genelinde paylaşılan çekirdek altyapı
│   ├── constants/                # API adresleri, renkler ve sabitler
│   ├── network/                  # HTTP istemcisi, timeout ve hata yakalama
│   ├── storage/                  # shared_preferences yerel veri katmanı
│   ├── theme/                    # Karanlık ve aydınlık tema tanımları
│   └── utils/                    # Tarih/saat formatlayıcılar ve yardımcı fonksiyonlar
│
├── features/                     # Özellik modülleri
│   ├── events/                   # Etkinlikler modülü
│   │   ├── data/                 # Modeller ve Repository katmanı
│   │   └── presentation/         # Provider'lar, ekranlar ve widget'lar
│   │
│   └── favorites/                # Favoriler modülü
│       ├── data/                 # Favori depolama repository'si
│       └── presentation/         # Favoriler provider ve ekranı
│
├── shared/                       # Ortak kullanılan arayüz bileşenleri (NavBar vb.)
└── main.dart                     # Uygulama başlangıç noktası
```

### Neden Bu Yapı Seçildi?
- **Sorumlulukların Ayrılması (Separation of Concerns)**: UI, iş mantığı (Providers) ve veri kaynakları (Repositories & API Client) birbirinden tamamen bağımsızdır.
- **Yeniden Kullanılabilirlik (Reusability)**: Widget'lar küçük ve modüler parçalara bölünmüştür.
- **Test Edilebilirlik (Testability)**: Ağ ve veri katmanı bağımsız olduğundan kolayca mock'lanabilir ve birim testlere tabi tutulabilir.

---

## 🤖 Yapay Zeka (AI) Kullanım Günlüğü

Bu proje Google Deepmind **Antigravity** yapay zeka asistanı ile eşli programlama (pair programming) yöntemiyle geliştirilmiştir.

### Temel Kurallar ve Yönergeler
- Mimari ve uygulama planı kod yazılmadan önce detaylandırıldı ve adım adım kullanıcı onayıyla ilerlendi.
- Kodlar, dosya adları ve tanımlayıcılar İngilizce; açıklamalar ve eğitim adımları Türkçe olarak kurgulandı.
- Önce temel işlevsellik (Faz 1), ardından UI cilalaması (Faz 2), bonus özellikler (Faz 3) ve dokümantasyon (Faz 4) sırası izlendi.
- API'nin kasıtlı simüle edilen hataları (500 internal error) ve yavaşlığı için savunmacı programlama (defensive programming) uygulandı.

### Kullanılan İstem Günlüğü (Prompt Log)
1. `/plan ... (Proje gereksinimleri, Swagger API analizi, Dribbble görsel dili yönergeleri)`
2. `Plan onaylandı, şu değişikliklerle Milestone 1'den başla: 1. limit=50, 2. favorilerde özet JSON saklama, 3. detay ekranında liste verisiyle anında render, 4. stale response koruması, 5. 500 hatasında otomatik 1-2 tekrar, 6. Türkçe intl formatı, 7. null-safe model testleri.`

---

## 🛡️ Ele Alınan Uç Durumlar (Edge Cases)

- **Simüle Edilen API Yavaşlığı**: İsteklere 10 saniye zaman aşımı (timeout) uygulandı.
- **Rastgele Sunucu Hataları (500)**: Otomatik 1-2 kez yeniden deneme (exponential/immediate retry) yapıldıktan sonra kullanıcıya dostça Türkçe hata mesajı ve "Yeniden Dene" butonu sunulur.
- **Stale Response Koruması**: Hızlı arama veya kategori değişimlerinde eski geciken yanıtların yeni sonuçları ezmesi engellendi.
- **İnternetsiz Favoriler**: Favori etkinlikler cihaz yerelinde JSON olarak saklandığı için internetsiz ortamda bile anında görüntülenir.
- **Null Safety**: API'den gelebilecek eksik veya hatalı alanlar için varsayılan güvenli değerler atanır, uygulama asla çökmez.
