Ellipses
========

[![test](https://github.com/roktas/ellipses/actions/workflows/test.yml/badge.svg)](https://github.com/roktas/ellipses/actions/workflows/test.yml)
[![codebeat badge](https://codebeat.co/badges/fe709527-2a06-40ed-b6af-517907bdc75e)](https://codebeat.co/projects/github-com-roktas-ellipses-master)

Static code reusing tool

**WARNING:** This is a pre-alpha release, development only, non-production code.

Kullanım
--------

- Eklenecek kodları `SRCPATH` altında varolan dizinlerde topla.  Bu dizinlere "sunucu" ("server") dizinleri diyoruz.
  Sunucu dizinlerin `«provider»/«owner»/«repo»` düzeninde olması tavsiye edilir.  Örneğin `SRCPATH=/usr/local/src` ise
  tüketilecek kabuk kaynaklarını `/usr/local/src/github.com/roktas/sh` dizininde toplayabilirsiniz.  Öncelikle `SRCPATH`
  ortam değişkeni anons edilir.

  ```sh
  export SRCPATH=/usr/local/src
  ```

- Sunucu dizinin kökünde servis edilecek sembolleri anons eden bir `src.toml` dosyası oluştur.  Örnekteki dizin için
  `/usr/local/src/github.com/roktas/sh/src.toml` dosyası aşağıdaki örnek içeriğe sahip olsun:

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

  Bu yapılandırmada `z` sembolü bağımlılık olarak tüm sembollere eklenirken örneğin `a` sembolü buna ilave olarak `b` ve
  `c` sembollerini çekecektir.  Sonuç olarak sunucudan `a` sembolü istendiğinde sırasıyla `z`, `b`, `c` sembolleri
  çekilecektir.

  Her sembol sunucu dizinde aynı isimde bir dosyaya karşılık gelir.  "Yaprak" niteliğinde sembollerde sembol ile aynı
  isimde dosyanın varlığı zorunlu, diğerlerinde ise zorunlu değildir.  Dolayısıyla yukarıdaki örnek `a` sembolü için
  sırasıyla `z`, `b`, `c` ve (sembolün kendisi için) `a` dosyalarının içerikleri eklenecektir.

- Sembolleri tüketecek dosyalara "istemci" ("client") dosyalar diyoruz.  Bir istemci dosyada başlangıçta `...` söz
  dizimiyle ilgili semboller aşağıdaki gibi istenir.  Örnek `test.sh` dosyası:

  ```sh
  if true; then
        ... github.com/roktas/sh a
  fi
  ```

- Eklemenin yapılması için öncelikle istemci taraf ilklenir.

  ```sh
  src init
  ```

  Bu işlem sonucunda bulunulan dizinde `src.json` adında boş bir dosya oluşacaktır.

- İstemci dosya derlenir ("compile").

  ```sh
  src compile
  ```

  Bu işlemin sonucunda, örneğin `a`, `b`, `c`, ve `z` dosyaları basitçe aynı harfte tek satırlık içeriklerden oluşuyorsa
  `test.sh` dosyası aşağıdaki içerikte olacaktır.

  ```sh
  if true; then
        z
        c
        b
        a
  fi
  ```

  Derleme sırasında `... github.com/roktas/sh a` direktifinin başındaki sekme karakterinin eklenen tüm satırların başına
  ön ek olarak geldiğini not edin.

  Her derleme işleminde `src.json` dosyası güncellenerek yapılan ekleme kaydedilmektedir.

- Herhangi bir anda sunucu tarafta bir değişiklik olmuşsa bu değişiklik `update` komutuyla uygulanır.

  ```sh
  src update
  ```

  Örneğin `b` dosyasının içeriği `B` olarak değiştirilmişse `test.sh` dosyasının içerği şu olacaktır.

  ```sh
  if true; then
        z
        c
        B
        a
  fi
  ```

- Derlenen bir dosyanın eksi haline getirilmesi için `decompile` komutu uygulanır.

  ```sh
  src decompile test.sh
  ```

  Bu komut sonucunda `test.sh` dosyasının içeriği şu oalcaktır.

  ```sh
  if true; then
        ... github.com/roktas/sh a
  fi
  ```

  Yapılan eklemelerin içeriğine müdahale edilmediği sürece `test.sh` dosyasında yapılan tüm değişikliklerin korunacağını
  not edin.
