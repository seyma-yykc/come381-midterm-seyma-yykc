-- Ödev 2, Bölüm A: iş kuralları. schema.sql'den sonra çalışır.

---------------------------------------------------------------
-- NOT NULL
---------------------------------------------------------------
-- Her üyenin adı, e-postası, bölümü ve üyelik türü bilinmek zorunda.
ALTER TABLE member ALTER COLUMN full_name   SET NOT NULL;
ALTER TABLE member ALTER COLUMN email       SET NOT NULL;
ALTER TABLE member ALTER COLUMN department  SET NOT NULL;
ALTER TABLE member ALTER COLUMN member_type SET NOT NULL;

-- Yazarın adı boş olamaz.
ALTER TABLE author ALTER COLUMN full_name SET NOT NULL;

-- Kitabın ISBN'i, adı, kategorisi ve basım yılı boş olamaz.
ALTER TABLE book ALTER COLUMN isbn         SET NOT NULL;
ALTER TABLE book ALTER COLUMN title        SET NOT NULL;
ALTER TABLE book ALTER COLUMN category     SET NOT NULL;
ALTER TABLE book ALTER COLUMN publish_year SET NOT NULL;

-- Her nüsha bir kitaba aittir, bir nüsha numarası ve durumu vardır. (Raf kodu henüz atanmamış olabilir.)
ALTER TABLE book_copy ALTER COLUMN book_id SET NOT NULL;
ALTER TABLE book_copy ALTER COLUMN copy_no SET NOT NULL;
ALTER TABLE book_copy ALTER COLUMN status  SET NOT NULL;

-- Her ödüncün üyesi, nüshası, veriliş tarihi ve son iade tarihi olmak zorunda. (return_date boş kalabilir: kitap henüz dönmedi.)
ALTER TABLE loan ALTER COLUMN member_id SET NOT NULL;
ALTER TABLE loan ALTER COLUMN copy_id   SET NOT NULL;
ALTER TABLE loan ALTER COLUMN loan_date SET NOT NULL;
ALTER TABLE loan ALTER COLUMN due_date  SET NOT NULL;

---------------------------------------------------------------
-- UNIQUE
---------------------------------------------------------------
-- İki üye aynı e-posta adresini kullanamaz.
ALTER TABLE member
  ADD CONSTRAINT uq_member_email UNIQUE (email);

-- Aynı ISBN ile iki farklı kitap kaydı açılamaz.
ALTER TABLE book
  ADD CONSTRAINT uq_book_isbn UNIQUE (isbn);

-- Bir kitabın aynı numaralı iki nüshası olamaz (1 numaralı nüsha tektir).
ALTER TABLE book_copy
  ADD CONSTRAINT uq_book_copy_book_copy_no UNIQUE (book_id, copy_no);

---------------------------------------------------------------
-- CHECK: tek sütunda aralık
---------------------------------------------------------------
-- Basım yılı matbaanın icadından (1450) önce ya da 2100'den sonra olamaz.
ALTER TABLE book
  ADD CONSTRAINT chk_book_publish_year
  CHECK (publish_year BETWEEN 1450 AND 2100);

-- Nüsha numaraları 1'den başlar.
ALTER TABLE book_copy
  ADD CONSTRAINT chk_book_copy_copy_no
  CHECK (copy_no > 0);

---------------------------------------------------------------
-- CHECK: izin verilen değerler
---------------------------------------------------------------
-- Üye ya öğrenci ya personeldir.
ALTER TABLE member
  ADD CONSTRAINT chk_member_type
  CHECK (member_type IN ('student', 'staff'));

-- Kütüphane yalnızca bu dört kategoride kitap tutar.
ALTER TABLE book
  ADD CONSTRAINT chk_book_category
  CHECK (category IN ('Roman', 'Tarih', 'Bilgisayar', 'Bilim'));

-- Bir nüsha ya rafta, ya ödünçte ya da kayıptır.
ALTER TABLE book_copy
  ADD CONSTRAINT chk_book_copy_status
  CHECK (status IN ('available', 'on_loan', 'lost'));

---------------------------------------------------------------
-- CHECK: iki sütunu karşılaştıran kurallar
---------------------------------------------------------------
-- Son iade tarihi, kitabın verildiği günden önce olamaz.
ALTER TABLE loan
  ADD CONSTRAINT chk_loan_due_order
  CHECK (due_date >= loan_date);

-- Kitap verildiği günden önce iade edilemez.
ALTER TABLE loan
  ADD CONSTRAINT chk_loan_return_order
  CHECK (return_date >= loan_date);

---------------------------------------------------------------
-- FOREIGN KEY: schema.sql'deki isimsiz FK'leri kaldırıp isimli ve silme politikalı olarak yeniden ekle
---------------------------------------------------------------
ALTER TABLE book_author DROP CONSTRAINT book_author_book_id_fkey;
ALTER TABLE book_author DROP CONSTRAINT book_author_author_id_fkey;
ALTER TABLE book_copy   DROP CONSTRAINT book_copy_book_id_fkey;
ALTER TABLE loan        DROP CONSTRAINT loan_member_id_fkey;
ALTER TABLE loan        DROP CONSTRAINT loan_copy_id_fkey;

-- Kitap-yazar eşleşmesi var olan bir kitaba ait olmalı; kitap silinince eşleşmeleri de silinir.
ALTER TABLE book_author
  ADD CONSTRAINT fk_book_author_book
  FOREIGN KEY (book_id) REFERENCES book (book_id) ON DELETE CASCADE;

-- Kitap-yazar eşleşmesi var olan bir yazara ait olmalı; kitabı olan bir yazar silinemez.
ALTER TABLE book_author
  ADD CONSTRAINT fk_book_author_author
  FOREIGN KEY (author_id) REFERENCES author (author_id) ON DELETE RESTRICT;

-- Her nüsha var olan bir kitaba ait olmalı; rafta nüshası olan bir kitap silinemez.
ALTER TABLE book_copy
  ADD CONSTRAINT fk_book_copy_book
  FOREIGN KEY (book_id) REFERENCES book (book_id) ON DELETE RESTRICT;

-- Ödünç var olan bir üyeye ait olmalı; ödünç geçmişi olan bir üye silinemez.
ALTER TABLE loan
  ADD CONSTRAINT fk_loan_member
  FOREIGN KEY (member_id) REFERENCES member (member_id) ON DELETE RESTRICT;

-- Ödünç var olan bir nüshaya ait olmalı; ödünç geçmişi olan nüsha silinemez (kayıpsa status = 'lost' yapılır).
ALTER TABLE loan
  ADD CONSTRAINT fk_loan_copy
  FOREIGN KEY (copy_id) REFERENCES book_copy (copy_id) ON DELETE NO ACTION;
