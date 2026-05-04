## الخطة النهائية: APK احترافي بشعار HN + كل الصلاحيات

### 🎯 الإعدادات النهائية المؤكدة
| البند | القيمة |
|---|---|
| النطاق الرئيسي | `https://hndriver.company` (Lovable, سنة) |
| Failover | hndriver.company → hn-driver.com → hn-driver.net |
| الأدوار المسموحة | customer / driver / delivery |
| اللغات | عربي / فرنسي / إنجليزي / إسباني (تلقائي حسب الجهاز) |
| الشعار | 👑 شعار HN الرسمي (التاج الذهبي) |
| الصلاحيات | كاملة (موقع، كاميرا، ميكروفون، إشعارات، تخزين، هاتف) |

### 1️⃣ Splash Screen بشعار HN الرسمي

سأستخدم نفس شعار الموقع (الذي يظهر في Header) ليكون Splash موحّداً بصرياً:

```text
┌─────────────────────────┐
│                         │
│     ╔═══════════╗       │
│     ║    👑     ║       │  ← شعار HN
│     ║   ذهبي    ║       │     (نفس شعار الموقع)
│     ╚═══════════╝       │
│                         │
│      HN Driver          │  ← خط Bold
│     النقل والتوصيل      │  ← فرعي بلغة الجهاز
│                         │
│   ●●●○○                 │  ← شريط تحميل
│   جاري الاتصال...       │
│                         │
└─────────────────────────┘
   خلفية: #111827 داكنة
```

- **الشعار**: نسخة من `/public/lovable-uploads/...` (شعار HN الذهبي الموجود)
- **Animation**: pulse ناعم على الشعار + شريط تحميل متحرك
- **متعدد اللغات**: النص يتغير حسب `navigator.language`

### 2️⃣ Failover (3 نطاقات)

```text
1. https://hndriver.company    🟢 PRIMARY
   ↓ فشل خلال 4s
2. https://www.hn-driver.com   Backup 1
   ↓ فشل
3. https://www.hn-driver.net   Backup 2
   ↓ فشل
شاشة "تحقق من الاتصال" + [إعادة المحاولة] بـ 4 لغات
```

النطاق الناجح يُحفظ 24 ساعة لتسريع الفتحات اللاحقة.

### 3️⃣ كل الصلاحيات Android (موجودة فعلاً)

✅ موجودة في `AndroidManifest.xml` حالياً:
- 📍 موقع GPS (foreground + background) — للسائقين
- 📷 كاميرا — للوثائق والصور
- 🎤 ميكروفون — للمكالمات
- 🔔 إشعارات + اهتزاز
- 📞 اتصال هاتفي
- 💾 تخزين الملفات
- 🔄 إعادة تشغيل تلقائي بعد إقلاع الجهاز
- 🔋 استثناء من توفير البطارية

### 4️⃣ قفل الأدوار

أي محاولة دخول بدور غير (customer/driver/delivery) تعرض شاشة تحويل مع رسالة بلغة المستخدم.

### 5️⃣ التعديلات

**ملفات جديدة:**
- `src/lib/domainFailover.ts`
- `src/lib/apkRoleGuard.ts`
- `android/app/src/main/assets/public/index.html` (Splash + شعار + failover)
- `android/app/src/main/assets/public/hn-logo.svg` (نسخة من شعار الموقع)

**ملفات معدّلة:**
- `capacitor.config.ts`
- `android/app/src/main/AndroidManifest.xml` (Deep Links لـ 3 نطاقات)
- `android/app/build.gradle` (versionCode 4, versionName "1.3")
- `src/App.tsx` (apkRoleGuard + كشف لغة الجهاز)
- `src/config/domain.ts` (APK_DOMAIN_PRIORITY)

### 6️⃣ بعد الموافقة — على ويندوز
```powershell
git pull
pnpm install
pnpm build
npx cap sync android
npx cap open android
```
ثم Android Studio → **Build → Build APK(s)**.

### ⚠️ التذكير المهم
بعد هذا الإصدار، **كل تحديثاتك المستقبلية** (واجهة، ميزات، أسعار، ترجمات، قاعدة بيانات) تصل تلقائياً عبر `Publish → Update` **بدون أي إعادة بناء APK**.