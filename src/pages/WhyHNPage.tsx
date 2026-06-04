import { lazy, Suspense } from "react";
import { Link } from "react-router-dom";
import { ChevronRight } from "lucide-react";

const LandingExtras = lazy(() => import("@/components/landing/LandingExtras"));

const WhyHNPage = () => {
  return (
    <div dir="rtl" className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-30 backdrop-blur-md bg-background/70 border-b border-border">
        <div className="max-w-6xl mx-auto flex items-center justify-between px-4 py-3">
          <Link to="/" className="inline-flex items-center gap-2 text-sm font-bold text-primary hover:opacity-80 transition">
            <ChevronRight className="h-4 w-4" />
            الرجوع للرئيسية
          </Link>
          <strong className="text-sm md:text-base">لماذا HN Driver</strong>
        </div>
      </header>

      <main>
        <Suspense fallback={<div className="p-10 text-center text-muted-foreground">جارٍ التحميل…</div>}>
          <LandingExtras />
        </Suspense>
      </main>
    </div>
  );
};

export default WhyHNPage;
