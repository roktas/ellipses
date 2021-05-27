Yol haritası
============

~~Sürüm `0.0`~~
-------------------------------

Kişisel tüketime hazır PoC sürüm

- [X] Geliştirici dokümantasyonu yap

Sürüm `0.1`
-------------------------------

Yakın çevrenin (kuvvetli uyarılarla) kullanımına izin verilebilecek sürüm

- [ ] `README`'yi zenginleştir

- [ ] Son kullanıcı kılavuzlarının ilk sürümlerini yaz
  * [ ] `src.1`
  * [ ] `srv.1`
  * [ ] `src.lock.5`
  * [ ] `src.toml.5`

Sürüm `0.x` (`x` 1'den büyük)
-------------------------------

Yakın çevrenin kullanımına teşvik edilecek sürüm

- [ ] Temel birim testlerini tamamla

- [ ] Eksik komutları tamamla
  * [ ] `src validate`
  * [ ] `srv validate`

Sürüm `1.0`
-------------------------------

Resmi ilk sürüm

- [ ] Statik tipleme (Sorbet vb) olanaklarını kullan

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

Sürüm `1.0` sonrası
-------------------------------

Yeni özelliklerin planlanabileceği sürümler

- [ ] Sembollerde yeni nitelikler?
  * [ ] `Conflict` niteliği?
  * [ ] `Provides` niteliği?

- [ ] Yeni direktifler
  * [ ] `render`

- [ ] Pre-injection yoluyla seçilen bazı bağımlılıkların çekilmemesi

Gelecek
-------------------------------

Yeni baştan yazımı gerektirebilecek gelecek sürümler

- [ ] Git yoluyla kaynak yönetimini seçenek olarak ekle

- [ ] Go ile yeniden yaz?

- [ ] "Dependabot" tarzı bir servis yaz
