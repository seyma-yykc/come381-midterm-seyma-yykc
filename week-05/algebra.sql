-- Bölüm D: ilişkisel cebir sorularının SQL karşılıkları. seed.sql'den sonra çalışır.

-- D1 | σ + π | 1990 ve sonrasında basılmış Bilgisayar kitaplarının adları
SELECT title
FROM book
WHERE category = 'Bilgisayar' AND publish_year >= 1990;

-- D2 | ⋈ | Henüz iade edilmemiş ödünçlerin üye adı ve kitap adı
SELECT m.full_name, b.title, l.due_date
FROM loan l
JOIN member    m ON m.member_id = l.member_id
JOIN book_copy c ON c.copy_id   = l.copy_id
JOIN book      b ON b.book_id   = c.book_id
WHERE l.return_date IS NULL
ORDER BY l.due_date;

-- D3 | ∩ | Hem Roman hem Tarih kategorisinden kitap ödünç almış üyeler
SELECT m.full_name
FROM loan l
JOIN member m ON m.member_id = l.member_id
JOIN book_copy c ON c.copy_id = l.copy_id
JOIN book b ON b.book_id = c.book_id
WHERE b.category = 'Roman'
INTERSECT
SELECT m.full_name
FROM loan l
JOIN member m ON m.member_id = l.member_id
JOIN book_copy c ON c.copy_id = l.copy_id
JOIN book b ON b.book_id = c.book_id
WHERE b.category = 'Tarih';

-- D4a | − (EXCEPT) | Hiç kitap ödünç almamış üyeler
SELECT member_id, full_name FROM member
EXCEPT
SELECT m.member_id, m.full_name
FROM member m
JOIN loan l ON l.member_id = m.member_id;

-- D4b | − (NOT EXISTS) | Aynı soru
SELECT m.member_id, m.full_name
FROM member m
WHERE NOT EXISTS (
    SELECT 1 FROM loan l WHERE l.member_id = m.member_id
);

-- D5 | ρ + kendisiyle join | Aynı bölümde okuyan farklı üye çiftleri
SELECT m1.full_name AS member_1, m2.full_name AS member_2, m1.department
FROM member m1
JOIN member m2
  ON m1.department = m2.department
 AND m1.member_id < m2.member_id
ORDER BY m1.department;

-- D6 | ÷ | Bilgisayar kategorisindeki TÜM kitapları ödünç almış üyeler (iç içe iki NOT EXISTS)
SELECT m.full_name
FROM member m
WHERE NOT EXISTS (
    SELECT 1
    FROM book b
    WHERE b.category = 'Bilgisayar'
      AND NOT EXISTS (
          SELECT 1
          FROM loan l
          JOIN book_copy c ON c.copy_id = l.copy_id
          WHERE l.member_id = m.member_id
            AND c.book_id = b.book_id
      )
);
