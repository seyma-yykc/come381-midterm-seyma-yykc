# Silme politikası

| Foreign key | Ebeveyn → çocuk | Seçimim | Neden | Diğer seçenek neden olmadı |
|---|---|---|---|---|
| `fk_book_author_book` | book → book_author | `CASCADE` | `book_author` satırı yalnızca "bu kitabı bu yazar yazdı" bilgisini taşır; kitap katalogdan kalkınca bu bilginin anlamı kalmaz. | `RESTRICT` olsaydı her kitabı silmeden önce yazar eşleşmelerini elle silmek gerekirdi; bu yalnızca iş çıkarır, bir şeyi korumaz. |
| `fk_book_author_author` | author → book_author | `RESTRICT` | Kitabı olan bir yazar silinirse o kitaplar yazarsız kalır. Önce kitaplar düzenlenmeli. | `CASCADE` yazarı silince kitaplarının yazar bilgisini sessizce yok ederdi. |
| `fk_book_copy_book` | book → book_copy | `RESTRICT` | Rafta fiziksel nüshası olan bir kitap katalogdan silinemez; önce nüshalar kayıttan düşülmeli. | `CASCADE` nüshaları da silerdi; bu nüshaların ödünç geçmişi olduğu için zaten `fk_loan_copy` engellerdi, ama asıl sorun rafta duran kitabın kayıtsız kalması. |
| `fk_loan_member` | member → loan | `RESTRICT` | Ödünç geçmişi kütüphanenin kaydıdır (geç iadeler, kayıp kitaplar). Geçmişi olan üye silinemez; ayrılan üye için ileride bir `status` sütunu eklenebilir. | `CASCADE` üyeyi silince elinde iade edilmemiş kitabı olsa bile kaydı yok ederdi. `SET NULL` için `member_id` sütununun boş bırakılabilmesi gerekirdi; o da kimin aldığı bilinmeyen ödünç demek. |
| `fk_loan_copy` | book_copy → loan | `NO ACTION` | Ödünç geçmişi olan nüsha silinemez. Kaybolan nüsha silinmez, `status = 'lost'` yapılır. | `CASCADE` bir nüshayı silince onunla yapılmış bütün ödünçleri silerdi. |

Kullanılan politikalar: `CASCADE`, `RESTRICT`, `NO ACTION`.

## CASCADE kanıtı (`fk_book_author_book`)

`seed.sql` yüklendikten sonra, değişiklik kalıcı olmasın diye işlem içinde çalıştırıldı. Kozmos'un (book_id = 9) nüshası yok, tek bir yazarı var.

```
BEGIN;
SELECT count(*) AS book_count FROM book;
 book_count
------------
          9
SELECT count(*) AS book_author_count FROM book_author;
 book_author_count
-------------------
                10
DELETE FROM book WHERE book_id = 9;
DELETE 1
SELECT count(*) AS book_count FROM book;
 book_count
------------
          8
SELECT count(*) AS book_author_count FROM book_author;
 book_author_count
-------------------
                 9
ROLLBACK;
```

Kitap silinince `book_author` tablosundaki eşleşmesi de kendiliğinden silindi (10 → 9).

## `RESTRICT` ile `NO ACTION` farkı

`RESTRICT` ihlali silme anında hemen kontrol eder; `NO ACTION` ise kontrolü ifadenin sonuna bırakır ve constraint `DEFERRABLE` tanımlanmışsa işlemin sonuna kadar ertelenebilir. Ertelenmeyen bir constraint'te ikisi aynı hatayı (23503) verir.
