/**
 * Terms & Conditions Page
 */
import { useNavigate } from "react-router-dom";
import { ArrowRight, FileText, UserCheck, CreditCard, AlertTriangle, Ban, Scale, Mail } from "lucide-react";
import { Button } from "@/components/ui/button";

const sections = [
  {
    icon: FileText,
    title: "مقدمة",
    content: `مرحباً بك في HN Driver. باستخدامك لتطبيقاتنا وخدماتنا، فإنك توافق على الالتزام بالشروط والأحكام التالية. يُرجى قراءتها بعناية قبل استخدام أي من خدماتنا (نقل الأشخاص، التوصيل، التجارة الإلكترونية، إدارة المخزون).`,
  },
  {
    icon: UserCheck,
    title: "الأهلية والتسجيل",
    content: `• يجب أن يكون عمرك 18 سنة أو أكثر لاستخدام الخدمات.
• يجب تقديم معلومات صحيحة ودقيقة عند التسجيل.
• أنت مسؤول عن الحفاظ على سرية بيانات حسابك.
• يحق لنا تعليق أو إلغاء أي حساب يخالف الشروط.`,
  },
  {
    icon: CreditCard,
    title: "المدفوعات والعمولات",
    content: `• تُدفع جميع الرسوم بالعملة المحلية (درهم مغربي).
• عمولة المنصة: 5% على رحلات النقل والتوصيل، و 5-10% على طلبات المتاجر.
• تتم معالجة المدفوعات الإلكترونية عبر بوابات آمنة (Stripe, PayPal).
• الاسترداد يخضع لسياسة الاسترجاع المعلنة في التطبيق.`,
  },
  {
    icon: AlertTriangle,
    title: "مسؤولية المستخدم",
    content: `• يُمنع استخدام الخدمة لأي غرض غير قانوني.
• يلتزم السائقون والتجار باحترام جميع القوانين المحلية.
• يتحمل المستخدم مسؤولية البضائع/الأمتعة الخاصة به.
• يُمنع التحرش أو الإساءة لأي طرف على المنصة.`,
  },
  {
    icon: Ban,
    title: "الإيقاف والإلغاء",
    content: `• يحق لنا إيقاف أي حساب يخالف هذه الشروط دون إشعار مسبق.
• في حالات الاحتيال، يتم تحويل الحساب إلى الجهات المختصة.
• يمكن للمستخدم حذف حسابه في أي وقت من الإعدادات.`,
  },
  {
    icon: Scale,
    title: "حدود المسؤولية والقانون المطبّق",
    content: `• تُقدَّم الخدمة "كما هي" دون أي ضمانات صريحة أو ضمنية.
• HN Driver ليست مسؤولة عن أي أضرار غير مباشرة قد تنتج عن استخدام الخدمة.
• تخضع هذه الشروط لقوانين المملكة المغربية، والمحاكم المختصة في طنجة.`,
  },
  {
    icon: Mail,
    title: "تواصل معنا",
    content: `لأي استفسار حول الشروط والأحكام:
• البريد الإلكتروني: legal@hn-driver.com
• الهاتف: +212 539 000 000
• العنوان: طنجة، المغرب

آخر تحديث: 3 يونيو 2026
© 2026 HN GROUPE — جميع الحقوق محفوظة el hassani moulay ismail. groupe hn`,
  },
];

const TermsAndConditions = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-background text-foreground" dir="rtl">
      <div className="bg-gradient-to-l from-primary/20 via-primary/10 to-background border-b border-border/40">
        <div className="max-w-4xl mx-auto px-4 py-10">
          <Button variant="ghost" size="sm" onClick={() => navigate(-1)} className="mb-4 gap-1">
            <ArrowRight className="w-4 h-4" />
            رجوع
          </Button>
          <div className="flex items-center gap-3 mb-3">
            <FileText className="w-10 h-10 text-primary" />
            <h1 className="text-3xl font-bold">الشروط والأحكام</h1>
          </div>
          <p className="text-muted-foreground text-lg">
            القواعد المنظِّمة لاستخدام خدمات HN Driver
          </p>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 py-8 space-y-6">
        {sections.map((section, i) => (
          <div key={i} className="rounded-xl border border-border/60 bg-card p-6 shadow-sm">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2 rounded-lg bg-primary/10">
                <section.icon className="w-5 h-5 text-primary" />
              </div>
              <h2 className="text-xl font-semibold">{section.title}</h2>
            </div>
            <p className="text-muted-foreground leading-relaxed whitespace-pre-line">
              {section.content}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default TermsAndConditions;
