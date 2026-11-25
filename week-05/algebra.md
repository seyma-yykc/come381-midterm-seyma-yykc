# İlişkisel cebir ve hesap

Kısaltmalar: `M = member`, `B = book`, `C = book_copy`, `L = loan`. SQL karşılıkları `algebra.sql` dosyasında aynı numarayla. Sonuçlar `seed.sql` verisiyle alındı.

Yardımcı ifade (D2, D3 ve D6'da kullanılıyor): bir ödüncü üyeye ve kitaba bağlayan birleşim

```
LB ← L ⋈ C ⋈ B          (L.copy_id = C.copy_id, C.book_id = B.book_id)
```

## D1: σ ve π

**Soru:** 1990 ve sonrasında basılmış Bilgisayar kitaplarının adları.

```
π title ( σ category='Bilgisayar' ∧ publish_year≥1990 (B) )
```

| title |
|---|
| Introduction to Algorithms |
| Clean Code |

**DISTINCT:** Gerekli değil. Bu veride aynı adlı iki kitap yok; yine de cebirdeki π tekrarları sileceği için tam karşılık `SELECT DISTINCT title` olurdu.

**İlişkisel hesap (tuple relational calculus):**

```
{ t.title | book(t) ∧ t.category = 'Bilgisayar' ∧ t.publish_year ≥ 1990 }
```

## D2: ⋈ join

**Soru:** Henüz iade edilmemiş ödünçlerin üye adı ve kitap adı.

```
π full_name, title, due_date ( σ return_date IS NULL ( M ⋈ LB ) )
```

| full_name | title | due_date |
|---|---|---|
| Derya Şen | Osmanlı İmparatorluğu Klasik Çağ | 2026-10-22 |
| Zehra Koç | Clean Code | 2026-10-24 |
| Ayşe Yılmaz | Introduction to Algorithms | 2026-11-03 |
| Okan Aydın | Introduction to Algorithms | 2026-11-08 |

**DISTINCT:** Gerekli değil. Her satır ayrı bir ödünç; aynı kişi aynı kitabı iki kez almış olsa bile bunlar iki ayrı kayıttır ve ikisi de görünmeli.

## D3: ∩ intersection

**Soru:** Hem Roman hem Tarih kategorisinden kitap ödünç almış üyeler.

```
π full_name ( σ category='Roman' ( M ⋈ LB ) )  ∩  π full_name ( σ category='Tarih' ( M ⋈ LB ) )
```

| full_name |
|---|
| Kerem Polat |
| Ayşe Yılmaz |
| Derya Şen |

**DISTINCT:** Gerekli değil; `INTERSECT` küme işlemidir ve tekrarları kendisi siler. Not: Karşılaştırma ad üzerinden yapıldığı için aynı adlı iki üye tek kişi gibi görünürdü; daha güvenlisi her iki tarafa `member_id` eklemek.

## D4: − difference

**Soru:** Hiç kitap ödünç almamış üyeler.

```
π member_id, full_name (M)  −  π member_id, full_name ( M ⋈ L )
```

| member_id | full_name |
|---|---|
| 8 | Tolga Er |

İki yoldan yazıldı: `EXCEPT` (D4a) ve `NOT EXISTS` (D4b). İkisi de aynı tek satırı döndürdü.

**DISTINCT:** Gerekli değil. `EXCEPT` küme işlemidir; `NOT EXISTS` sürümünde ise her üye `member` tablosundan bir kez gelir.

**İlişkisel hesap:**

```
{ m.member_id, m.full_name | member(m) ∧ ¬∃ l ( loan(l) ∧ l.member_id = m.member_id ) }
```

## D5: ρ ile tablonun kendisiyle join'i

**Soru:** Aynı bölümde okuyan farklı üye çiftleri.

```
π M1.full_name, M2.full_name, M1.department (
    ρ M1(M)  ⋈ M1.department = M2.department ∧ M1.member_id < M2.member_id  ρ M2(M) )
```

| member_1 | member_2 | department |
|---|---|---|
| Zehra Koç | Okan Aydın | Bilgisayar Mühendisliği |
| Derya Şen | Kerem Polat | İşletme |
| Ayşe Yılmaz | Mert Demir | YBS |

**DISTINCT:** Gerekli değil. `member_id <` koşulu her çifti bir kez getiriyor; `<>` kullansaydım (Ayşe, Mert) ve (Mert, Ayşe) iki ayrı satır olurdu.

## D6: ÷ division

**Soru:** Bilgisayar kategorisindeki **tüm** kitapları ödünç almış üyeler.

```
π member_id, book_id ( LB )  ÷  π book_id ( σ category='Bilgisayar' (B) )
```

Sonuç üye id'si olarak döner; ada çevirmek için `M` ile join yapılır.

| full_name |
|---|
| Zehra Koç |

"Neredeyse" aday Okan Aydın: Introduction to Algorithms'i iki kez, Fundamentals of Database Systems'ı bir kez aldı ama Clean Code'u hiç almadı. Doğru sorgu onu eliyor.

**Neden iç içe NOT EXISTS:** "Okumadığı bir Bilgisayar kitabı olmayan üye" cümlesinin doğrudan çevirisi olduğu için seçtim; `COUNT` ile yazılan sürüm ise aynı kitabın iki kez alınmasında `DISTINCT` unutulursa yanlış sayıyor (bkz. `AI_LOG.md`).

**DISTINCT:** Gerekli değil; her üye `member` tablosundan bir kez geliyor.
