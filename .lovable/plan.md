
## الهدف
زيادة التحويل من "زائر" إلى "مسجّل" عبر إزالة العوائق:
1. **Google ضغطة واحدة** متاح مباشرة من الصفحة الرئيسية (لا من داخل `/auth/client` فقط).
2. **رابط UTM جاهز** يصل بالزائر مباشرة إلى صفحة التسجيل مع تتبع المصدر.

---

## التغييرات

### 1. زر "تسجيل بـ Google" في الـ Hero بالصفحة الرئيسية
**الملف:** `src/pages/LandingPage.tsx` (داخل قسم Hero، تحت `VideoShowcaseSection`)

إضافة بطاقة CTA بارزة قبل بطاقات الأدوار:
- زر أخضر/ذهبي كبير: **"🎉 سجّل بضغطة واحدة عبر Google — احصل على 50 درهم مجاناً"**
- يستدعي `lovable.auth.signInWithOAuth("google", { redirect_uri: window.location.origin })` مباشرة
- تتبّع `trackEvent("signup_google_oneclick_landing")` للقياس
- زر صغير ثانوي: "تسجيل بالبريد الإلكتروني" → `navigate("/auth/client")`

### 2. تثبيت زر "Google" في الشريط العلوي (Desktop + Mobile)
بدل/بجانب زر "🎉 سجّل مجاناً" الحالي → زر Google مباشر بنفس المنطق، حتى الزائر الذي لا يمرّر للأسفل يراه.

### 3. منطق ما بعد Google OAuth (مهم)
بعد عودة المستخدم من Google، `AuthPage` يتعامل مع الجلسة عبر `useAuthReady` ويوجّه للوحة المناسبة. 
سنضيف في `LandingPage` كود `useEffect` خفيف: إذا كانت هناك جلسة نشطة (عودة من OAuth)، نعيد التوجيه إلى `/customer` تلقائياً.

### 4. صفحة "صانع روابط UTM" — توليد رابط جاهز للحملة
**الملف:** `src/admin/pages/UtmBuilder.tsx` (موجود مسبقاً)

التحقق أنه يولّد روابط بصيغة:
```
https://www.hn-driver.com/auth/client?utm_source=facebook&utm_medium=cpc&utm_campaign=signup_50dh
```
وأن `VisitorCounter` (الذي يستدعي `record_visit`) يلتقط هذه الـ UTMs (مؤكد أنه يفعل).

سنضيف **قالب جاهز** بزر واحد في `UtmBuilder`: 
- "📱 حملة فيسبوك للتسجيل" → ينسخ رابط `/auth/client` مع UTM معبّأة مسبقاً
- "📱 حملة إنستغرام للتسجيل"
- "📱 حملة Google Ads"

---

## القياس
بعد التطبيق، سنتمكن من قراءة في `/admin/campaigns`:
- زيارات `/auth/client` (ستكون > 0 لأول مرة)
- معدل التحويل لكل قناة UTM
- نقرات زر Google في `site_visits` (عبر `trackEvent`)

---

## الملفات المتأثرة
- `src/pages/LandingPage.tsx` — إضافة CTA Google في Hero والشريط
- `src/admin/pages/UtmBuilder.tsx` — قوالب UTM جاهزة لصفحة `/auth/client`

لا تغييرات في قاعدة البيانات. لا حاجة لمفاتيح جديدة (Google OAuth مُدار من Lovable Cloud).

---

## الحرس على الـ UI Lockdown
هذا تعديل **مطلوب صراحة من المستخدم** (لتقليل الاحتكاك)، لذا يندرج تحت الاستثناء المسموح به.
