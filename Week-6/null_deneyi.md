# NULL deneyi

## Deney 1

```sql
SELECT COUNT(*), COUNT(phone) FROM customer;
```

- **Tahminim:** _(Sorguyu çalıştırmadan önce ne beklediğini kendi cümlenle yaz.)_
- **Sonuç:** `COUNT(*)` = 8, `COUNT(phone)` = 5.
- **Yorum:** `COUNT(*)` tablodaki tüm satırları sayar, `COUNT(phone)` ise yalnızca telefonu NULL olmayan satırları sayar. Mehmet Kaya, Can Arslan ve Selin Öztürk'ün telefonu NULL olduğu için 8 değil 5 çıktı.

## Deney 2

```sql
SELECT AVG(age), SUM(age) / COUNT(*) FROM customer;
```

- **Tahminim:** _(Sorguyu çalıştırmadan önce ne beklediğini kendi cümlenle yaz.)_
- **Sonuç:** `AVG(age)` = 20.83, `SUM(age) / COUNT(*)` = 15.
- **Yorum:** `AVG` NULL yaşları yok sayar: 125 / 6 = 20.83. İkinci ifade ise toplamı (125) yaşı boş olanlar dahil 8 kişiye böler; üstelik `integer / integer` tam sayı bölmesi olduğu için 15.625 yerine 15 verir. Elif Yıldız ve Can Arslan'ın yaşı NULL; NULL'ı sıfır gibi saymak ortalamayı yanlış biçimde düşürür.
