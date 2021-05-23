Ellipses
========

[![test](https://github.com/alaturka/ellipses/actions/workflows/test.yml/badge.svg)](https://github.com/alaturka/ellipses/actions/workflows/test.yml)
[![codebeat badge](https://codebeat.co/badges/3828d0b1-bdac-4028-92a4-33055a74ecae)](https://codebeat.co/projects/github-com-alaturka-ellipses-master)

Static code reusing tool (**WARNING:** This software is a pre-release that is still in development)

Statik olarak yeniden kod kullanımı için bir araç (**UYARI:** Bu yazılım, geliştirmesi halen devam eden bir ön sürümdür)

Kullanım
--------

- Eklenecek kodları `SRCPATH` ortam değişkeniyle anons edilen dizin ağacında topla.  Bu dizinlere "sunucu" ("server")
  dizinleri diyoruz.  Sunucu dizinlerin `«provider»/«owner»/«repo»` düzeninde olması tavsiye edilir.  Örneğin
  `SRCPATH=/usr/local/src` ise tüketilecek kabuk kaynaklarını `/usr/local/src/github.com/roktas/sh` dizininde
  toplayabilirsin.

  ```sh
  export SRCPATH=/usr/local/src
  ```

- Sunucu dizin kökünde servis edilecek sembolleri bildiren bir `src.toml` dosyası oluştur.  Örnekteki dizin için
  `/usr/local/src/github.com/roktas/sh/src.toml` dosyası aşağıdaki örnek içerikte olsun.

  ```toml
  depends = [
        "z"
  ]

  [[symbols]]
        symbol  = "a"
        depends = [
                "b",
                "c"
        ]

  [[symbols]]
        symbol = "b"

  [[symbols]]
        symbol = "c"

  [[symbols]]
        symbol = "z"
  ```

  Bu yapılandırmada `z` sembolü bağımlılık olarak tüm sembollere eklenirken, örneğin `a` sembolü buna ilave olarak `b`
  ve `c` sembollerini çekecektir.  Sonuç olarak sunucudan `a` sembolü istendiğinde bağımlılık olarak sırasıyla `z`, `b`,
  `c` sembolleri ve sonrasında sembolün kendisi için `a` sembolü çekilecektir.

  Her sembol sunucu dizinde aynı isimde bir dosyaya karşılık gelir.  "Yaprak" niteliğinde sembollerde sembol ile aynı
  isimde dosyanın varlığı zorunlu, diğerlerinde ise zorunlu değildir.  Dolayısıyla yukarıdaki örnekte `a` sembolü için
  sırasıyla `z`, `b`, `c` ve (sembolün kendisi için) `a` dosyalarının içerikleri eklenecektir.

- Sunucudan sembol isteğinde bulun.  Sembolleri tüketecek dosyalara "istemci" ("client") dosyalar diyoruz.  Aşağıda
  örneklenen `test.sh` isimli istemci dosyada başlangıçta `...` söz dizimiyle `github.com/roktas/sh` isimli sunucudan
  `a` sembolü istenmektedir.  Bu satıra "direktif" satırı diyoruz.

  ```sh
  if true; then
        ... github.com/roktas/sh a
  fi
  ```

- Eklemenin yapılması için öncelikle istemci tarafı ilkle.

  ```sh
  src init
  ```

  Bu işlem sonucunda bulunulan dizinde `src.json` adında boş bir dosya oluşacaktır.

- İstemci dosyayı derle ("compile")

  ```sh
  src compile test.sh
  ```

  Bu işlemin sonucunda, örneğin `a`, `b`, `c`, ve `z` dosyaları basitçe aynı harfte tek satırlık içeriklerden oluşuyorsa
  `test.sh` dosyası aşağıdaki içerikte olacaktır.

  ```sh
  if true; then
        z

        b

        c

        a
  fi
  ```

  Derleme sırasında `... github.com/roktas/sh a` direktifinin başındaki sekme karakterinin eklenen tüm satırların başına
  ön ek olarak geldiğini not edin.  Her derleme işleminde `src.json` dosyası güncellenerek yapılan ekleme kaydedilmektedir.

- Herhangi bir anda sunucu tarafta bir değişiklik olmuşsa bu değişikliği `update` komutuyla al

  ```sh
  src update
  ```

  Bu komut tüm istemci dosyaları güncellediğinden dosya argümanı gerekmemektedir.  Örneğin `b` dosyasının içeriği `B`
  olarak değiştirilmişse `test.sh` dosyasının içeriği aşağıdaki gibi olacaktır.

  ```sh
  if true; then
        z

        B

        c

        a
  fi
  ```

- Derlenen bir dosyayı eski haline getirmek için `decompile` komutunu uygula

  ```sh
  src decompile test.sh
  ```

  Komut sonucunda `test.sh` dosyasının içeriği (dosyada başka bir düzenleme yapılmadığı varsayımıyla) aşağıdaki gibi
  olacaktır.

  ```sh
  if true; then
        ... github.com/roktas/sh a
  fi
  ```

  Önceden uygulanan eklemelerin içeriğine müdahale edilmediği sürece `test.sh` dosyasında yapılan tüm değişiklikler
  korunmaktadır.

Yol haritası
------------

### Sürüm `0.0`

Kişisel tüketime hazır PoC sürüm

- [ ] Geliştirici dokümantasyonunu yaz

### Sürüm `0.1`

Yakın çevrenin (kuvvetli uyarılarla) kullanımına izin verilebilecek sürüm

- [ ] `README`'yi zenginleştir

- [ ] Son kullanıcı kılavuzlarını yaz
  * [ ] `src.1`
  * [ ] `srv.1`
  * [ ] `src.lock.5`
  * [ ] `src.toml.5`

### Sürüm `0.5`

Yakın çevrenin kullanımına teşvik edilecek sürüm

- [ ] Temel birim testlerini tamamla

- [ ] Eksik komutları tamamla
  * [ ] `src validate`
  * [ ] `srv validate`

### Sürüm `1.0`

Resmi ilk sürüm

- [ ] Enternasyonelleştir (İngilizce dokümantasyon)

- [ ] Birim testlerini tamamla (code coverage kabul edilir seviyede olmalı)

- [ ] Entegrasyon testlerini tamamla
  * [ ] Testleri refaktörle
  * [ ] Testleri zenginleştir

- [ ] Yeterince test edilmemiş direktifleri tamamla
  * [ ] `reject`
  * [ ] `select`
  * [ ] `substitute`
  * [ ] `translate`

- [ ] Resmi Gem olarak yayınla

### Sürüm `1.0` sonrası

Yeni özelliklerin planlanabileceği sürümler

- [ ] Sembollerde yeni nitelikler?
  * [ ] `Conflict` niteliği?
  * [ ] `Provides` niteliği?

- [ ] Yeni direktifler
  * [ ] `render`

- [ ] Pre-injection yoluyla seçilen bazı bağımlılıkların çekilmemesi

### Gelecek

Yeni baştan yazımı gerektirebilecek gelecek sürümler

- [ ] Git yoluyla kaynak yönetimini seçenek olarak ekle

- [ ] Go ile yeniden yaz?

- [ ] "Dependabot" tarzı bir servise yaz
