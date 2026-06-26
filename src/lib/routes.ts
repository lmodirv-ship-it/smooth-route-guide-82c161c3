/**
 * Canonical route map — the single source of truth for all routing decisions.
 *
 * Naming convention:
 *   DB role  →  canonical dashboard path
 *   "user"   →  /customer   (default signup role)
 *   "driver" →  /driver
 *   "admin"  →  /admin
 *   "agent"  →  /call-center
 *
 * Legacy paths (/client, /driver-panel, /customer-tracking, etc.) are kept as
 * redirect-only routes in App.tsx.
 */

export type DbRole = "admin" | "moderator" | "user" | "driver" | "agent" | "delivery" | "store_owner" | "smart_admin_assistant";

/** Maps a DB role to its canonical dashboard path. */
export const ROLE_DASHBOARD: Record<string, string> = {
  driver: "/driver",
  client: "/customer",
  user: "/customer",
  admin: "/admin",
  agent: "/call-center",
  moderator: "/supervisor",
  delivery: "/driver/delivery",
  store_owner: "/delivery/my-store",
  smart_admin_assistant: "/call-center",
};

/** Human-readable labels (Arabic) for each DB role. */
export const ROLE_LABELS: Record<string, string> = {
  admin: "مسؤول",
  moderator: "مشرف",
  agent: "مركز اتصال",
  driver: "سائق ركاب",
  delivery: "سائق توصيل",
  store_owner: "صاحب محل",
  client: "عميل",
  user: "عميل",
  smart_admin_assistant: "مساعد ذكي",
};

/**
 * Given a DB role, return the canonical dashboard path.
 * Falls back to /customer for unknown roles.
 */
export function dashboardForRole(role: string): string {
  return ROLE_DASHBOARD[role] || "/customer";
}
