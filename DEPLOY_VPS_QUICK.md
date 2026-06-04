# 🚀 نشر سريع على VPS — دليل خطوة بخطوة

> **VPS:** Ubuntu 24.04 LTS — IP: `213.156.132.166`
> **النطاقان:** `hn-driver.com` + `hndriver.company` (يعملان معاً)

---

## 1️⃣ سجلات DNS (في كلا النطاقين)

أضف **10 سجلات A** في كل نطاق، كلها تشير إلى `213.156.132.166`:

| Type | Name | Value |
|------|------|-------|
| A | @ | 213.156.132.166 |
| A | www | 213.156.132.166 |
| A | admin | 213.156.132.166 |
| A | call | 213.156.132.166 |
| A | client | 213.156.132.166 |
| A | delivery | 213.156.132.166 |
| A | driver | 213.156.132.166 |
| A | ride | 213.156.132.166 |
| A | supervisor | 213.156.132.166 |
| A | stock | 213.156.132.166 |

---

## 2️⃣ إعداد VPS (مرة واحدة فقط)

```bash
ssh root@213.156.132.166

# تحديث + الأساسيات
apt update && apt upgrade -y
apt install -y nginx git curl rsync ufw certbot python3-certbot-nginx

# Node 20 + pnpm
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g pnpm@latest

# جدار الحماية
ufw allow OpenSSH && ufw allow 'Nginx Full' && ufw --force enable

# استنساخ المشروع
git clone <YOUR_REPO_URL> /var/www/hn-driver
cd /var/www/hn-driver

# تشغيل سكريبت الإعداد (يثبت webhook + nginx تلقائياً)
bash scripts/server/setup-server.sh
```

---

## 3️⃣ SSL — أمر واحد للنطاقين

```bash
sudo certbot --nginx \
  -d hn-driver.com -d www.hn-driver.com \
  -d admin.hn-driver.com -d call.hn-driver.com \
  -d client.hn-driver.com -d delivery.hn-driver.com \
  -d driver.hn-driver.com -d ride.hn-driver.com \
  -d supervisor.hn-driver.com -d stock.hn-driver.com \
  -d hndriver.company -d www.hndriver.company \
  -d admin.hndriver.company -d call.hndriver.company \
  -d client.hndriver.company -d delivery.hndriver.company \
  -d driver.hndriver.company -d ride.hndriver.company \
  -d supervisor.hndriver.company -d stock.hndriver.company \
  --email YOUR_EMAIL@example.com --agree-tos --non-interactive --redirect
```

التجديد التلقائي مُفعَّل (`systemctl status certbot.timer`).

---

## 4️⃣ بناء + نشر

```bash
cd /var/www/hn-driver
pnpm install --frozen-lockfile

# بناء كل التطبيقات
pnpm build                  # → dist/        (main + client)
pnpm build:admin            # → dist-admin/
pnpm build:client           # → dist-call-center/ + dist-supervisor/
pnpm build:driver-ride      # → dist-driver-ride/
pnpm build:driver-delivery  # → dist-driver-delivery/
pnpm build:hn-stock         # → dist-hn-stock/

# النشر إلى web roots (يفعله auto-deploy.sh تلقائياً عند git push)
bash scripts/server/auto-deploy.sh
```

---

## 5️⃣ Failover تلقائي للـ APK

تم تحديث `src/lib/domainFailover.ts`:
- يجرب `hn-driver.com` أولاً (3 ثوانٍ timeout)
- إن فشل → ينتقل تلقائياً لـ `hndriver.company`
- يحفظ النطاق العامل لمدة 5 دقائق

### إعادة بناء APKs

```bash
for r in admin callcenter client delivery driver; do
  bash scripts/build-apk.sh $r
done
```

---

## ✅ التحقق النهائي

```bash
# Nginx
nginx -t && systemctl status nginx

# اختبر كل نطاق
for d in www admin call client delivery driver ride supervisor stock; do
  echo "=== $d ==="
  curl -sI "https://$d.hn-driver.com" | head -1
  curl -sI "https://$d.hndriver.company" | head -1
done

# SSL
certbot certificates
```

---

## 💾 مساحة 1GB

| البند | الحجم |
|---|---|
| النظام + Nginx + Node | ~400 MB |
| 10 builds | ~150 MB |
| Repo + node_modules | ~300 MB |
| SSL + Logs | ~50 MB |
| **المجموع** | **~900 MB** |

> **توصية:** لا ترفع ملفات APK على الـ VPS — ضعها على GitHub Releases.
