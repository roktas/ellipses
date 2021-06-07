Sürüm
=====

- [ ] `CHANGELOG.md` düzenle

  ```sh
  git commit CHANGELOG.md -m "chore: Changelog for upcoming release"
  ```

- [ ] Sürüm numarasını arttır

- [ ] Bundle güncelle

  ```sh
  bundle install
  ```

- [ ] Testleri çalıştır

- [ ] Paketi inşa ve kontrol et

  ```sh
  rake build
  ```

- [ ] Varsa hataları düzelt

- [ ] Sürüm

  ```sh
  git commit -a -m "chore: Release x.x.x"
  ```

- [ ] Ana dala birleştir

  ```sh
  git checkout master
  git merge dev
  git checkout dev
  ```

- [ ] Paketi upload et

  ```sh
  gem push pkg/ellipses-x.x.x.gem
  ```

- [ ] Tag'le

  ```sh
  git tag -a x.x.x -m "Releasing version x.x.x"
  ```

- [ ] Değişiklikleri gönder

  ```sh
  git push
  git push --tags
  ```

- [ ] Github'ta release oluştur

- [ ] Temizle

  ```sh
  rake clean
  ```
