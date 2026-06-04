/**
 * LandingExtras — below-the-fold content (stats, features, CTA).
 * Lazy-loaded from LandingPage to keep the hero ultra-light.
 */
import { Users, Car, Bike, Store, Zap, ShieldCheck, Headphones, Globe, Smartphone } from "lucide-react";
import { Link } from "react-router-dom";

const stats = [
  { Icon: Users, value: "+10,000", label: "مستخدم نشط", color: "text-info" },
  { Icon: Car, value: "+2,500", label: "سائق", color: "text-success" },
  { Icon: Bike, value: "+5,000", label: "عامل توصيل", color: "text-accent-foreground" },
  { Icon: Store, value: "+1,200", label: "مطعم و متجر", color: "text-primary" },
];

const features = [
  { Icon: Zap, title: "سرعة فائقة", desc: "وصول طلباتك في أقل وقت ممكن" },
  { Icon: ShieldCheck, title: "أمان وموثوقية", desc: "حماية كاملة لبياناتك ومعاملاتك" },
  { Icon: Headphones, title: "دعم 24/7", desc: "فريق دعم متواصل على مدار الساعة" },
  { Icon: Globe, title: "تغطية شاملة", desc: "نخدم جميع المناطق الرئيسية" },
];

const LandingExtras = () => {
  return (
    <>
      {/* Stats */}
      <section id="stats" className="px-4 md:px-8 py-12 bg-secondary/30">
        <div className="max-w-6xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-4">
          {stats.map(({ Icon, value, label, color }) => (
            <div key={label} className="glass-card rounded-2xl p-5 text-center">
              <Icon className={`h-7 w-7 ${color} mx-auto mb-2`} />
              <div className="text-2xl md:text-3xl font-bold text-foreground">{value}</div>
              <div className="text-xs md:text-sm text-muted-foreground mt-1">{label}</div>
            </div>
          ))}
        </div>
      </section>

      {/* Features */}
      <section id="features" className="px-4 md:px-8 py-16">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-2xl md:text-4xl font-bold text-center text-foreground mb-3">
            لماذا <span className="text-primary">HN Driver</span>؟
          </h2>
          <p className="text-center text-muted-foreground mb-10 max-w-xl mx-auto">
            منصة موحدة لجميع خدمات التوصيل، مصممة لتلبية احتياجاتك
          </p>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {features.map(({ Icon, title, desc }) => (
              <div key={title} className="glass-card rounded-2xl p-6 text-center">
                <Icon className="h-10 w-10 text-primary mx-auto mb-3" />
                <h3 className="font-bold text-foreground mb-1">{title}</h3>
                <p className="text-sm text-muted-foreground">{desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Download CTA */}
      <section id="download" className="px-4 md:px-8 py-16 bg-secondary/30">
        <div className="max-w-3xl mx-auto text-center">
          <Smartphone className="h-12 w-12 text-primary mx-auto mb-4" />
          <h2 className="text-2xl md:text-4xl font-bold text-foreground mb-3">حمّل التطبيق الآن</h2>
          <p className="text-muted-foreground mb-6">متوفر على جميع المتاجر</p>
          <div className="flex flex-wrap justify-center gap-3">
            <Link to="/register/customer" className="gradient-primary text-primary-foreground font-bold px-6 py-3 rounded-xl">
              ابدأ الآن
            </Link>
            <Link to="/login" className="border border-border text-foreground px-6 py-3 rounded-xl hover:bg-secondary transition">
              لدي حساب
            </Link>
          </div>
        </div>
      </section>

      <footer className="px-4 py-6 text-center text-xs text-muted-foreground border-t border-border space-y-2">
        <div className="flex flex-wrap justify-center gap-4">
          <Link to="/terms" className="hover:text-primary transition">الشروط والأحكام</Link>
          <Link to="/privacy" className="hover:text-primary transition">سياسة الخصوصية</Link>
        </div>
        <div>© {new Date().getFullYear()} HN Driver — جميع الحقوق محفوظة el hassani moulay ismail. groupe hn</div>
      </footer>
    </>
  );
};

export default LandingExtras;
