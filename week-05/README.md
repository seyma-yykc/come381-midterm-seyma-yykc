# Ödev 2: Constraint'ler, ihlal testleri ve ilişkisel cebir

## Çalıştırma sırası

```bash
psql -d come381 -f sql/schema.sql
psql -d come381 -f week-05/constraints.sql
psql -d come381 -f week-05/violations.sql > week-05/violations_output.txt 2>&1
psql -d come381 -f week-05/seed.sql
psql -d come381 -f week-05/algebra.sql
psql -d come381 -f week-05/ai_d6_test.sql
```

`violations.sql` tabloları boşaltarak başladığı için `seed.sql` ondan sonra çalışır. Windows'ta komutlara `-U postgres` ekle.

## NULL testi (T17)

`loan.return_date` sütununda `CHECK (return_date >= loan_date)` var ama `NOT NULL` yok. `return_date` NULL iken kural `NULL >= '2026-10-25'` olur; bunun sonucu ne true ne false, UNKNOWN'dur. `CHECK` yalnızca sonuç false olduğunda satırı reddeder, UNKNOWN'u kabul eder; bu yüzden satır eklendi. Bu senaryoda istediğimiz de bu: kitap henüz iade edilmediyse iade tarihi boş kalmalı.

## Beklediğimden farklı çıkan şey

İlk denemede sınır testlerinde (T10, T15, T17) id'leri elle yazmıştım (`book_id = 2`, `copy_id = 2`) ve testler beklenmeyen bir foreign key hatası verdi. Sebebi: başarısız olan `INSERT`'ler de identity sayacını ilerletiyor, yani 2 numara hata veren satıra "harcanmıştı". Testleri id yerine `(SELECT ... WHERE isbn = ...)` alt sorgusuyla yazınca düzeldi.

T20'de bir üyenin id'sini değiştirerek foreign key'i bozmayı denedim ama `member_id` `GENERATED ALWAYS AS IDENTITY` olduğu için PostgreSQL daha foreign key'e gelmeden `428C9` hatası verdi. Foreign key'in ebeveyn tarafı T19'da (`DELETE`) test edildi.

## Tek tabloya sığmayan kural

"Bir nüsha aynı anda iki kişide olamaz" (iade edilmemiş iki ödünç aynı `copy_id`'yi gösteremez) ve "ödünçteki nüshanın `status` değeri `on_loan` olmalı" kuralları birden çok satıra ya da tabloya bakıyor; `CHECK` ile yazılamıyor. Hafta 8'de trigger ile eklenecek.
