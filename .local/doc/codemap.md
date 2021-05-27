Kod haritası
================================

Kod 3 ana modülden oluşuyor: `Client`, `Server` ve `Support`.

`Client`
--------------------------------

İstemciyle ilgili tüm işlerin gerçekleştiği modül.  Modülün merkezinde `Application` nesnesi yer alır.  `MetaFile`
yoluyla yüklenen durum dosyasıyla (`src.lock`) `Repository` nesnesi ilklenerek izlenen kaynak depo oluşturulur ve `CLI`
yoluyla gelen `compile`, `decompile`, `update` gibi komutlar `Repository` nesnesine iletilir.

`Repository` tüm istemci dosyaların kaydını `Source` nesneleri yoluyla tutan bir "repository" nesnesidir.  İstemci
dosyalara karşı düşen `Source` nesnelerin bir kısmı durum bilgisiyle oluşturulurken; `compile` komutuyla henüz
izlenmiyorsa yeni `Source` nesneleri eklenir, `decompile` komutuyla ise izlenen bir dosya depodan çıkartılır.  İlkleme
sürecinde öntanımlı olarak bir `Server` nesnesi de oluşturularak derleme (`compile`) işleminde kullanılacak sunucu
olarak `Application` nesnesinde tutulur.

### `CLI`

`Dry::CLI` yoluyla komutları çalıştıran komut satırı nesnesi.  Ayrıntılar için `dry-cli`'ı inceleyin.

### `Application`

`CLI` ile diğer nesneler arasında aracılık yapan "mediator" nesne.  Verilmemesi halinde öntanımlı değerler alan
`Config`, `MetaFile` ("loader"), `Repository` ve `Server` nesnelerinden kompozedir.

### `Config`

Yapılandırma bilgilerini taşıyan nesne.

### `Repository`

Depoyu (bir dizin) izleyen ve ilgili komutları `Source` nesnelerine ileten kolleksiyon nesnesi.  Bu kapsamda öncelikle
dosyaları `register` yaparak depoya katar veya `unregister` yaparak depodan çıkarır.  Kayıtlanan bir dosya `Source`
nesnesine dönüştürülür.  İşlemler `each_source` metoduyla ilgili `Source` nesnelerine iletilir.

### `Meta`

Yapılan derleme işlemlerine ait geri derlemeyi olanaklı kılan meta bilgileri tutan nesne.  İzlenen bir depoya ait güncel
durum `Meta` nesnelerinden oluşan bir dizi halinde tutulur ve bu dizi JSON biçiminde bir "lock" dosyasına kaydedilir.

Nesne, temelde ilgili dosya yolunu taşıyan bir `source` alanı ve derleme işlemlerinin her birini tanımlayan diziye karşı
düşen `series` alanından oluşur.  Dizi içeriğindeki her kayıt bir `Lock` nesnesidir.  `Lock` nesnesi değişime yol açan
"direktif" satırı bilgisi ve yapılan eklemeyi anlatan `Insertion` nesnesinden oluşur.  `Insertion` nesnesi aşağıdaki
bilgilerden oluşur:

- `signature`: Geri derleme işleminde eklenen satır bloğu aranırken başlangıç noktası olarak kullanılacak, entropisi
  yani ayırt ediciliği yüksek "imza" satırı.

- `before`, `after`: İmza satırının öncesi ve sonrasında kaç satır bulunduğu bilgisi.  Ekleme belirlenirken önce imza
  satırı bulunur, daha sonra bu imza satırı etrafındaki blok bu alanlardaki bilgi kullanılarak belirlenir.

- `digest`: Eşleşen bir bloğun aradığımız blok olduğunu belirleyen nihai testte kullanılacak sayısal özet değeri.
  Eşleşen blok satırları birleştirildikten sonra sayısal özeti hesaplanarak bu değerle kıyaslanır.  Kıyaslama olumluysa
  derleme işlemi sonrasında eklenen satırlar tam olarak bulunmuş demektir.

### `MetaFile`

