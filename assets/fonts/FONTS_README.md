# Font Files for Mushaf Hifd App

This folder contains custom font files used by the Mushaf Hifd application. To enable the additional fonts, download the following font files and place them in this directory.

## Required Fonts

### 1. **Andalus** (أندلس)
- Already included: `andalus.ttf`
- Original Quranic font

### 2. **Cairo** (القاهرة) - RECOMMENDED
- Download from: [Google Fonts - Cairo](https://fonts.google.com/specimen/Cairo)
- File: `cairo.ttf`
- A popular, modern Arabic font with good readability

### 3. **Droid Arabic Naskh**
- Download from: [Google Fonts - Droid Arabic Naskh](https://fonts.google.com/specimen/Droid+Arabic+Naskh)
- File: `droid_arabic_naskh.ttf`
- Professional and clean Quranic font

### 4. **Gara** (غارة - Urdu Traditional)
- Download from: [Gara Font](https://www.fontspace.com/gara-font-f20387) or similar sources
- File: `gara.ttf`
- Traditional Urdu/Arabic font

### 5. **Traditional Arabic**
- Download from: [Google Fonts - Traditional Arabic](https://fonts.google.com/specimen/Traditional+Arabic) or similar
- File: `traditional_arabic.ttf`
- Classic, formal Arabic font

### 6. **Amiri Quran** (عمير القرآني)
- Download from: [Amiri Font Project](https://www.amirifont.org/)
- File: `amiri_quran.ttf`
- Specifically designed for Quranic text

## Installation Steps

1. Download the font files (`.ttf` format)
2. Place them in this directory: `assets/fonts/`
3. Run `flutter clean` and then `flutter pub get`
4. Rebuild the app: `flutter run`

## Font Selection in App

Once fonts are installed, users can select any available font in the Settings page:
- الإعدادات → تخصيص الخط → اختر نوع الخط

## Notes

- Most fonts from Google Fonts are free to use under the SIL Open Font License
- Ensure the filename matches exactly what's specified in `pubspec.yaml`
- If a font file is missing, the app will fallback to the System font automatically
