-- Bölüm D için küçük veri seti. violations.sql'den sonra çalışır; önce tabloları boşaltır.
TRUNCATE loan, book_copy, book_author, author, book, member RESTART IDENTITY CASCADE;

INSERT INTO member (full_name, email, department, member_type) VALUES
  ('Ayşe Yılmaz',  'ayse@uni.edu.tr',   'YBS',                 'student'),  -- 1
  ('Mert Demir',   'mert@uni.edu.tr',   'YBS',                 'student'),  -- 2
  ('Zehra Koç',    'zehra@uni.edu.tr',  'Bilgisayar Mühendisliği', 'student'),  -- 3
  ('Okan Aydın',   'okan@uni.edu.tr',   'Bilgisayar Mühendisliği', 'student'),  -- 4
  ('Derya Şen',    'derya@uni.edu.tr',  'İşletme',             'student'),  -- 5
  ('Kerem Polat',  'kerem@uni.edu.tr',  'İşletme',             'staff'),    -- 6
  ('Nihan Acar',   'nihan@uni.edu.tr',  'Hukuk',               'student'),  -- 7
  ('Tolga Er',     'tolga@uni.edu.tr',  'Psikoloji',           'student');  -- 8 (hiç ödünç almadı)

INSERT INTO author (full_name) VALUES
  ('Orhan Pamuk'),        -- 1
  ('Sabahattin Ali'),     -- 2
  ('İlber Ortaylı'),      -- 3
  ('Halil İnalcık'),      -- 4
  ('Thomas H. Cormen'),   -- 5
  ('Ramez Elmasri'),      -- 6
  ('Shamkant Navathe'),   -- 7
  ('Robert C. Martin'),   -- 8
  ('Carl Sagan');         -- 9

INSERT INTO book (isbn, title, category, publish_year) VALUES
  ('9789750800001', 'Kar',                                 'Roman',      2002),  -- 1
  ('9789750800002', 'Masumiyet Müzesi',                    'Roman',      2008),  -- 2
  ('9789750800003', 'Kürk Mantolu Madonna',                'Roman',      1943),  -- 3
  ('9789750800004', 'Osmanlı''yı Yeniden Keşfetmek',       'Tarih',      2006),  -- 4
  ('9789750800005', 'Osmanlı İmparatorluğu Klasik Çağ',    'Tarih',      1973),  -- 5
  ('9780262033848', 'Introduction to Algorithms',          'Bilgisayar', 1990),  -- 6
  ('9780133970777', 'Fundamentals of Database Systems',    'Bilgisayar', 1989),  -- 7
  ('9780132350884', 'Clean Code',                          'Bilgisayar', 2008),  -- 8
  ('9780345539434', 'Kozmos',                              'Bilim',      1980);  -- 9 (sipariş edildi, henüz nüshası yok)

INSERT INTO book_author (book_id, author_id) VALUES
  (1, 1), (2, 1), (3, 2), (4, 3), (5, 4), (6, 5), (7, 6), (7, 7), (8, 8), (9, 9);

INSERT INTO book_copy (book_id, copy_no, shelf_code, status) VALUES
  (1, 1, 'R-01', 'available'),  -- 1
  (2, 1, 'R-02', 'available'),  -- 2
  (3, 1, 'R-03', 'available'),  -- 3
  (3, 2, 'R-03', 'available'),  -- 4
  (4, 1, 'T-01', 'available'),  -- 5
  (5, 1, 'T-02', 'on_loan'),    -- 6
  (6, 1, 'B-01', 'on_loan'),    -- 7
  (6, 2, 'B-01', 'on_loan'),    -- 8
  (7, 1, 'B-02', 'available'),  -- 9
  (7, 2, 'B-02', 'available'),  -- 10
  (8, 1, 'B-03', 'on_loan');    -- 11

INSERT INTO loan (member_id, copy_id, loan_date, due_date, return_date) VALUES
  (1, 1,  '2026-10-01', '2026-10-15', '2026-10-12'),  -- Ayşe: Kar (Roman)
  (1, 5,  '2026-10-03', '2026-10-17', '2026-10-16'),  -- Ayşe: Osmanlı'yı Yeniden Keşfetmek (Tarih)
  (1, 7,  '2026-10-20', '2026-11-03', NULL),          -- Ayşe: Introduction to Algorithms
  (2, 3,  '2026-10-02', '2026-10-16', '2026-10-10'),  -- Mert: Kürk Mantolu Madonna
  (2, 9,  '2026-10-21', '2026-11-04', '2026-11-01'),  -- Mert: Fundamentals of Database Systems
  (3, 7,  '2026-10-01', '2026-10-15', '2026-10-14'),  -- Zehra: Introduction to Algorithms
  (3, 10, '2026-10-05', '2026-10-19', '2026-10-18'),  -- Zehra: Fundamentals of Database Systems
  (3, 11, '2026-10-10', '2026-10-24', NULL),          -- Zehra: Clean Code  -> 3 bilgisayar kitabının hepsi
  (4, 8,  '2026-10-02', '2026-10-16', '2026-10-15'),  -- Okan: Introduction to Algorithms
  (4, 8,  '2026-10-25', '2026-11-08', NULL),          -- Okan: aynı kitabı ikinci kez aldı
  (4, 9,  '2026-10-06', '2026-10-20', '2026-10-19'),  -- Okan: Fundamentals of Database Systems (Clean Code eksik -> "neredeyse" aday)
  (5, 2,  '2026-10-04', '2026-10-18', '2026-10-17'),  -- Derya: Masumiyet Müzesi (Roman)
  (5, 6,  '2026-10-08', '2026-10-22', NULL),          -- Derya: Osmanlı İmparatorluğu Klasik Çağ (Tarih)
  (6, 5,  '2026-10-18', '2026-11-01', '2026-10-30'),  -- Kerem: Osmanlı'yı Yeniden Keşfetmek (Tarih)
  (6, 4,  '2026-10-11', '2026-10-25', '2026-10-24'),  -- Kerem: Kürk Mantolu Madonna (Roman)
  (7, 1,  '2026-10-14', '2026-10-28', '2026-10-27');  -- Nihan: Kar
