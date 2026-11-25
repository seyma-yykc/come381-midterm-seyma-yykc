# Yapay zeka kullanım günlüğü

## Ödev 1

Senaryo seçimi, ER diyagramı (Mermaid), `schema.sql` ve README, Claude (Claude Code) ile hazırlandı. Şema temiz bir PostgreSQL 16 veritabanında hatasız çalıştırıldı. İlk çizimde kitap ile nüsha arasındaki kardinalite "her kitabın en az bir nüshası var" (`||--|{`) olarak yazılmıştı; nüshası henüz gelmemiş kitap (Kozmos) da tutulabilmeli diye `||--o{` olarak düzeltildi.

## Ödev 2

### D6 denemesi

**Araç:** Claude Haiku

**Prompt (aynen):**

> PostgreSQL'de şu tablolarım var:
>
> member(member_id, full_name, email, department, member_type)
> book(book_id, isbn, title, category, publish_year)
> book_copy(copy_id, book_id, copy_no, shelf_code, status)
> loan(loan_id, member_id, copy_id, loan_date, due_date, return_date)
>
> Bir kitabın birden çok nüshası (book_copy) olabilir, ödünç (loan) nüshaya bağlı. 'Bilgisayar' kategorisindeki tüm kitapları ödünç almış üyelerin adlarını bulan SQL sorgusunu yazar mısın?

**Gelen sorgu:**

```sql
SELECT m.full_name
FROM member m
JOIN loan l ON l.member_id = m.member_id
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b ON b.book_id = bc.book_id
WHERE b.category = 'Bilgisayar'
GROUP BY m.member_id, m.full_name
HAVING COUNT(DISTINCT b.book_id) = (SELECT COUNT(*) FROM book WHERE category = 'Bilgisayar');
```

**Kendi verimde sonuç:** `Zehra Koç`. Benim iç içe `NOT EXISTS` sorgum da aynı sonucu verdi, yani bu veride sorgu doğru.

**Yanıltacak veri arayışı:** `seed.sql`'de Okan Aydın aynı kitabı (Introduction to Algorithms) iki kez ödünç aldı, Clean Code'u hiç almadı. Bilgisayar ödünç sayısı 3, toplam Bilgisayar kitabı da 3. Yapay zekanın sorgusu `COUNT(DISTINCT b.book_id)` kullandığı için bu tuzağa düşmedi. Aynı sorguyu `DISTINCT` olmadan çalıştırınca (`ai_d6_test.sql`, sorgu 2) sonuç `Zehra Koç, Okan Aydın` oldu: Okan yanlışlıkla listeye girdi.

**Bulunan fark: boş bölen.** Katalogda hiç kitabı olmayan bir kategori için iki sorgu farklı davranıyor. `ai_d6_test.sql` 3. bölümde, işlem içinde 'Bilim' kategorisinin tek kitabı (Kozmos) silindi ve iki sorgu 'Bilim' için çalıştırıldı:

| Sorgu | Sonuç |
|---|---|
| Yapay zekanın `GROUP BY ... HAVING COUNT` sorgusu | 0 satır |
| İç içe `NOT EXISTS` | 8 satır (bütün üyeler) |

Cebirde bölen boş küme olduğunda `R ÷ ∅` bütün adayları döndürür ("okumadığı bir kitap yok" koşulunu herkes boş yere sağlar). Yapay zekanın sorgusu ise önce `JOIN` ve `WHERE` ile o kategoride ödüncü olmayanları attığı için kimseyi döndürmüyor. Yani bu sorgu division'ın tam karşılığı değil. İş açısından "kategoride kitap yoksa kimse listelenmesin" daha mantıklı olabilir; ama hangisi istenirse istensin, bunun bilerek seçilmesi gerekiyor.

### Ödevin geri kalanı

Constraint'ler, ihlal testleri, seed verisi, cebir ifadeleri ve açıklamalar Claude (Claude Code) ile hazırlandı ve PostgreSQL 16'da çalıştırılarak doğrulandı. İlk sürümde üç sınır testi id'leri elle yazdığı için yanlış hata veriyordu (başarısız `INSERT`'ler identity sayacını ilerletiyor); alt sorguyla düzeltildi (`week-05/README.md`).
