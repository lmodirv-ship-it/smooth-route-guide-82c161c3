#!/bin/bash
# بناء تطبيقات Windows مع OTA لـ Admin / Supervisor / Call Center
# يجب التشغيل على ويندوز (أو ماك/لينكس مع wine) — ليس داخل Lovable sandbox
set -e

ROLES=("admin" "supervisor" "callcenter")
OUT="public/downloads/desktop"

for ROLE in "${ROLES[@]}"; do
  echo "=== بناء $ROLE ==="
  cd "electron/$ROLE"

  # ضع icon.ico (256x256) في هذا المجلد قبل التشغيل
  if [ ! -f icon.ico ]; then
    echo "⚠️  ضع icon.ico في electron/$ROLE/ ثم أعد المحاولة"
    cd ../..
    continue
  fi

  npm install
  npm run build

  # انسخ Setup.exe و latest.yml للسيرفر
  mkdir -p "../../$OUT/$ROLE"
  cp dist/*.exe "../../$OUT/$ROLE/"
  cp dist/latest.yml "../../$OUT/$ROLE/"
  cp dist/*.exe.blockmap "../../$OUT/$ROLE/" 2>/dev/null || true

  cd ../..
  echo "✅ $ROLE → $OUT/$ROLE/"
done

echo ""
echo "📦 جاهز! لرفع تحديث جديد لاحقاً:"
echo "   1. ارفع رقم version في electron/<role>/package.json"
echo "   2. أعد تشغيل هذا السكريبت"
echo "   3. ادفع المشروع → التطبيقات المثبتة ستتحدث تلقائياً عند فتحها"
