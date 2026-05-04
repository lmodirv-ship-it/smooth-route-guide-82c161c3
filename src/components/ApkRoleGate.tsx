/**
 * APK Role Guard component — wraps the app and blocks non-allowed roles
 * inside the native APK. Web users are unaffected.
 */
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
  isNativeApk,
  isRoleAllowedInApk,
  APK_BLOCKED_MESSAGES,
  detectLang,
} from "@/lib/apkRoleGuard";

interface Props { children: React.ReactNode }

export default function ApkRoleGate({ children }: Props) {
  const [blocked, setBlocked] = useState<string | null>(null);

  useEffect(() => {
    if (!isNativeApk()) return;

    const check = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { setBlocked(null); return; }
      const { data: prof } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .maybeSingle();
      const role = (prof as any)?.role ?? null;
      setBlocked(isRoleAllowedInApk(role) ? null : (role || "unknown"));
    };

    check();
    const { data: sub } = supabase.auth.onAuthStateChange(() => { check(); });
    return () => { sub.subscription.unsubscribe(); };
  }, []);

  if (!blocked) return <>{children}</>;

  const lang = detectLang();
  const m = APK_BLOCKED_MESSAGES[lang] || APK_BLOCKED_MESSAGES.ar;
  const dir = lang === "ar" ? "rtl" : "ltr";

  return (
    <div dir={dir} style={{
      position: "fixed", inset: 0, zIndex: 99999,
      background: "radial-gradient(ellipse at center, hsl(220 25% 12%), hsl(222 35% 5%))",
      color: "hsl(0 0% 95%)", display: "flex", flexDirection: "column",
      alignItems: "center", justifyContent: "center", padding: 24, textAlign: "center",
      fontFamily: "-apple-system, system-ui, sans-serif",
    }}>
      <div style={{ fontSize: 64, marginBottom: 16 }}>🔒</div>
      <h1 style={{ fontSize: 26, fontWeight: 800, marginBottom: 16,
        background: "linear-gradient(135deg, hsl(45 80% 65%), hsl(45 70% 45%))",
        WebkitBackgroundClip: "text", backgroundClip: "text", color: "transparent" }}>
        {m.title}
      </h1>
      <p style={{ fontSize: 15, lineHeight: 1.7, color: "hsl(0 0% 75%)",
        whiteSpace: "pre-line", maxWidth: 320, marginBottom: 32 }}>{m.body}</p>
      <button
        onClick={async () => { await supabase.auth.signOut(); location.reload(); }}
        style={{
          padding: "14px 40px",
          background: "linear-gradient(135deg, hsl(45 80% 55%), hsl(45 70% 35%))",
          color: "hsl(222 35% 8%)", border: "none", borderRadius: 99,
          fontSize: 16, fontWeight: 700, cursor: "pointer",
          boxShadow: "0 8px 24px hsl(45 70% 45% / 0.4)",
        }}>{m.btn}</button>
    </div>
  );
}
