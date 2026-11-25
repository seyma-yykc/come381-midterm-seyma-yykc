-- Kampüs Kütüphanesi: kitap ödünç takibi
-- Ödev 1: tablolar, primary key ve foreign key'ler.
-- NOT NULL / UNIQUE / CHECK ve isimli foreign key'ler Ödev 2'de week-05/constraints.sql ile eklenir.

DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS book_copy;
DROP TABLE IF EXISTS book_author;
DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;

CREATE TABLE member (
    member_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name   text,
    email       text,
    department  text,
    member_type text            -- 'student' veya 'staff'
);

CREATE TABLE author (
    author_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text
);

CREATE TABLE book (
    book_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    isbn         varchar(13),
    title        text,
    category     text,
    publish_year smallint
);

-- M:N: bir kitabın birden çok yazarı, bir yazarın birden çok kitabı olabilir.
CREATE TABLE book_author (
    book_id   integer REFERENCES book (book_id),
    author_id integer REFERENCES author (author_id),
    PRIMARY KEY (book_id, author_id)
);

-- Rafta duran fiziksel nüsha. Aynı kitabın birden çok nüshası olabilir.
CREATE TABLE book_copy (
    copy_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    book_id    integer REFERENCES book (book_id),
    copy_no    smallint,
    shelf_code text,
    status     text             -- 'available', 'on_loan', 'lost'
);

-- Bir üyenin bir nüshayı ödünç alması. Aynı üye aynı kitabı tekrar alabilir.
CREATE TABLE loan (
    loan_id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id   integer REFERENCES member (member_id),
    copy_id     integer REFERENCES book_copy (copy_id),
    loan_date   date,
    due_date    date,
    return_date date            -- henüz iade edilmediyse NULL
);
