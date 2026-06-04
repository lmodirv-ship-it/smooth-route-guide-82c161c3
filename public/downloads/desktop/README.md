# HN Driver — تطبيقات Windows مع OTA

## التطبيقات المتاحة

| الدور | رابط التحميل |
|---|---|
| Admin | `/downloads/desktop/admin/HN-Admin-Setup.exe` |
| Supervisor | `/downloads/desktop/supervisor/HN-Supervisor-Setup.exe` |
| Call Center | `/downloads/desktop/callcenter/HN-CallCenter-Setup.exe` |

## كيف يعمل OTA (التحديث التلقائي)

1. المستخدم يحمّل `Setup.exe` **مرة واحدة فقط** ويثبّته على ويندوز
2. كل مرة يفتح التطبيق:
   - يفحص `latest.yml` على السيرفر بصمت
   - إذا وُجد إصدار أحدث → ينزّله في الخلفية
   - يظهر إشعار "تحديث جاهز" → إعادة تشغيل → التطبيق محدّث
3. **لا حاجة لإعادة التحميل اليدوي أبداً**

## كيف تطلق تحديثاً جديداً

في جهازك المحلي (يحتاج Windows أو Mac مع wine):

```bash
# 1. ارفع رقم الإصدار
# عدّل electron/admin/package.json → "version": "1.0.1"

# 2. ابنِ التطبيق
bash scripts/build-desktop-windows.sh

# 3. ادفع للسيرفر (السكريبت ينسخ تلقائياً إلى public/downloads/desktop/)
# عند نشر Lovable، الملفات تُرفع → جميع المستخدمين يتحدّثون تلقائياً
```

## ملاحظات

- **محتوى الواجهة:** التطبيق يفتح `admin.hndriver.company` / `call.hndriver.company` مباشرة → أي تعديل واجهة ينعكس فوراً بدون OTA حتى
- **OTA يُستخدم فقط** عند تغيير: الأيقونة، اسم التطبيق، صلاحيات Electron، أو ترقية Electron نفسه
- يجب وضع `icon.ico` (256x256) في `electron/<role>/` قبل البناء
