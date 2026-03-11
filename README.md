<div dir="rtl" align="right">

# 📖 مصحف الحفظ — Mushaf Hifd

**تطبيق متكامل لمساعدة المسلمين على حفظ القرآن الكريم بطريقة تفاعلية وجميلة.**

</div>

---

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-Arabic%20(RTL)-gold?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Version-1.0.0-blueviolet?style=for-the-badge" />
</p>

---

## ✨ نظرة عامة | Overview

**مصحف الحفظ** هو تطبيق Flutter مصمم خصيصاً لمساعدة المسلمين في **حفظ القرآن الكريم** ومراجعته بأسلوب عصري وسلس.

> _Mushaf Hifd_ is a Flutter application designed to help Muslims **memorize and review the Holy Quran** with a modern, elegant, and fully Arabic-first experience.

---

## 🚀 المميزات | Features

| الميزة | الوصف |
|---|---|
| 📖 **قراءة المصحف** | عرض نصوص القرآن بخطوط عربية أصيلة |
| 🎙️ **صفحة التسميع** | مساعدة المستخدم على مراجعة محفوظاته وتسميعها |
| 📚 **صفحة التعلم** | تعلم الآيات بشكل تدريجي ومنظم |
| ⚙️ **إعدادات متقدمة** | تخصيص الخط والحجم وتباعد الأسطر |
| 🌙 **وضع مظلم** | واجهة داكنة أنيقة تريح العين أثناء القراءة |
| 🌐 **دعم RTL كامل** | دعم كامل للغة العربية واتجاه الكتابة من اليمين لليسار |

---

## 🎨 الخطوط المدعومة | Supported Fonts

التطبيق يدعم مجموعة من أجمل الخطوط العربية:

- **Andalus** — الخط الافتراضي *(الأندلس)*
- **Cairo** — خط القاهرة العصري
- **Droid Arabic Naskh** — خط النسخ العربي
- **Gara** — خط غارا
- **Traditional Arabic** — الخط العربي التقليدي
- **Amiri Quran** — خط أميري القرآني

---

## 🛠️ التقنيات المستخدمة | Tech Stack

```
Flutter SDK   ^3.x
Dart SDK      ^3.10.8
flutter_localizations  — دعم اللغة العربية
shared_preferences     — حفظ إعدادات المستخدم
```

---

## 📂 هيكل المشروع | Project Structure

```
mushaf_hifd/
├── lib/
│   ├── main.dart                  # نقطة البداية والثيم
│   ├── src/
│   │   ├── pages/
│   │   │   ├── splash_screen.dart   # شاشة البداية
│   │   │   ├── home_page.dart       # الصفحة الرئيسية
│   │   │   ├── learn_page.dart      # صفحة التعلم
│   │   │   ├── learn2_page.dart     # صفحة التعلم التفصيلية
│   │   │   ├── recite_page.dart     # صفحة التسميع
│   │   │   └── settings_page.dart   # صفحة الإعدادات
│   │   ├── theme/
│   │   │   └── theme_settings.dart  # إعدادات الثيم
│   │   └── constants.dart           # الثوابت
│   └── thomuns_txt/                 # ملفات نصوص القرآن
├── assets/
│   ├── fonts/                       # ملفات الخطوط العربية
│   └── splash/                      # صور شاشة البداية
├── android/                         # إعدادات أندرويد
├── ios/                             # إعدادات iOS
└── pubspec.yaml
```

---

## ⚙️ كيفية التشغيل | Getting Started

### المتطلبات | Requirements

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.x أو أعلى)
- [Dart SDK](https://dart.dev/get-dart) (v3.10.8 أو أعلى)
- جهاز Android أو iOS أو محاكي

### خطوات التشغيل | Run Steps

```bash
# 1. استنسخ المشروع
git clone https://github.com/your-username/mushaf_hifd.git
cd mushaf_hifd

# 2. ثبّت التبعيات
flutter pub get

# 3. شغّل التطبيق
flutter run
```

### البناء للإصدار | Build for Release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📜 حقوق الملكية | License

```
هذا التطبيق مُطوَّر بنية خالصة لخدمة كتاب الله.
جميع الحقوق محفوظة © 2025
```

---

<div align="center">

**﴿ وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ ﴾**

*صدق الله العظيم — سورة القمر: ١٧*

---

صُنع بـ ❤️ وإخلاص لخدمة القرآن الكريم

</div>
