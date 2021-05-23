Geliştirme Kılavuzu
===================

Kod haritası
------------

Kod 3 ana modülden oluşuyor: `Client`, `Server` ve `Support`.

### `Client`

İstemciyle ilgili tüm işlerin gerçekleştiği modül.  Modülün merkezinde `Application` nesnesi yer alır.  `MetaFile`
yoluyla yüklenen durum dosyasıyla (`src.lock`) `Repository` nesnesi ilklenerek izlenen kaynak depo oluşturulur ve `CLI`
yoluyla gelen `compile`, `decompile`, `update` gibi komutlar `Repository` nesnesine iletilir.

`Repository` tüm istemci dosyaların kaydını `Source` nesneleri yoluyla tutan bir "repository" nesnesidir.  İstemci
dosyalara karşı düşen `Source` nesnelerin bir kısmı durum bilgisiyle oluşturulurken; `compile` komutuyla henüz
izlenmiyorsa yeni `Source` nesneleri eklenir, `decompile` komutuyla ise izlenen bir dosya depodan çıkartılır.

İlkleme sürecinde öntanımlı olarak bir `Server` nesnesi de oluşturularak derleme (`compile`) işleminde
kullanılacak sunucu olarak `Application` nesnesinde tutulur.

#### `Application`

#### `Repository`

#### `Source`

#### `MetaFile`

#### `Meta`

#### `Directive`

#### `CLI`

#### `Command`

#### `Commands`

#### `Lines`

#### `Parser`

#### `Config`

### `Server`

#### `Application`

#### `CLI`

#### `Repository`

#### `MetaFile`

#### `Meta`

#### `Symbols`

### `Support`

Projede kullanılan çoğunlukla genel amaçlı tüm yardımcılar.
