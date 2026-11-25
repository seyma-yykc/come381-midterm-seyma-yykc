# COME 381 Vize Projesi: Kampüs Kütüphanesi

Senaryo: Üniversitenin kampüs kütüphanesi kitaplarını, bu kitapların raftaki nüshalarını, yazarlarını ve öğrenci ile personelin yaptığı ödünç alma işlemlerini takip etmek istiyor. Veritabanında altı tablo var: `member`, `book`, `author`, `book_author`, `book_copy` ve `loan`.

Tasarım kararı: Kitap (`book`) ile raftaki fiziksel nüshayı (`book_copy`) ayırdım. Kütüphanede aynı kitabın birden çok nüshası olabiliyor ve ödünç verilen şey kitabın kendisi değil, o nüshalardan biri. Bu yüzden `loan`, `book` tablosuna değil `book_copy` tablosuna bağlı. Kitap ile yazar arasındaki ilişki M:N olduğu için `book_author` ara tablosunu açtım; birincil anahtarı iki sütunun birleşimi.

## Klasörler

- `docs/er.md`: ER diyagramı (Mermaid)
- `sql/schema.sql`: tablolar (Ödev 1)
- `week-05/`: constraint'ler, ihlal testleri, silme politikası, ilişkisel cebir (Ödev 2); çalıştırma sırası `week-05/README.md` içinde
