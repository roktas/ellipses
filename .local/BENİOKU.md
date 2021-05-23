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

Yol haritası
------------

### Sürüm `0.0`

Kişisel tüketime hazır PoC sürüm

- [ ] Geliştirici dokümantasyonu yaz

### Sürüm `0.1`

Yakın çevrenin (kuvvetli uyarılarla) kullanımına izin verilebilecek sürüm

- [ ] `README`'yi zenginleştir

- [ ] Son kullanıcı kılavuzlarının ilk sürümlerini yaz
  * [ ] `src.1`
  * [ ] `srv.1`
  * [ ] `src.lock.5`
  * [ ] `src.toml.5`

### Sürüm `0.x` (`x` 1'den büyük)

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

- [ ] Yeni komutlar
  * [ ] `src refresh`
  * [ ] `src rename`

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

- [ ] "Dependabot" tarzı bir servis yaz
