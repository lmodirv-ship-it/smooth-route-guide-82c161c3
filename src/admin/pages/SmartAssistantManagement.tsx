import { useEffect, useState } from "react";
import { Bot, Power, PowerOff, Save, Shield, Settings, History, AlertCircle, Loader2, Sparkles } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Slider } from "@/components/ui/slider";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";

type AssistantConfig = {
  id: number;
  is_enabled: boolean;
  model: string;
  system_prompt: string;
  temperature: number;
  max_messages_per_session: number;
  daily_request_limit: number;
  allowed_roles: string[];
  voice_enabled: boolean;
  file_uploads_enabled: boolean;
  maintenance_message: string;
  updated_at: string;
  updated_by: string | null;
};

type AuditEntry = {
  id: string;
  action: string;
  changed_by: string | null;
  created_at: string;
  notes: string | null;
};

const ROLES = [
  { key: "admin", label: "مسؤول" },
  { key: "moderator", label: "مشرف" },
  { key: "agent", label: "مركز اتصال" },
  { key: "driver", label: "سائق ركاب" },
  { key: "delivery", label: "سائق توصيل" },
  { key: "store_owner", label: "صاحب محل" },
  { key: "user", label: "عميل" },
  { key: "smart_admin_assistant", label: "مساعد ذكي" },
];

const MODELS = [
  "google/gemini-3-flash-preview",
  "google/gemini-3-pro-preview",
  "openai/gpt-5.2",
  "openai/gpt-5.2-mini",
];

