# HN Driver — Native (Bundled) APK Downloads

Each APK is a **fully native Android app** with all web assets **embedded inside**.
Works completely offline. No dependency on the website server for the UI.

> ⚠️ **Important:** since the code is bundled, every code change in the project
> requires rebuilding and redistributing the APK (no automatic updates).

---

## Roles

| Role | File | App ID | Bundled Build |
|---|---|---|---|
| General | `hn-general.apk` | `com.hndriver.general` | `dist/` |
| Admin | `hn-admin.apk` | `com.hndriver.admin` | `dist-admin/` |
| Call Center | `hn-callcenter.apk` | `com.hndriver.callcenter` | `dist-call-center/` |
| Client | `hn-client.apk` | `com.hndriver.client` | `dist-client/` |
| Delivery | `hn-delivery.apk` | `com.hndriver.delivery` | `dist-driver-delivery/` |
| Driver (Ride) | `hn-driver.apk` | `com.hndriver.driver` | `dist-driver-ride/` |
| Store / Restaurant | `hn-store.apk` | `com.hndriver.store` | `dist/` |

---

## Build steps (per role)

```bash
# 1. Drop your 1024×1024 PNG icon into:
#    android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
#    (Android Studio → Image Asset auto-generates all densities)

# 2. Build the APK (bundles web assets into the apk)
bash scripts/build-apk.sh <role>

# 3. Output lands here automatically:
#    public/downloads/apps/hn-<role>.apk

# 4. Sign it (one-time keystore via Android Studio):
#    Build → Generate Signed Bundle/APK
```

Replace `<role>` with: `general`, `admin`, `callcenter`, `client`, `delivery`, `driver`, `store`.

---

## Build all 7 at once

```bash
for r in general admin callcenter client delivery driver store; do
  bash scripts/build-apk.sh $r
done
```

---

## Updates policy

- **Backend / database changes** → still live, no rebuild needed (the bundled
  app talks to Lovable Cloud over HTTPS).
- **UI / frontend changes** → require running `build-apk.sh` again and
  publishing a new `.apk` here. Users must download the new APK manually.
- If you want users to receive UI updates without reinstalling, switch to the
  Hybrid OTA architecture later (Capgo Capacitor Updater plugin).
