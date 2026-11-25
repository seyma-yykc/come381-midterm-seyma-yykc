# ER diyagramı: Kampüs Kütüphanesi

```mermaid
erDiagram
    MEMBER ||--o{ LOAN : "borrows"
    BOOK_COPY ||--o{ LOAN : "is lent in"
    BOOK ||--o{ BOOK_COPY : "has copies"
    BOOK ||--|{ BOOK_AUTHOR : "written by"
    AUTHOR ||--|{ BOOK_AUTHOR : "writes"

    MEMBER {
        int member_id PK
        string full_name
        string email
        string department
        string member_type
    }
    AUTHOR {
        int author_id PK
        string full_name
    }
    BOOK {
        int book_id PK
        string isbn
        string title
        string category
        int publish_year
    }
    BOOK_AUTHOR {
        int book_id PK, FK
        int author_id PK, FK
    }
    BOOK_COPY {
        int copy_id PK
        int book_id FK
        int copy_no
        string shelf_code
        string status
    }
    LOAN {
        int loan_id PK
        int member_id FK
        int copy_id FK
        date loan_date
        date due_date
        date return_date
    }
```

## Kardinaliteler

- Bir üye sıfır ya da çok ödünç alır; her ödünç tek bir üyeye aittir.
- Bir nüsha zaman içinde sıfır ya da çok kez ödünç verilir; her ödünç tek bir nüshaya aittir.
- Bir kitabın sıfır ya da çok nüshası olabilir (yeni sipariş edilen kitabın henüz nüshası yoktur); her nüsha tek bir kitaba aittir.
- Kitap ile yazar arasında M:N ilişki vardır ve `BOOK_AUTHOR` ara tablosuyla kurulur.
