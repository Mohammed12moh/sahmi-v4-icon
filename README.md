# سهمي (Sahmi) - المراحل 1 + 2 + 3 + 4 (وضع تجريبي)

## التشغيل
1. نفّذ `supabase/schema.sql` كاملاً في Supabase SQL Editor (آمن لإعادة التنفيذ).
2. `flutter create . --platforms=android,ios` ثم `flutter pub get`
3. `flutter run` — أو `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
4. `dart run flutter_launcher_icons` (يولّد أيقونة التطبيق لأندرويد وiOS)
5. `flutter test`

## Android: فتح تلغرام
أضف داخل `<manifest>` في `android/app/src/main/AndroidManifest.xml`:
```xml
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="tg"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
</queries>
```

## المحتوى
- م1: Splash، Onboarding، دخول، تسجيل 5 خطوات، RLS.
- م2: الرئيسية، السوق، تفاصيل السهم + محرك الإشارات، مراقبة محفوظة.
- م3: شحن تجريبي، سجل المعاملات، الدعوات والمستويات والمتصدرون، دعم تلغرام.
- م4: المحفظة (قيمة لحظية، توزيع، أرباح/خسائر، سجل صفقات)، شراء/بيع تجريبي (RPC آمن)،
  الملف الشخصي (XP، حضور يومي Streak، تحديات يومية/أسبوعية، 8 شارات)،
  الحساب، الأمان (تغيير كلمة المرور)، المساعدة، عن التطبيق.

## ملاحظات أمنية
- كل الكتابات الحساسة (رصيد، XP، صفقات، شارات) عبر دوال security definer فقط؛ العميل لا يكتب مباشرة.
- أسعار الصفقات تأتي من العميل (محاكاة) — مقبول للتجريبي. لا تعتمد هذا النمط لأموال حقيقية.
- م4: المحفظة (قيمة، ربح/خسارة، توزيع، حيازات، سجل صفقات)، تداول تجريبي (RPC `execute_trade`)،
  حسابي (معلومات قابلة للتعديل، إعدادات، أمان، مساعدة، عن التطبيق)،
  تلعيب: XP، Streak يومي، 8 شارات، تحديات يومية/أسبوعية بمكافآت يتحقق منها الخادم.
  ملاحظة: سعر التداول يأتي من محاكاة العميل (تجريبي فقط)؛ في الإنتاج يجب مصدر سعر موثوق من الخادم.
- الأسعار والرصيد والمكافآت افتراضية. الدفع عبر core/payment/payment_provider.dart.