Depoda yapılan işlemlerin kaydını tutan `Meta` nesnesinin JSON biçimine serileştirilmiş halini içeren dosya.  İzlenen
bir depoda bu dosya daima bulunmalı, yoksa `init` komutuyla ilklenerek boş halde oluşturulmalıdır.

Bu dosya bulunulan dizinden itibaren üst dizinlere doğru yapılacak bir aramada `%w[.local/var/src.lock src.lock
.src.lock]` dizisinde bulunan dosya yollarından ilk eşleşen olarak belirlenir.  (`.local/var/src.lock` dosya yolu
[LFHS](https://alaturka.github.io/) (TODO: henüz dokümante edilmedi) uyumlu proje depolarını desteklemek için
eklenmiştir.)

### `Source`

Derlenecek veya geri derlenecek kaynak kod içeriklerini yöneten nesne.  İçerik satırlar halinde `Lines` nesnesine
dönüştürülerek tutulur.  İşlem geçmişi `series` dizisiyle iletilir.  Dosya zaten derlenmemiş veya geri derlenmiş
durumdaysa bu dizi boştur.  Nesne temelde üç işlem gerçekleştirir: `compile`, `decompile` ve `recompile`.

Derleme işleminde satırlar (`lines`) üzerinde dolaşılarak "direktif" (`Directive`) eşleştirmesi yapılır.  Satırda
"direktif" varsa `Parser` nesnesiyle ayrıştırılarak `Directive` nesnesi oluşturulur ve çalıştırılır (`execute`).
Çalıştırma sonucunda üretilen yeni satır dizisi ilgili direktif satırıyla değiştirilerek kaynak satırlara yerleştirilir.
İşlem sonucunda yapılan eklemeyi tasvir eden `Meta` bilgi üretilerek `series` dizisine eklenir.

Geri derleme işleminde `series` dizisinde dolaşılarak her bir ekleme için kaynak satırlarda eşleşen satırlar belirlenir
ve bu satırlar kaynak satırlardan çıkarılır.  Geri derleme işlemi sonrasında `series` dizisi tamamen tüketilerek boş bir
dizi halini alır.

Tekrar derleme işleminde kaynak satırlar önce geri derlenerek özgün haline dönüştürülür ve daha sonra bu satırlar
derleme işlemine alınır.  Bu sayede sunucu tarafında güncellenen içerik kaynak satırlarda yerini almış olur.

### `Lines`

Kaynak kod satırları üzerinde yapılacak satır bazlı işlemleri kolaylaştıran yardımcı nesne.  `Lines` temelde
`SimpleDelegator` yoluyla diziden delege eden bir dizi nesnesidir; dolayısıyla tüm dizi metodlarına sahiptir.  Bu nesne
`Meta::Insertion` ile iletilen ekleme bilgisine uygun satır bloğunu bulan veya istenen bir eklemeyi gerçekleştirirken
eklenen bloğa ait `Meta::Insertion` nesnesini oluşturan lojiği barındırır.

### `Parser`

Söz dizimi ilgili bölümde verilen direktif satırlarıyla eşleşerek bu satırları sözcük birimlerine ("lexeme") ayıran
nesne.  `Parser` nesnesi eşleştirme ve ayrıştırmayı (şimdilik) basit düzenli ifadelerle ve `Shellwords` yoluyla
gerçekleştirmektedir.

### `Directive`

Bir direktif kaynak kodda `|` karakteriyle ayrılmış komutlardan (`Command`) oluşan aşağıdaki gibi bir satırdır.

```txt
>>> «Source command» | «Sink command» | ...
```

Bu söz diziminde görülen her bir "command" `Commands` modülü altında toplanmış komut nesnelerinden birine karşı düşer.
Özel olarak `>>> include uri [symbols]` komutu `... uri [symbols]` "syntax sugar" niteliğindeki söz dizimiyle de
tanınabilir.  (Söz diziminde geçen `...` (ellipses) karakteri bu projeye de ismini vermiştir.)

`Directive` nesnesi `Command` nesneleri dizisinden oluşan kompozit bir nesnedir.  Bir derleme işlemi sırasında ilgili
satırdaki direktif çalıştırılırken her bir komutun ürettiği yeni satırlar takip eden komuta girdi olarak girer ve son
komutun ürettiği satırlar direktifin bulunduğu satırla yer değiştirir.

### `Command`

`Commands` modülü altındaki tüm komut eklentilerini temsil eden komut nesnesi.  Ayrıştırma sonrasında üretilen `Command`
nesnesi `Directive` nesnesine girerken önce (varsa) `setup` metodu çağrılarak yapılandırılır.  Bu aşamada örneğin komut
argümanları denetlenir ve varsa hatalar için istisna üretilir.  Direktifin çalıştırması ("execute") sırasında ise `call`
metodu çağrılır.  Her komutun sunucu (`Server`) tüketmesi gerekmemekle birlikte bazı "kaynak" komutlar (ör. `include`)
çalıştırma sırasında ihtiyaç duyacağı `Server` nesnesini `Command` baz nesnesinden alabilir.  `Command` nesnesi
`Commands` isim uzayındaki komutlarda kullanılmak üzere basit bir `DSL` de barındırır.

### `Commands`

`Command` nesnesinden miras alarak gerçeklenen tüm komutları birer eklenti halinde barındıran isim uzayı modülü.  Bir
komut tanımlanırken öncelikle `Command` sınıfından miras alır ve sınıf gövdesinde `Command` sınıfının sunduğu DSL
kullanılarak komutun ismi ve argüman denetlemesi için gerekli bilgi bildirilir.

`Server`
--------------------------------

Sunucuyla ilgili tüm işlerin gerçekleştiği modül.  Burada geçen "sunma" işlemi geleneksel anlamın biraz dışındadır.
İstemci tarafta `include` komutuyla bildirilen "URI"lerin her biri dosya sisteminde, kök dizininde geçerli bir
`src.toml` dosyası barındıran bir dizin ağacıdır.  Bu dizin ağacına sunucu deposu: `Server::Repository` diyoruz.  Her
sunucu deposu `src.toml` dosyasında bir dizi "sembol" (`Symbol`) ekspoze eder.  İstemci tarafta çalıştırılan bir
`include` komutu, argüman olarak verilen "URI"ye karşı düşen sunucu deposundan, yine argüman olarak verilen sembollere
karşı düşen kaynak kod satırlarını tüketir.

### `Repository`

Bir sunucu deposundaki sembolleri yöneten nesne.  Bu nesne, `MetaFile` yoluyla yüklenen `src.toml` dosyasında tanımlı
sembollerden üretilen `Symbols` nesnesi, yine `src.toml` dosyasında tanımlı global ayarlardan üretilen bir
`Meta::Global` nesnesi ve son olarak semboller dosya sistemindeki gerçek dosyalarla eşleştirilirken yapılacak dosya yolu
çözümlemesinde kullanılan ve sunucu deposunun bulunduğu kök dizini gösteren bir dizin adından oluşur.  `Repository`
nesnesinin temel görevi kendisine bildirilen bir sembol dizgisini çözümleyerek bu dizgiye karşı düşen kaynak kod
satırlarını üretmektir.  Bu şekilde çözümlenerek kaynak kod satırları elde edilen her sembol "tüketilmiş" kabul edilir
ve aynı sembol bir kez daha istendiğinde çözümleme yapılmadan boş (`nil`) dönülür.

### `CLI`

`Dry::CLI` yoluyla komutları çalıştıran komut satırı nesnesi.  Ayrıntılar için `dry-cli`'ı inceleyin.

### `Application`

`CLI` ile diğer nesneler arasında aracılık yapan "mediator" nesne.  `Application` nesnesi istemciden gelen sunucu
URI'lerini dizin halinde arayacağı bir `paths` değişkeniyle ilklenir.  Her isimlendirilmiş sunucu/port için, içinde o
sunucuya karşı düşen `Repository` nesnesini barındıran  özel bir `Instance` üretilir ve üretilen bu sunucu nesneleri bir
`instances` tablosunda tutulur.

Burada geçen "port" kavramı da geleneksel anlamın biraz dışındadır.  `Repository` nesneleri her sembol istediğinde
sembolü "tükettiğinden" istemci tarafta aynı dosya içinde bir sembolün birden fazla kez "include" edilmesi olanağı
normalde bulunmamaktadır.  Bu sınırlama "port" kullanımıyla aşılır.  Aynı sunucu deposundan bir sembolün istemci dosyada
tekrar eklenmesi isteniyorsa yapılması gereken bildirilen URI'ye aşağıdaki gibi bir "port" eklemektir.

```txt
... github.com/foo/bar baz
... github.com/foo/bar:1 baz
```

Bu örnekte ilk istemci direktifinde `baz` sembolü tüketildiğinden aynı direktifle `baz` sembolü tekrar eklenemez ve hata
alınır.  Tüketilen sembolü tekrar eklemek için `github.com/foo/bar` sunucu "URI"sine `:1` port belirtimi eklenerek
`Application` nesnesinin farklı bir instance oluşturması sağlanır.  (Port verilmediğinde `:0` port belirtimi
varsayılır.)

### `Meta`

Sunucu deposunu tanımlayan meta bilgileri temsil eden nesne.  Bu nesne bir `Meta::Global` niteliğinden ve deponun
bildirdiği tüm sembolleri temsil eden bir `Meta::Symbols` niteliğinden oluşur, öyleki temelde bir dizi olan bu nesnede
her bir eleman bir `Meta::Symbol` nesnesidir.

`Meta::Global` nesnesi aşağıdaki niteliklere sahiptir.

- `depends`: Sunucu deposunda tüm sembollere bağımlılık olarak eklenecek sembol dizgilerini tanımlayan dizgi dizisi.

- `root`: Dosya çözümlemesinde (sunucu deposu köküne eklenerek) kullanılacak kök dizin yolu.

- `extension`: Semboller dosya sistemindeki gerçek dosyalarla eşleştirilirken hesaplanan dosya yoluna dosya eklentisi
  olarak eklenecek dizgi.

`Meta::Symbol` nesnesi aşağıdaki niteliklere sahiptir.

- `symbol`: Sembole karşı düşen dizgi.

- `description`: Sembolle ilgili (isteğe bağlı) açıklama.

- `depends`: Sembolün bağımlı olduğu diğer sembolleri tanımlayan dizgi dizisi.

- `path`: İsteğe bağlı olarak sembole karşı düşen dosyayı açık halde bildiren dosya yolu dizgisi.

### `MetaFile`

Sunucu deposunu tanımlayan `src.toml` meta dosyasını yöneten nesne.  Kolay düzenlenebilmesi için TOML biçiminin tercih
edildiği bu dosya `MetaFile` nesnesi yoluyla yüklenir ve ayrıştırılan bilgiler bir `Meta` nesnesine dönüştürülür.

### `Symbols`

Sunucu deposundaki tüm sembolleri temsil eden nesne.  Temelde bir hash olan bu nesne bir `Meta` nesnesiyle ilklenir ve
verilen sembol dizgisine karşı düşen sembolü tüm bağımlılıklarıyla birlikte çözer.  Nesnenin merkezinde her sembol
düğümünde özyinelemeli olarak çalışan `walk` metodu vardır.  `Symbol` tablosu `Meta` nesnesinden hareketle
oluşturulduktan sonra bu `walk` metoduyla semboller arasında "döngüsel referanslar" başta olmak üzere hata olup olmadığı
denetlenir (`sanitize` işlemi).  Nesneye verilen her sembol dizgisi `resolve` metodu yoluyla yine bu `walk` metodu ile
çözümlenerek hesaplanan semboller dönülür.

`Support`
--------------------------------

Projede kullanılan çoğunlukla genel amaçlı tüm yardımcılar.
