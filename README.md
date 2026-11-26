# طريق النور | Tariq Al-Noor

تطبيق Flutter عربي لإدارة حلقات تحفيظ القرآن الكريم. البيانات الأساسية محفوظة محلياً في SQLite ويعمل التطبيق دون تسجيل دخول.

## البيئة المستهدفة
- Flutter stable 3.29.3
- Dart 3.7.x
- Android فقط، Java 17
- ملاحظة شفافية: لم يتم تشغيل Flutter/Gradle داخل بيئة إنشاء هذا الأرشيف؛ لذلك لا أزعم أن APK بُني أو أن البناء اختُبر فعلياً. نفّذ خطوات التحقق أدناه قبل النشر.

## التشغيل والبناء على Windows
1. ثبّت Flutter 3.29.3 و Android Studio و Android SDK.
2. ثبّت JDK 17.
3. فك ضغط المشروع وافتح Terminal داخل المجلد.
4. نفّذ:
   ```bash
   flutter doctor
   flutter config --jdk-dir "C:\Program Files\Java\jdk-17"
   flutter create . --platforms=android
   flutter pub get
   flutter analyze
   flutter test
   flutter build apk --release
   ```
5. ستجد APK في `build/app/outputs/flutter-apk/app-release.apk`.

إذا كان مسار JDK مختلفاً، استبدل المسار أعلاه بمسار JDK 17 الصحيح.

## مشاكل Gradle المعروفة
- إذا شغّل Flutter Gradle باستخدام Java 25 وظهر `Unsupported class file major version 69`، وجّه Flutter إلى JDK 17:
  `flutter config --jdk-dir "<JDK 17 path>"`
- أوقف Gradle daemon بعد تغيير Java:
  `cd android` ثم `gradlew --stop` (على Windows استخدم `gradlew.bat --stop`).
- إذا كان `gradle-wrapper.jar` مفقوداً، نفّذ `flutter create . --platforms=android` لإعادة توليد ملفات Android wrapper، ثم أعد `flutter pub get`.
- يمكنك أيضاً تشغيل `gradlew.bat --version` للتحقق من JVM وGradle المستخدمين.

## GitHub
أنشئ مستودعاً جديداً باسم `tariq-al-noor` ثم:
```bash
git init
git add .
git commit -m "Initial Tariq Al-Noor Flutter app"
git branch -M main
git remote add origin https://github.com/USERNAME/tariq-al-noor.git
git push -u origin main
```
استبدل `USERNAME` باسم حساب GitHub الخاص بك.

## المزايا الموجودة في هذه النسخة
- إدارة مؤسسات متعددة وتصنيف رجالي/نسائي.
- إضافة الطلاب مع صفحات الحفظ السابقة ورقم الهاتف.
- تسجيل يومي قابل للتعديل بمفتاح فريد للطالب والتاريخ.
- الحفظ والمراجعة والحديث والجزرية والتحفة والصفحات والتقدير.
- مؤشرات الحضور والحفظ ومتوسط التقدير.
- معاينة تقارير وقوالب شهادات قابلة للتعديل وتصدير PDF ومشاركته.
- إعداد اسم الشيخ والمعلم وإظهار المعلم.
- قاعدة بيانات SQLite محلية.

## ملاحظات النطاق
هذه نسخة تأسيسية قابلة للتطوير وليست مطابقة بعد لكل تفاصيل المواصفات الكبيرة: تصدير PNG، الاستيراد/التصدير الكامل للنسخ الاحتياطي، التوقيع المحفوظ، أرشيف التقارير، الرسوم البيانية، التصفية الزمنية، وتفاصيل تصميم 30 شهادة متميزة تحتاج استكمالاً واختباراً قبل اعتبارها إصداراً إنتاجياً.

## البناء التلقائي على GitHub
ملف GitHub Actions موجود في `.github/workflows/android.yml`.
1. ارفع جميع ملفات هذا المشروع إلى مستودع GitHub جديد، مع الحفاظ على المجلد المخفي `.github`.
2. افتح تبويب **Actions** في المستودع وفعّل workflows إذا طلب GitHub ذلك.
3. بعد رفع الملفات إلى فرع `main` سيبدأ البناء تلقائياً، أو اختر **Build Android APK** ثم **Run workflow**.
4. بعد نجاح التشغيل افتح نتيجة التشغيل ثم قسم **Artifacts** وحمّل `tariq-al-noor-release-apk`؛ بداخله ملف APK.

ملاحظة: GitHub يبني ملف APK فقط؛ تثبيت التطبيق وتشغيله يكون على هاتف Android. هذه النسخة تأسيسية وليست مكتملة بكل المواصفات المذكورة أعلاه، كما أن البناء لم يتم التحقق منه مسبقاً.
