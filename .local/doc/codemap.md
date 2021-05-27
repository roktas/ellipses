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
izlenmiyorsa yeni `Source` nesneleri eklenir, `decompile` komutuyla ise izlenen bir dosya depodan çıkartılır.

İlkleme sürecinde öntanımlı olarak bir `Server` nesnesi de oluşturularak derleme (`compile`) işleminde
kullanılacak sunucu olarak `Application` nesnesinde tutulur.

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

Nesne temelde ilgili dosya yolunu taşıyan bir `source` alanı ve derleme işlemlerinin her birini tanımlayan diziye karşı
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

Depoda yapılan işlemleri tutan `Meta` nesnesinin JSON biçimine serileştirilmiş halinden oluşan dosya.  İzlenen bir
depoda bu dosya daima bulunmalı, yoksa `init` komutuyla ilklenerek boş halde oluşturulmalıdır.

Bu dosya bulunulan dizinden itibaren üst dizinlere doğru yapılacak bir aramada `%w[.local/var/src.lock src.lock
.src.lock]` dizisinde bulunan dosya yollarından ilk eşleşen olarak belirlenir.  (`.local/var/src.lock` dosya yolu
[LFHS](https://alaturka.github.io/) (TODO: henüz dokümante edilmedi) uyumlu proje depolarını desteklemek için
eklenmiştir.)

### `Source`

Derlenecek veya geri derlenecek kaynak kod içeriklerini yöneten nesne.  İçerik satırlar halinde `Lines` nesnesine
dönüştürülerek tutulur.  İşlem geçmişi `series` dizisiyle iletilir.  Dosya zaten derlenmemiş veya geri derlenmiş
durumdaysa bu dizi boştur.  Nesne temelde üç işlem gerçekleştirir: `compile`, `decompile` ve `recompile`.

Derleme işleminde satırlar (`lines`) üzerinde dolaşılarak "direktif" (`Directive`) eşleştirmesi yapılır.  Satırda
"direktif" varsa `Parser` nesnesiyle ayrıştırılarak `Directive` nesnesi oluşturulur ve nesne çalıştırılır (`execute`).
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
Özel olarak `>>> include uri [symbols]...` komutu `... uri [symbols]...` söz dizimiyle de tanınabilir.  (Bu söz
diziminde geçen `...` (ellipses) karakteri bu projeye de ismini vermiştir.)

`Directive` nesnesi `Command` nesneleri dizisinden oluşan kompozit bir nesnedir.  Bir derleme işlemi sırasında ilgili
satırdaki direktif çalıştırılırken her bir komutun ürettiği yeni satırlar takip eden komuta girdi olarak girer ve son
komutun ürettiği satırlar direktifin bulunduğu satırla yer değiştirir.

### `Command`

`Commands` modülü altındaki tüm komut eklentilerini temsil eden komut nesnesi.  Bir komut ayrıştırma sonrasında üretilen
`Command` nesnesi `Directive` nesnesine girerken önce (varsa) `setup` metodu çağrılarak yapılandırılır.  Bu aşamada
örneğin komut argümanları denetlenir ve varsa hatalar için istisna üretilir.  Direktifin çalıştırması ("execute")
sırasında ise `call` metodu çağrılır.  Her komutun sunucu (`Server`) tüketmesi gerekmemekle birlikte bazı "kaynak"
komutlar (ör. `include`) çalıştırma sırasında ihtiyaç duyacağı `Server` nesnesini `Command` baz nesnesinden alabilir.

`Command` nesnesi `Commands` isim uzayındaki komutlarda kullanılmak üzere basit bir `DSL` de barındırır.

### `Commands`

Tüm komutları birer eklenti halinde barındıran `Command` nesneleri.  Bir komut tanımlanırken öncelikle `Command`
sınıfından miras alır ve sınıf gövdesinde `Command` sınıfının sunduğu DSL'i kullanarak komutun söz diziminde gerekli
ismlendirme ve argüman sayısı sınırları bildirilir.

`Server`
--------------------------------

### `Application`

### `CLI`

### `Repository`

### `MetaFile`

### `Meta`

### `Symbols`

`Support`
--------------------------------

Projede kullanılan çoğunlukla genel amaçlı tüm yardımcılar.
