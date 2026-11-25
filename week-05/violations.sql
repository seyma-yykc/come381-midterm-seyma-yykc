\set VERBOSITY verbose

-- Hazırlık: tabloları boşalt, testlerin ihtiyaç duyduğu birkaç satırı ekle.
TRUNCATE loan, book_copy, book_author, author, book, member RESTART IDENTITY CASCADE;

INSERT INTO member (full_name, email, department, member_type)
VALUES ('Ayşe Yılmaz', 'ayse@uni.edu.tr', 'YBS', 'student');                    -- member_id = 1
INSERT INTO author (full_name) VALUES ('Orhan Pamuk');                            -- author_id = 1
INSERT INTO book (isbn, title, category, publish_year)
VALUES ('9789750800001', 'Kar', 'Roman', 2002);                                   -- book_id = 1
INSERT INTO book_author (book_id, author_id) VALUES (1, 1);
INSERT INTO book_copy (book_id, copy_no, shelf_code, status)
VALUES (1, 1, 'R-01', 'on_loan');                                                -- copy_id = 1
INSERT INTO loan (member_id, copy_id, loan_date, due_date)
VALUES (1, 1, '2026-10-01', '2026-10-15');                                        -- loan_id = 1

-- T01 | member.full_name NOT NULL | Beklenen: 23502
INSERT INTO member (full_name, email, department, member_type)
VALUES (NULL, 'isimsiz@uni.edu.tr', 'YBS', 'student');

-- T02 | loan.due_date NOT NULL | Beklenen: 23502
INSERT INTO loan (member_id, copy_id, loan_date, due_date)
VALUES (1, 1, '2026-10-20', NULL);

-- T03 | uq_member_email | Beklenen: 23505
INSERT INTO member (full_name, email, department, member_type)
VALUES ('Ayşe Yılmaz (kopya)', 'ayse@uni.edu.tr', 'YBS', 'student');

-- T04 | uq_book_isbn | Beklenen: 23505
INSERT INTO book (isbn, title, category, publish_year)
VALUES ('9789750800001', 'Kar (ikinci kayıt)', 'Roman', 2002);

-- T05 | uq_book_copy_book_copy_no (çok sütunlu) | Beklenen: 23505
INSERT INTO book_copy (book_id, copy_no, shelf_code, status)
VALUES (1, 1, 'R-02', 'available');

-- T06 | uq_book_copy_book_copy_no | Beklenen: OK (aynı kitabın 2 numaralı nüshası)
INSERT INTO book_copy (book_id, copy_no, shelf_code, status)
VALUES (1, 2, 'R-02', 'available');

-- T07 | chk_book_publish_year | Beklenen: 23514
INSERT INTO book (isbn, title, category, publish_year)
VALUES ('9780000000007', 'Gelecekten Gelen Kitap', 'Roman', 2150);

-- T08 | chk_book_publish_year | Beklenen: OK (sınır: 1450)
INSERT INTO book (isbn, title, category, publish_year)
VALUES ('9780000000008', 'İlk Basılı Kitap', 'Tarih', 1450);

-- T09 | chk_book_copy_copy_no | Beklenen: 23514
INSERT INTO book_copy (book_id, copy_no, shelf_code, status)
VALUES (1, 0, 'R-03', 'available');

-- T10 | chk_book_copy_copy_no | Beklenen: OK (sınır: 1; T08'de eklenen kitabın ilk nüshası)
-- Not: id'yi elle yazmıyoruz; başarısız INSERT'ler de identity sayacını ilerletir.
INSERT INTO book_copy (book_id, copy_no, shelf_code, status)
VALUES ((SELECT book_id FROM book WHERE isbn = '9780000000008'), 1, 'T-01', 'available');

-- T11 | chk_member_type | Beklenen: 23514
INSERT INTO member (full_name, email, department, member_type)
VALUES ('Misafir Okur', 'misafir@uni.edu.tr', 'YBS', 'guest');

-- T12 | chk_book_category | Beklenen: 23514
INSERT INTO book (isbn, title, category, publish_year)
VALUES ('9780000000012', 'Futbol Taktikleri', 'Spor', 2015);

-- T13 | chk_book_copy_status | Beklenen: 23514
UPDATE book_copy SET status = 'damaged' WHERE copy_id = 1;

-- T14 | chk_loan_due_order | Beklenen: 23514
INSERT INTO loan (member_id, copy_id, loan_date, due_date)
VALUES (1, (SELECT copy_id FROM book_copy WHERE book_id = 1 AND copy_no = 2), '2026-10-20', '2026-10-10');

-- T15 | chk_loan_due_order | Beklenen: OK (sınır: aynı gün verilip aynı gün iadesi beklenen ödünç)
INSERT INTO loan (member_id, copy_id, loan_date, due_date)
VALUES (1, (SELECT copy_id FROM book_copy WHERE book_id = 1 AND copy_no = 2), '2026-10-20', '2026-10-20');

-- T16 | chk_loan_return_order | Beklenen: 23514
UPDATE loan SET return_date = '2026-09-30' WHERE loan_id = 1;

-- T17 | chk_loan_return_order + NULL | Beklenen: OK (return_date NULL, CHECK sonucu UNKNOWN; reddedilmez)
INSERT INTO loan (member_id, copy_id, loan_date, due_date, return_date)
VALUES (1, (SELECT copy_id FROM book_copy WHERE book_id = 1 AND copy_no = 2), '2026-10-25', '2026-11-08', NULL);

-- T18 | fk_loan_member (çocuktan: olmayan üye) | Beklenen: 23503
INSERT INTO loan (member_id, copy_id, loan_date, due_date)
VALUES (999, 1, '2026-10-20', '2026-11-03');

-- T19 | fk_loan_member (ebeveynden: ödünç geçmişi olan üyeyi silmek) | Beklenen: 23503
DELETE FROM member WHERE member_id = 1;

-- T20 | member_id (ebeveynden: üyenin id'sini değiştirmek) | Beklenen: 428C9
-- member_id GENERATED ALWAYS AS IDENTITY olduğu için PostgreSQL id'nin elle değiştirilmesine FK'ye gelmeden izin vermez.
UPDATE member SET member_id = 50 WHERE member_id = 1;

-- T21 | fk_loan_copy | Beklenen: 23503
INSERT INTO loan (member_id, copy_id, loan_date, due_date)
VALUES (1, 999, '2026-10-20', '2026-11-03');

-- T22 | fk_book_copy_book | Beklenen: 23503
INSERT INTO book_copy (book_id, copy_no, shelf_code, status)
VALUES (999, 1, 'X-01', 'available');

-- T23 | fk_book_copy_book (ebeveynden: nüshası olan kitabı silmek) | Beklenen: 23503
DELETE FROM book WHERE book_id = 1;

-- T24 | fk_book_author_author (ebeveynden: kitabı olan yazarı silmek) | Beklenen: 23503
DELETE FROM author WHERE author_id = 1;

-- T25 | fk_book_author_book | Beklenen: 23503
INSERT INTO book_author (book_id, author_id) VALUES (999, 1);
