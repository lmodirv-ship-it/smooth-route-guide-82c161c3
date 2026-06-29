import { useEffect, useState } from "react";
import { X } from "lucide-react";

// ⚙️ وقت نهاية المباراة — بعد انتهائه تختفي النافذة نهائيًا
// عدّل هذا التاريخ حسب موعد المباراة الفعلي (UTC)
const MATCH_END_ISO = "2026-06-29T23:00:00Z";

const OPTIONS = [
  "المغرب 1 - 0 هولندا",
  "المغرب 2 - 1 هولندا",
  "تعادل 1 - 1",
  "تعادل 0 - 0",
  "هولندا 2 - 1 المغرب",
];

const STORAGE_KEY = "hn_morocco_match_popup_closed";

function formatRemaining(ms: number) {
  if (ms <= 0) return "00:00:00";
  const s = Math.floor(ms / 1000);
  const h = String(Math.floor(s / 3600)).padStart(2, "0");
  const m = String(Math.floor((s % 3600) / 60)).padStart(2, "0");
  const sec = String(s % 60).padStart(2, "0");
  return `${h}:${m}:${sec}`;
}

export default function MoroccoMatchPopup() {
  const endTime = new Date(MATCH_END_ISO).getTime();
  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState<number | null>(null);
  const [submitted, setSubmitted] = useState(false);
  const [now, setNow] = useState(Date.now());

  useEffect(() => {
    if (Date.now() >= endTime) return;
    if (sessionStorage.getItem(STORAGE_KEY) === "1") return;
    setOpen(true);
  }, [endTime]);

  useEffect(() => {
    if (!open) return;
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, [open]);

  useEffect(() => {
    if (now >= endTime) setOpen(false);
  }, [now, endTime]);

  if (!open) return null;
  if (Date.now() >= endTime) return null;

  const close = () => {
    sessionStorage.setItem(STORAGE_KEY, "1");
    setOpen(false);
  };

  const submit = () => {
    if (selected === null) return;
    try {
      localStorage.setItem(
        "hn_morocco_prediction",
        JSON.stringify({ choice: OPTIONS[selected], at: new Date().toISOString() }),
      );
    } catch {}
    setSubmitted(true);
  };

  return (
    <div
      className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/70 backdrop-blur-sm p-4"
      dir="rtl"
      role="dialog"
      aria-modal="true"
    >
      <div className="relative w-full max-w-md rounded-2xl bg-background border border-border shadow-2xl overflow-hidden animate-in fade-in zoom-in-95">
        <button
          onClick={close}
          aria-label="إغلاق"
          className="absolute top-3 left-3 p-1.5 rounded-full bg-secondary hover:bg-secondary/80 text-foreground transition z-10"
        >
          <X className="w-4 h-4" />
        </button>

        <div className="bg-gradient-to-br from-red-600 via-red-700 to-green-700 p-5 text-white text-center">
          <h2 className="text-lg font-bold leading-snug">
            🇲🇦 توقع نتيجة مباراة المغرب × هولندا 🇳🇱
          </h2>
          <p className="text-xs mt-2 opacity-90">
            شارك في تخمين نتيجة المباراة مجانًا للتسلية والترفيه فقط.
          </p>
        </div>

        <div className="p-5 space-y-4">
          <div className="text-[11px] text-muted-foreground bg-secondary/60 rounded-lg p-2.5 leading-relaxed text-center">
            ⚠️ هذه الميزة مجانية بالكامل، ولا ترتبط بأي جوائز مالية أو مراهنات أو مقامرة.
          </div>

          {!submitted ? (
            <>
              <div className="space-y-2">
                {OPTIONS.map((opt, i) => (
                  <button
                    key={i}
                    onClick={() => setSelected(i)}
                    className={`w-full text-right px-4 py-2.5 rounded-lg border transition text-sm font-medium ${
                      selected === i
                        ? "bg-primary text-primary-foreground border-primary shadow-md scale-[1.02]"
                        : "bg-secondary text-foreground border-border hover:bg-secondary/80"
                    }`}
                  >
                    {selected === i ? "✓ " : ""}{opt}
                  </button>
                ))}
              </div>

              {selected !== null && (
                <button
                  onClick={submit}
                  className="w-full py-3 rounded-lg bg-green-600 hover:bg-green-700 text-white font-bold transition shadow-lg animate-in fade-in"
                >
                  إرسال التوقع
                </button>
              )}
            </>
          ) : (
            <div className="text-center py-6 space-y-2">
              <div className="text-4xl">🎉</div>
              <div className="text-base font-bold text-foreground">
                شكراً، تم تسجيل توقعك.
              </div>
              <div className="text-sm text-muted-foreground">
                توقعك: <span className="font-semibold">{OPTIONS[selected!]}</span>
              </div>
            </div>
          )}

          <div className="border-t border-border pt-3 text-center">
            <div className="text-[11px] text-muted-foreground mb-1">
              ينتهي استقبال التوقعات بعد نهاية المباراة
            </div>
            <div className="font-mono text-lg font-bold text-primary tabular-nums">
              {formatRemaining(endTime - now)}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
