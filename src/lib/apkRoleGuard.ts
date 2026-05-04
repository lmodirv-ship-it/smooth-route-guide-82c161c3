/**
 * APK Role Guard — restricts the mobile APK to 3 user roles.
 * Allowed: customer, driver, delivery.
 * Other roles (admin, supervisor, call_center, etc.) see a redirect screen.
 */

import { Capacitor } from "@capacitor/core";

export const APK_ALLOWED_ROLES = ["customer", "driver", "delivery"] as const;
export type ApkAllowedRole = typeof APK_ALLOWED_ROLES[number];

export const isNativeApk = (): boolean => {
  try {
    return Capacitor?.isNativePlatform?.() ?? false;
  } catch {
    return false;
  }
};

export const isRoleAllowedInApk = (role: string | null | undefined): boolean => {
  if (!role) return true; // unauthenticated users may browse
  return (APK_ALLOWED_ROLES as readonly string[]).includes(role);
};

/** Localized blocked-access messages for unsupported roles inside APK */
export const APK_BLOCKED_MESSAGES: Record<string, { title: string; body: string; btn: string }> = {
  ar: {
    title: "وصول محظور",
    body: "هذا التطبيق مخصص للعملاء والسائقين والتوصيل فقط.\nللوصول الإداري استخدم المتصفح:\nhndriver.company",
    btn: "تسجيل الخروج",
  },
  fr: {
    title: "Accès restreint",
    body: "Cette application est réservée aux clients, chauffeurs et livreurs.\nPour l'administration, utilisez le navigateur :\nhndriver.company",
    btn: "Se déconnecter",
  },
  en: {
    title: "Access Restricted",
    body: "This app is for customers, drivers and delivery only.\nFor admin access use the browser:\nhndriver.company",
    btn: "Sign out",
  },
  es: {
    title: "Acceso restringido",
    body: "Esta aplicación es solo para clientes, conductores y repartidores.\nPara administración use el navegador:\nhndriver.company",
    btn: "Cerrar sesión",
  },
};

export const detectLang = (): string => {
  try {
    const stored = localStorage.getItem("hn_lang");
    if (stored && APK_BLOCKED_MESSAGES[stored]) return stored;
    const nav = (navigator.language || "ar").toLowerCase().slice(0, 2);
    return APK_BLOCKED_MESSAGES[nav] ? nav : "ar";
  } catch {
    return "ar";
  }
};
