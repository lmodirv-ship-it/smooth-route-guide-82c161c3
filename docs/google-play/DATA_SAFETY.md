# 🔒 Data Safety Form — HN Driver

Ready-to-paste answers for **Play Console → App content → Data safety**.

---

## 1. Data collection & sharing — Overview

| Question | Answer |
|---|---|
| Does your app collect or share user data? | **Yes** |
| Is all collected data encrypted in transit? | **Yes** (HTTPS/TLS 1.3 everywhere) |
| Do you provide a way for users to request data deletion? | **Yes** — via in-app `Settings → Delete account` and `lmodirv@gmail.com` |

---

## 2. Data Types Collected

### 📍 Location
| Type | Collected | Shared | Required | Purpose |
|---|---|---|---|---|
| Approximate location | ✅ | ❌ | Optional | App functionality, Analytics |
| Precise location | ✅ | ✅ (with assigned driver only) | Required for ride/delivery | App functionality |

### 👤 Personal info
| Type | Collected | Shared | Purpose |
|---|---|---|---|
| Name | ✅ | ❌ | Account, Personalization |
| Email address | ✅ | ❌ | Account, Communications |
| Phone number | ✅ | ✅ (driver↔client during active trip only) | Account, Service operation |
| User IDs | ✅ | ❌ | Account |

### 💰 Financial info
| Type | Collected | Shared | Purpose |
|---|---|---|---|
| Purchase history | ✅ | ❌ | App functionality, Analytics |
| Payment info | ❌ collected by us | ❌ | Handled by Stripe / PayPal directly |

### 📨 Messages
| Type | Collected | Shared | Purpose |
|---|---|---|---|
| In-app messages | ✅ (preset only) | Between client↔driver of same order | App functionality |

### 📷 Photos & videos
| Type | Collected | Purpose |
|---|---|---|
| Photos | ✅ | Profile picture, Proof of Delivery |

### 📱 App activity
| Type | Collected | Purpose |
|---|---|---|
| App interactions | ✅ | Analytics |
| In-app search history | ✅ | App functionality |
| Other user-generated content | ✅ (ratings, reviews) | App functionality |

### 🛠 App info & performance
| Type | Collected | Purpose |
|---|---|---|
| Crash logs | ✅ | Analytics, Bug fixing |
| Diagnostics | ✅ | Analytics |

### 📲 Device or other IDs
| Type | Collected | Purpose |
|---|---|---|
| Device ID | ✅ | Analytics, Fraud prevention |

---

## 3. Security Practices

- ✅ Data is encrypted in transit (TLS 1.3)
- ✅ Users can request data deletion (in-app + email)
- ✅ Data deletion request handled within 30 days
- ✅ Independent security review: Lovable Cloud (Supabase) — SOC 2 Type II
- ✅ Follows Google Play Families Policy: **Not applicable** (16+ app)

---

## 4. Permissions Justification

Paste these in **App content → Permissions declaration** when prompted.

| Permission | Why we need it | Triggered when |
|---|---|---|
| `ACCESS_FINE_LOCATION` | Show driver/client live location, calculate fare by distance | User books a ride or driver goes online |
| `ACCESS_COARSE_LOCATION` | Fallback when GPS unavailable | Same as above |
| `ACCESS_BACKGROUND_LOCATION` | Continue tracking driver during active trip only | Driver accepts a ride, stops when trip ends |
| `INTERNET` | Network requests | Always |
| `CAMERA` | Take profile photo, capture Proof of Delivery, scan QR | User taps camera button |
| `READ_MEDIA_IMAGES` | Upload existing photo from gallery | User taps gallery |
| `POST_NOTIFICATIONS` | Order updates, messages | User opts in |
| `RECORD_AUDIO` | In-app voice/video calls (driver↔client) | User initiates call |
| `FOREGROUND_SERVICE` | Keep driver tracking alive during active trip | Driver accepts ride |
| `VIBRATE` | Notification feedback | Notification received |

### 🔴 Sensitive permissions — extra justification

**Background location** (most scrutinized):
> "HN Driver requires background location ONLY for active drivers during an
> ongoing trip, to broadcast live position to the client tracking the ride.
> The permission is requested incrementally AFTER the driver accepts an
> order, never on app launch. It stops automatically when the trip ends.
> No background tracking occurs for client (passenger) accounts."

---

## 5. Account Deletion (mandatory since 2024)

✅ Implemented at: `Settings → Account → Delete account`
✅ Web alternative: `https://www.hn-driver.com/account/delete`
✅ Effect: Removes profile, ride history (anonymized for legal records), wallet balance refunded if > 0.

---

## 6. Target Audience

- **Primary age**: 18+
- **Children-directed**: ❌ No
- **Ad SDKs targeting children**: ❌ None

---

## 7. News app declaration

❌ Not a news app.

---

## 8. COVID-19 / Government app

❌ Not applicable.

---

## ✅ Pre-submission checklist

- [ ] All data types above declared in Console
- [ ] Privacy Policy URL active: `https://www.hn-driver.com/privacy-policy`
- [ ] Account deletion link active: `https://www.hn-driver.com/account/delete`
- [ ] Background location video demo recorded (required by Google for review)
- [ ] Sensitive permissions explained in declaration form