export default function SmartAssistantManagement() {
  const [config, setConfig] = useState<AssistantConfig | null>(null);
  const [audit, setAudit] = useState<AuditEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from("smart_assistant_config" as any)
      .select("*")
      .eq("id", 1)
      .maybeSingle();
    if (error) toast.error("تعذّر تحميل الإعدادات");
    else if (data) setConfig(data as any);

    const { data: logs } = await supabase
      .from("smart_assistant_audit_log" as any)
      .select("id, action, changed_by, created_at, notes")
      .order("created_at", { ascending: false })
      .limit(20);
    setAudit((logs as any) || []);
    setLoading(false);
  };

  useEffect(() => {
    load();
    const ch = supabase
      .channel("smart-assistant-config")
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "smart_assistant_config" }, load)
      .subscribe();
    return () => { supabase.removeChannel(ch); };
  }, []);

  const updateField = <K extends keyof AssistantConfig>(key: K, value: AssistantConfig[K]) => {
    setConfig((c) => (c ? { ...c, [key]: value } : c));
  };

  const toggleRole = (role: string) => {
    if (!config) return;
    const has = config.allowed_roles.includes(role);
    updateField(
      "allowed_roles",
      has ? config.allowed_roles.filter((r) => r !== role) : [...config.allowed_roles, role],
    );
  };

  const save = async () => {
    if (!config) return;
    setSaving(true);
    const { error } = await supabase
      .from("smart_assistant_config" as any)
      .update({
        is_enabled: config.is_enabled,
        model: config.model,
        system_prompt: config.system_prompt,
        temperature: config.temperature,
        max_messages_per_session: config.max_messages_per_session,
        daily_request_limit: config.daily_request_limit,
        allowed_roles: config.allowed_roles,
        voice_enabled: config.voice_enabled,
        file_uploads_enabled: config.file_uploads_enabled,
        maintenance_message: config.maintenance_message,
      })
      .eq("id", 1);
    setSaving(false);
    if (error) toast.error("فشل الحفظ: " + error.message);
    else {
      toast.success("✅ تم حفظ الإعدادات");
      load();
    }
  };

  const quickToggle = async () => {
    if (!config) return;
    const newVal = !config.is_enabled;
    setSaving(true);
    const { error } = await supabase
      .from("smart_assistant_config" as any)
      .update({ is_enabled: newVal })
      .eq("id", 1);
    setSaving(false);
    if (error) toast.error("فشل التحديث");
    else {
      toast.success(newVal ? "🟢 تم تفعيل المساعد الذكي" : "🔴 تم تعطيل المساعد الذكي");
      load();
    }
  };

  if (loading || !config) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="w-8 h-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="space-y-6 p-4 md:p-6" dir="rtl">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary/60 flex items-center justify-center">
            <Bot className="w-6 h-6 text-primary-foreground" />
          </div>
          <div>
            <h1 className="text-2xl font-bold">إدارة المساعد الذكي</h1>
            <p className="text-sm text-muted-foreground">التحكم الكامل في سلوك وصلاحيات المساعد الذكي</p>
          </div>
        </div>
        <Badge variant={config.is_enabled ? "default" : "destructive"} className="text-sm px-3 py-1.5">
          {config.is_enabled ? "🟢 مُفعَّل" : "🔴 معطَّل"}
        </Badge>
      </div>

      {/* Master switch */}
      <Card className={config.is_enabled ? "border-green-500/40" : "border-red-500/40"}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Power className="w-5 h-5" />
            مفتاح التشغيل الرئيسي
          </CardTitle>
          <CardDescription>
            تعطيل المساعد يوقف الردود في كل التطبيقات فوراً ويعرض رسالة الصيانة.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between gap-4">
            <div className="flex-1">
              <p className="font-semibold">
                {config.is_enabled ? "المساعد الذكي يعمل حالياً" : "المساعد الذكي متوقف"}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                آخر تحديث: {new Date(config.updated_at).toLocaleString("ar-MA")}
              </p>
            </div>
            <Button
              size="lg"
              variant={config.is_enabled ? "destructive" : "default"}
              onClick={quickToggle}
              disabled={saving}
              className="min-w-[160px]"
            >
              {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : config.is_enabled ? (
                <><PowerOff className="w-4 h-4 mr-2" /> تعطيل فوري</>
              ) : (
                <><Power className="w-4 h-4 mr-2" /> تفعيل فوري</>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Model & behavior */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Sparkles className="w-5 h-5" /> النموذج والسلوك</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label>النموذج (Model)</Label>
              <select
                value={config.model}
                onChange={(e) => updateField("model", e.target.value)}
                className="w-full mt-1 px-3 py-2 rounded-md border bg-background"
              >
                {MODELS.map((m) => <option key={m} value={m}>{m}</option>)}
              </select>
            </div>

            <div>
              <Label>درجة الإبداع (Temperature): {config.temperature}</Label>
              <Slider
                value={[config.temperature]}
                min={0} max={2} step={0.1}
                onValueChange={([v]) => updateField("temperature", v)}
                className="mt-2"
              />
              <p className="text-xs text-muted-foreground mt-1">منخفض = دقيق، مرتفع = إبداعي</p>
            </div>

            <div>
              <Label>التعليمات الأساسية (System Prompt)</Label>
              <Textarea
                value={config.system_prompt}
                onChange={(e) => updateField("system_prompt", e.target.value)}
                rows={5}
                className="mt-1"
              />
            </div>

            <div>
              <Label>رسالة الصيانة (تظهر عند التعطيل)</Label>
              <Textarea
                value={config.maintenance_message}
                onChange={(e) => updateField("maintenance_message", e.target.value)}
                rows={2}
                className="mt-1"
              />
            </div>
          </CardContent>
        </Card>

        {/* Limits & features */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><Settings className="w-5 h-5" /> الحدود والميزات</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label>أقصى عدد رسائل لكل جلسة</Label>
              <Input
                type="number" min={1} max={200}
                value={config.max_messages_per_session}
                onChange={(e) => updateField("max_messages_per_session", parseInt(e.target.value) || 30)}
                className="mt-1"
              />
            </div>

            <div>
              <Label>حد الطلبات اليومية لكل مستخدم</Label>
              <Input
                type="number" min={1} max={10000}
                value={config.daily_request_limit}
                onChange={(e) => updateField("daily_request_limit", parseInt(e.target.value) || 200)}
                className="mt-1"
              />
            </div>

            <div className="flex items-center justify-between p-3 rounded-lg border">
              <div>
                <p className="font-medium text-sm">🎙️ الإدخال الصوتي</p>
                <p className="text-xs text-muted-foreground">السماح بإرسال الرسائل بالصوت</p>
              </div>
              <Switch checked={config.voice_enabled} onCheckedChange={(v) => updateField("voice_enabled", v)} />
            </div>

            <div className="flex items-center justify-between p-3 rounded-lg border">
              <div>
                <p className="font-medium text-sm">📎 رفع الملفات</p>
                <p className="text-xs text-muted-foreground">السماح بإرفاق صور/ملفات</p>
              </div>
              <Switch checked={config.file_uploads_enabled} onCheckedChange={(v) => updateField("file_uploads_enabled", v)} />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Allowed roles */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2"><Shield className="w-5 h-5" /> الأدوار المسموح لها باستخدام المساعد</CardTitle>
          <CardDescription>اختر من يستطيع التحدث مع المساعد الذكي</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {ROLES.map((r) => (
              <label key={r.key} className="flex items-center gap-2 p-3 rounded-lg border cursor-pointer hover:bg-muted/50">
                <Switch
                  checked={config.allowed_roles.includes(r.key)}
                  onCheckedChange={() => toggleRole(r.key)}
                />
                <span className="text-sm">{r.label}</span>
              </label>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Save bar */}
      <div className="sticky bottom-4 flex justify-end">
        <Button size="lg" onClick={save} disabled={saving} className="shadow-lg min-w-[180px]">
          {saving ? <Loader2 className="w-4 h-4 animate-spin mr-2" /> : <Save className="w-4 h-4 mr-2" />}
          حفظ كل التغييرات
        </Button>
      </div>

      {/* Audit log */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2"><History className="w-5 h-5" /> سجل التعديلات (آخر 20)</CardTitle>
        </CardHeader>
        <CardContent>
          {audit.length === 0 ? (
            <p className="text-sm text-muted-foreground text-center py-4">لا توجد تعديلات بعد</p>
          ) : (
            <div className="space-y-2 max-h-[400px] overflow-auto">
              {audit.map((a) => (
                <div key={a.id} className="flex items-center justify-between p-3 rounded-lg border bg-card text-sm">
                  <div className="flex items-center gap-3">
                    {a.action === "enable" ? <Power className="w-4 h-4 text-green-500" /> :
                      a.action === "disable" ? <PowerOff className="w-4 h-4 text-red-500" /> :
                      <Settings className="w-4 h-4 text-blue-500" />}
                    <Badge variant="outline">{a.action === "enable" ? "تفعيل" : a.action === "disable" ? "تعطيل" : "تعديل"}</Badge>
                  </div>
                  <span className="text-xs text-muted-foreground">{new Date(a.created_at).toLocaleString("ar-MA")}</span>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      <div className="flex items-start gap-2 p-3 rounded-lg bg-muted/50 text-xs text-muted-foreground">
        <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
        <p>كل تغيير يُسجَّل تلقائياً بهوية الأدمن الذي أجراه. التعطيل الفوري يوقف جميع الردود في تطبيقات العميل/السائق/الإدارة خلال ثوانٍ.</p>
      </div>
    </div>
  );
}
