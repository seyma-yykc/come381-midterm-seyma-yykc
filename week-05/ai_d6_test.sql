-- Bölüm E: yapay zekanın D6 sorgusunu kendi verimizde test etme. seed.sql'den sonra çalışır.

-- 1) Yapay zekanın sorgusu (aynen)
SELECT m.full_name
FROM member m
JOIN loan l ON l.member_id = m.member_id
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b ON b.book_id = bc.book_id
WHERE b.category = 'Bilgisayar'
GROUP BY m.member_id, m.full_name
HAVING COUNT(DISTINCT b.book_id) = (SELECT COUNT(*) FROM book WHERE category = 'Bilgisayar');

-- 2) Aynı sorgu DISTINCT olmadan: Okan aynı kitabı iki kez aldığı için yanlışlıkla listeye girer
SELECT m.full_name
FROM member m
JOIN loan l ON l.member_id = m.member_id
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b ON b.book_id = bc.book_id
WHERE b.category = 'Bilgisayar'
GROUP BY m.member_id, m.full_name
HAVING COUNT(b.book_id) = (SELECT COUNT(*) FROM book WHERE category = 'Bilgisayar');

-- 3) Boş bölen durumu: 'Bilim' kategorisindeki tek kitap (Kozmos, nüshası yok) katalogdan kalkarsa
BEGIN;
DELETE FROM book WHERE book_id = 9;   -- book_author satırı CASCADE ile silinir, nüshası olmadığı için RESTRICT engellemez

-- 3a) Yapay zekanın sorgusu, kategori 'Bilim'
SELECT m.full_name
FROM member m
JOIN loan l ON l.member_id = m.member_id
JOIN book_copy bc ON bc.copy_id = l.copy_id
JOIN book b ON b.book_id = bc.book_id
WHERE b.category = 'Bilim'
GROUP BY m.member_id, m.full_name
HAVING COUNT(DISTINCT b.book_id) = (SELECT COUNT(*) FROM book WHERE category = 'Bilim');

-- 3b) İç içe NOT EXISTS, kategori 'Bilim'
SELECT m.full_name
FROM member m
WHERE NOT EXISTS (
    SELECT 1 FROM book b
    WHERE b.category = 'Bilim'
      AND NOT EXISTS (
          SELECT 1 FROM loan l JOIN book_copy c ON c.copy_id = l.copy_id
          WHERE l.member_id = m.member_id AND c.book_id = b.book_id));
ROLLBACK;
