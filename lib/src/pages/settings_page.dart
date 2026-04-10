import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:mushaf_hifd/src/services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Set<int> _learnedThomuns = {};
  Set<int> _revisedThomuns = {};
  String _reminderTime = '09:00';

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedList = prefs.getStringList('learned_thomuns_txt') ?? [];
    final revisedList = prefs.getStringList('revised_thomuns_txt') ?? [];
    final reminderTime = prefs.getString('revision_reminder_time') ?? '09:00';

    if (mounted) {
      setState(() {
        _learnedThomuns = learnedList.map((e) => int.tryParse(e) ?? 0).toSet();
        _revisedThomuns = revisedList.map((e) => int.tryParse(e) ?? 0).toSet();
        _reminderTime = reminderTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: themeSettingsNotifier,
      builder: (context, settings, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: settings.backgroundGradient,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'الإعدادات',
                style: TextStyle(
                  color: settings.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /* Text(
                      'تخصيص الخط',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: kPrimaryTeal)),
                    ), */
                    _buildSettingCard(
                      settings: settings,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.brightness_4,
                              color: kPrimaryTeal,
                            ),
                            title: Text(
                              'المظهر',
                              style: TextStyle(color: settings.textColor),
                            ),
                            trailing: Switch(
                              value: !settings.isDarkMode,
                              onChanged: (bool value) {
                                updateThemeMode(!value);
                              },
                              activeTrackColor: kPrimaryTeal.withAlpha(100),
                              activeThumbColor: kPrimaryTeal,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ),
                          if (Platform.isWindows ||
                              Platform.isLinux ||
                              Platform.isMacOS) ...[
                            Divider(
                              color: settings.isDarkMode
                                  ? kLightBackground.withAlpha(20)
                                  : Colors.black12,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.rocket_launch,
                                color: kPrimaryTeal,
                              ),
                              title: Text(
                                'التشغيل التلقائي',
                                style: TextStyle(color: settings.textColor),
                              ),
                              subtitle: Text(
                                'تشغيل التطبيق تلقائياً عند بدء تشغيل الجهاز',
                                style: TextStyle(
                                  color: settings.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Switch(
                                value: settings.autostart,
                                onChanged: (bool value) {
                                  updateAutostart(value);
                                },
                                activeTrackColor: kPrimaryTeal.withAlpha(100),
                                activeThumbColor: kPrimaryTeal,
                                inactiveThumbColor: Colors.grey,
                              ),
                            ),
                            Divider(
                              color: settings.isDarkMode
                                  ? kLightBackground.withAlpha(20)
                                  : Colors.black12,
                            ),
                          ],
                          ListTile(
                            leading: const Icon(
                              Icons.light_mode,
                              color: kPrimaryTeal,
                            ),
                            title: Text(
                              'إبقاء الشاشة مضاءة',
                              style: TextStyle(color: settings.textColor),
                            ),
                            subtitle: Text(
                              'منع الشاشة من الإغلاق أثناء القراءة',
                              style: TextStyle(
                                color: settings.textColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Switch(
                              value: settings.keepScreenOn,
                              onChanged: (bool value) {
                                updateKeepScreenOn(value);
                              },
                              activeTrackColor: kPrimaryTeal.withAlpha(100),
                              activeThumbColor: kPrimaryTeal,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ),
                          Divider(
                            color: settings.isDarkMode
                                ? kLightBackground.withAlpha(20)
                                : Colors.black12,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.font_download,
                              color: kPrimaryTeal,
                            ),
                            title: Text(
                              'نوع الخط',
                              style: TextStyle(color: settings.textColor),
                            ),
                            trailing: DropdownButton<String>(
                              value: settings.fontFamily,
                              dropdownColor: settings.isDarkMode
                                  ? kDarkBackground
                                  : kLightBackground,
                              underline: Container(),
                              items:
                                  [
                                    'System',
                                    'Amiri',
                                    'Scheherazade New',
                                    'Noto Naskh Arabic',
                                    'Cairo',
                                    'Almarai',
                                    'Aref Ruqaa',
                                    'Markazi Text',
                                    'Harmattan',
                                    'Reem Kufi',
                                    'Mada',
                                    'Mirza',
                                    'Lateef',
                                    'Tajawal',
                                    'El Messiri',
                                    'Gulzar',
                                    'Alkalami',
                                    'Vazirmatn',
                                    'Katibeh',
                                    'Readex Pro',
                                  ].map((String value) {
                                    final displayNames = {
                                      'System': 'خط النظام',
                                      'Amiri': 'خط الأميري',
                                      'Scheherazade New':
                                          'الرسم المغربي الأصيل',
                                      'Noto Naskh Arabic': 'خط نوتو نسخ',
                                      'Cairo': 'خط القاهرة',
                                      'Almarai': 'خط المراعي',
                                      'Aref Ruqaa': 'خط عارف رقعة',
                                      'Markazi Text': 'خط مركزي',
                                      'Harmattan': 'خط هرماتان',
                                      'Reem Kufi': 'خط ريم كوفي',
                                      'Mada': 'خط مدى',
                                      'Mirza': 'خط ميرزا',
                                      'Lateef': 'خط لطيف',
                                      'Tajawal': 'خط تجول',
                                      'El Messiri': 'خط المسيري',
                                      'Gulzar': 'خط جولزار',
                                      'Alkalami': 'خط القلمي',
                                      'Vazirmatn': 'خط وزير',
                                      'Katibeh': 'خط كتيبة',
                                      'Readex Pro': 'خط ريديكس بروب',
                                    };
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        displayNames[value] ?? value,
                                        style: TextStyle(
                                          color: settings.textColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  updateThemeSettings(
                                    newValue,
                                    settings.fontSize,
                                    settings.lineSpacing,
                                  );
                                }
                              },
                            ),
                          ),
                          Divider(
                            color: settings.isDarkMode
                                ? kLightBackground.withAlpha(20)
                                : Colors.black12,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.format_size,
                              color: kPrimaryTeal,
                            ),
                            title: Text(
                              'حجم الخط',
                              style: TextStyle(color: settings.textColor),
                            ),
                            subtitle: Slider(
                              value: settings.fontSize,
                              min: 14,
                              max: 30,
                              divisions: 16,
                              activeColor: kPrimaryTeal,
                              inactiveColor: Colors.grey.withAlpha(77),
                              label: settings.fontSize.round().toString(),
                              onChanged: (double value) {
                                updateThemeSettings(
                                  settings.fontFamily,
                                  value,
                                  settings.lineSpacing,
                                );
                              },
                            ),
                            trailing: Text(
                              settings.fontSize.round().toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: settings.textColor,
                              ),
                            ),
                          ),
                          Divider(
                            color: settings.isDarkMode
                                ? kLightBackground.withAlpha(20)
                                : Colors.black12,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.line_weight,
                              color: kPrimaryTeal,
                            ),
                            title: Text(
                              'تباعد الأسطر',
                              style: TextStyle(color: settings.textColor),
                            ),
                            subtitle: Slider(
                              value: settings.lineSpacing,
                              min: 1.0,
                              max: 2.0,
                              divisions: 20,
                              activeColor: kPrimaryTeal,
                              inactiveColor: Colors.grey.withAlpha(77),
                              label: settings.lineSpacing.toStringAsFixed(1),
                              onChanged: (double value) {
                                updateThemeSettings(
                                  settings.fontFamily,
                                  settings.fontSize,
                                  value,
                                );
                              },
                            ),
                            trailing: Text(
                              settings.lineSpacing.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: settings.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Background colour picker ─────────────────────────
                    _buildBgThemePicker(context, settings),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveHeight(
                        context,
                        0.02,
                      ),
                    ),
                    _buildTextColorPicker(context, settings),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveHeight(
                        context,
                        0.03,
                      ),
                    ),
                    _buildSettingCard(
                      settings: settings,
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: kPrimaryTeal,
                        ),
                        title: const Text('تذكير كل 3 ساعات'),
                        subtitle: Text(
                          'تبدأ التذكيرات من $_reminderTime وتتكرر كل 3 ساعات طوال اليوم',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: int.parse(_reminderTime.split(':')[0]),
                                minute: int.parse(_reminderTime.split(':')[1]),
                              ),
                            );
                            if (picked != null) {
                              final timeString =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              setState(() {
                                _reminderTime = timeString;
                              });
                              await NotificationService.instance
                                  .setReminderTime(timeString);
                              // Re-schedule all active reminders with the new time
                              await NotificationService.instance
                                  .rescheduleAllReminders();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم تحديث التذكيرات — تبدأ من $timeString كل 3 ساعات',
                                    ),
                                    backgroundColor: kPrimaryTeal,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('تغيير'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveHeight(
                        context,
                        0.03,
                      ),
                    ),

                    /*  Text(
                      'حول التطبيق',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: kSecondaryTeal),
                    ), */
                    _buildProgressCard(context, settings),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveHeight(
                        context,
                        0.03,
                      ),
                    ),

                    _buildSettingCard(
                      settings: settings,
                      child: Column(
                        children: [
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.025,
                            ),
                          ),
                          const Icon(
                            Icons.info_outline,
                            size: 60,
                            color: kPrimaryTeal,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.02,
                            ),
                          ),
                          Text(
                            'مصحف الحفظ - ورش مثمن',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: settings.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.01,
                            ),
                          ),
                          Text(
                            'تطبيق صمم خصيصاً لمساعدتك على حفظ القرآن الكريم وتسجيل ما تحفظه بسهولة.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: settings.isDarkMode
                                      ? kLightBackground
                                      : Colors.black54,
                                ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.01,
                            ),
                          ),
                          Divider(
                            color: settings.isDarkMode
                                ? kLightBackground.withAlpha(20)
                                : Colors.black12,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveHeight(
                              context,
                              0.01,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.copyright,
                              color: kPrimaryTeal,
                              size: 35,
                            ),
                            title: const Text('حقوق النشر'),
                            subtitle: Text(
                              'جميع الحقوق محفوظة © 2026',
                              style: TextStyle(
                                color: settings.textColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveHeight(
                        context,
                        0.03,
                      ),
                    ),
                    _buildDeveloperCard(context, settings),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveHeight(
                        context,
                        0.02,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingCard({
    required Widget child,
    required ThemeSettings settings,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kLightBackground.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: settings.isDarkMode
              ? kLightBackground.withAlpha(20)
              : Colors.black.withAlpha(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.0),
            blurRadius: 3,
            //offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBgThemePicker(BuildContext context, ThemeSettings settings) {
    final darkThemes = kBgThemes.where((t) => t.isDark).toList();
    final lightThemes = kBgThemes.where((t) => !t.isDark).toList();
    final selectedDark = settings.darkBgTheme;
    final selectedLight = settings.lightBgTheme;

    Widget swatch(BgThemeOption opt, bool isSelected) {
      return GestureDetector(
        onTap: () {
          if (opt.isDark) {
            updateBgTheme(darkBgTheme: opt.key);
          } else {
            updateBgTheme(lightBgTheme: opt.key);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [opt.start, opt.end],
            ),
            border: Border.all(
              color: isSelected ? kPrimaryTeal : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? kPrimaryTeal.withAlpha(100)
                    : Colors.black.withAlpha(40),
                blurRadius: isSelected ? 8 : 3,
              ),
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check, color: kPrimaryTeal, size: 22)
              : null,
        ),
      );
    }

    return _buildSettingCard(
      settings: settings,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: kPrimaryTeal, size: 22),
                const SizedBox(width: 10),
                Text(
                  'لون الخلفية',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: kPrimaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Dark mode swatches ──────────────────────────────────────
            Text(
              'الوضع الداكن',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: darkThemes.map((opt) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    swatch(opt, opt.key == selectedDark),
                    const SizedBox(height: 4),
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: settings.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            // ── Light mode swatches ─────────────────────────────────────
            Text(
              'الوضع الفاتح',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: lightThemes.map((opt) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    swatch(opt, opt.key == selectedLight),
                    const SizedBox(height: 4),
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: settings.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextColorPicker(BuildContext context, ThemeSettings settings) {
    final darkTextOptions = kTextColors.where((t) => t.isDark).toList();
    final lightTextOptions = kTextColors.where((t) => !t.isDark).toList();
    final currentDarkKey = settings.darkTextColor;
    final currentLightKey = settings.lightTextColor;

    Widget colorBox(TextColorOption opt, bool isSelected) {
      return GestureDetector(
        onTap: () {
          if (opt.isDark) {
            updateTextColor(darkTextColor: opt.key);
          } else {
            updateTextColor(lightTextColor: opt.key);
          }
        },
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: opt.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryTeal : Colors.grey.withAlpha(100),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kPrimaryTeal.withAlpha(80),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: (opt.color.computeLuminance() > 0.5)
                          ? Colors.black
                          : Colors.white,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              opt.label,
              style: TextStyle(
                fontSize: 10,
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return _buildSettingCard(
      settings: settings,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_format, color: kPrimaryTeal, size: 22),
                const SizedBox(width: 10),
                Text(
                  'لون النص',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: kPrimaryTeal),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'ألوان الوضع الداكن',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: darkTextOptions
                  .map((opt) => colorBox(opt, opt.key == currentDarkKey))
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text(
              'ألوان الوضع الفاتح',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: lightTextOptions
                  .map((opt) => colorBox(opt, opt.key == currentLightKey))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeSettings settings) {
    final total = kThomunsTxt.length;
    final learned = _learnedThomuns.length;
    final learnedAndRevised = _learnedThomuns
        .intersection(_revisedThomuns)
        .length;
    final learnedOnly = learned - learnedAndRevised;
    final advancement = total > 0
        ? (learned / total * 100).toStringAsFixed(1)
        : '0.0';

    return _buildSettingCard(
      settings: settings,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقدم الحفظ',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: kPrimaryTeal),
            ),

            const SizedBox(height: 16),
            // Advancement statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatWidget(
                  context,
                  label: 'نسبة الحفظ',
                  value: '$advancement%',
                  color: kPrimaryTeal,
                  labelColor: settings.textColor.withValues(alpha: 0.7),
                ),
                _buildStatWidget(
                  context,
                  label: 'الأحزاب المحفوظة',
                  value: '${learned / 8}',
                  color: kPrimaryTeal,
                  labelColor: settings.textColor.withValues(alpha: 0.7),
                ),
                _buildStatWidget(
                  context,
                  label: 'محفوظ ومراجع',
                  value: '$learnedAndRevised',
                  color: kPrimaryTeal,
                  labelColor: settings.textColor.withValues(alpha: 0.7),
                ),
                _buildStatWidget(
                  context,
                  label: 'محفوظ فقط',
                  value: '$learnedOnly',
                  color: kOrangeAccent,
                  labelColor: settings.textColor.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Progress dots chart
            Text(
              'خريطة الحفظ (8 ثمن في كل صف)',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressDotsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatWidget(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required Color labelColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: labelColor),
        ),
      ],
    );
  }

  Widget _buildProgressDotsChart() {
    final int dotsPerRow = 8;
    final int totalRows = (kThomunsTxt.length / dotsPerRow).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        final int startIndex = rowIndex * dotsPerRow;
        final int endIndex = (startIndex + dotsPerRow > kThomunsTxt.length)
            ? kThomunsTxt.length
            : startIndex + dotsPerRow;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hisb label
              SizedBox(
                width: ResponsiveUtils.getResponsiveWidth(context, 0.13),
                child: Text(
                  'الحزب ${rowIndex + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kPrimaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // Dots
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: endIndex - startIndex,
                  itemBuilder: (context, dotIndex) {
                    final int index = startIndex + dotIndex;
                    final isRevised = _revisedThomuns.contains(index);
                    final isLearned = _learnedThomuns.contains(index);

                    Color dotColor;
                    if (isRevised && isLearned) {
                      dotColor = kPrimaryTeal; // Green: revised and learned
                    } else if (isLearned) {
                      dotColor = kOrangeAccent; // Orange: learned only
                    } else {
                      dotColor = Colors.grey.withAlpha(
                        128,
                      ); // Grey: not learned or revised
                    }

                    return Tooltip(
                      message: 'الثمن ${index + 1}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDeveloperCard(BuildContext context, ThemeSettings settings) {
    return _buildSettingCard(
      settings: settings,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'المطور',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: kPrimaryTeal),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'NOR Mohammed\nNOR It! team',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: settings.textColor),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/devloper/NOR_MOHAMMED.png',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactButton(
                  icon: Icons.email,
                  label: 'البريد',
                  onPressed: () {
                    _launchEmail('nor.it.services@gmail.com');
                  },
                ),
                const SizedBox(width: 26),
                _buildContactButton(
                  icon: Icons.code,
                  label: 'GitHub',
                  onPressed: () {
                    _launchURL('https://github.com/mohammed-nor/');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'الإصدار 1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: settings.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: kPrimaryTeal, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: kPrimaryTeal, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: kPrimaryTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
