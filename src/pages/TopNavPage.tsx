import { Link, Navigate, useLocation } from "react-router-dom";
import { ArrowRight, Bike, Car, CheckCircle2, Headphones, ShieldCheck, Sparkles, Store, Wallet } from "lucide-react";
import PageMeta from "@/components/PageMeta";
import heroBg from "@/assets/landing-hero-bg.jpg";

const pages = {
  services: {
    title: "الخدمات",
    subtitle: "رحلات، توصيل طلبات، دعم المطاعم والمتاجر في منصة واحدة.",
    Icon: Car,
    items: ["خدمة السائق الخاص داخل المدينة", "توصيل طلبات المطاعم والمتاجر", "عمال توصيل مستقلون", "حلول مخصصة للشركاء"],
  },
  pricing: {
    title: "الأسعار",
    subtitle: "تسعير واضح ومرن يناسب الزبائن والسائقين وأصحاب المتاجر.",
    Icon: Wallet,
    items: ["أسعار شفافة قبل تأكيد الطلب", "عمولات مناسبة للشركاء", "عروض موسمية داخل التطبيق", "دعم الدفع النقدي والرقمي"],
  },
  features: {
    title: "مزايا التطبيق",
    subtitle: "تجربة سريعة وآمنة مصممة للعمل اليومي بدون تعقيد.",
    Icon: Sparkles,
    items: ["تتبع مباشر للرحلات والطلبات", "تنبيهات فورية للحسابات", "واجهة سهلة للهاتف والحاسوب", "حماية بيانات المستخدمين"],
  },
  contact: {
    title: "تواصل معنا",
    subtitle: "فريق HN Driver جاهز لمساعدتك والرد على طلبات الشراكة والدعم.",
    Icon: Headphones,
    items: ["دعم فني دائم", "طلبات شراكة المطاعم والمتاجر", "مساعدة السائقين وعمال التوصيل", "متابعة الحسابات الجديدة"],
  },
};

const quickRoles = [
  { to: "/register/driver", label: "تسجيل سائق", Icon: Car },
  { to: "/register/customer", label: "تسجيل زبون", Icon: ShieldCheck },
  { to: "/register/delivery", label: "تسجيل عامل توصيل", Icon: Bike },
  { to: "/register/store", label: "تسجيل مطعم أو متجر", Icon: Store },
];

type PageKey = keyof typeof pages;

const TopNavPage = () => {
  const { pathname } = useLocation();
  const slug = pathname.replace(/^\//, "");
  const page = slug && slug in pages ? pages[slug as PageKey] : null;

  if (!page) return <Navigate to="/" replace />;

  const Icon = page.Icon;

  return (
    <div className="min-h-screen gradient-dark" dir="rtl">
      <PageMeta title={`${page.title} — HN Driver`} description={page.subtitle} />
      <main className="relative min-h-screen overflow-hidden px-4 py-5 md:px-10">
        <div className="absolute inset-0 bg-cover bg-center opacity-35" style={{ backgroundImage: `url(${heroBg})` }} aria-hidden />
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,hsl(220_30%_5%/0.5),hsl(220_35%_3%/0.98))]" aria-hidden />

        <div className="relative z-10 mx-auto flex min-h-[calc(100vh-2.5rem)] max-w-6xl flex-col">
          <header className="flex items-center justify-between rounded-2xl border border-border/70 bg-background/55 px-4 py-3 backdrop-blur-xl">
            <Link to="/" className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground">
              <ArrowRight className="h-4 w-4" />
              الرئيسية
            </Link>
            <strong className="text-primary">HN DRIVER</strong>
          </header>

          <section className="flex flex-1 items-center justify-center py-8">
            <div className="grid w-full gap-6 lg:grid-cols-[1fr_0.85fr] lg:items-center">
              <div>
                <div className="mb-5 inline-grid h-16 w-16 place-items-center rounded-2xl border border-primary/40 bg-primary/15 text-primary shadow-[0_0_35px_hsl(var(--primary)/0.25)]">
                  <Icon className="h-9 w-9" />
                </div>
                <h1 className="text-4xl font-extrabold leading-tight text-foreground md:text-6xl">{page.title}</h1>
                <p className="mt-4 max-w-2xl text-lg text-muted-foreground">{page.subtitle}</p>
                <div className="mt-8 grid gap-3 sm:grid-cols-2">
                  {page.items.map((item) => (
                    <div key={item} className="flex items-center gap-3 rounded-xl border border-border/70 bg-card/55 px-4 py-3 backdrop-blur-xl">
                      <CheckCircle2 className="h-5 w-5 shrink-0 text-primary" />
                      <span className="text-sm text-foreground">{item}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="rounded-3xl border border-primary/25 bg-background/55 p-5 shadow-[0_0_50px_hsl(var(--primary)/0.12)] backdrop-blur-xl">
                <h2 className="mb-4 text-xl font-bold text-foreground">ابدأ الآن</h2>
                <div className="grid gap-3">
                  {quickRoles.map(({ to, label, Icon: RoleIcon }) => (
                    <Link key={to} to={to} className="flex items-center justify-between rounded-xl border border-border/70 bg-card/70 px-4 py-3 text-foreground transition hover:border-primary/50 hover:bg-primary/10">
                      <span className="font-semibold">{label}</span>
                      <RoleIcon className="h-5 w-5 text-primary" />
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          </section>
        </div>
      </main>
    </div>
  );
};

export default TopNavPage;