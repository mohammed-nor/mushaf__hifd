import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';
import 'package:mushaf_hifd/src/services/notification_service.dart';
import 'package:mushaf_hifd/src/services/progress_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _reminderTime = '09:00';

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderTime = prefs.getString('revision_reminder_time') ?? '09:00';

    if (mounted) {
      setState(() {
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
              toolbarHeight: 38,
              //toolbarHeight: 70,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'الإعدادات',
                  style: TextStyle(
                    color: settings.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize:
                        ResponsiveUtils.sp(context, 14) * settings.fontScale,
                  ),
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: ListenableBuilder(
                listenable: progressService,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /* Text(
                      'تخصيص الخط',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: settings.primaryColor)),
                    ), */
                        _buildSettingCard(
                          settings: settings,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.brightness_4,
                                  color: settings.primaryColor,
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
                                  activeTrackColor: settings.primaryColor
                                      .withAlpha(100),
                                  activeThumbColor: settings.primaryColor,
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
                                  leading: Icon(
                                    Icons.rocket_launch,
                                    color: settings.primaryColor,
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
                                      fontSize:
                                          ResponsiveUtils.sp(context, 12) *
                                          settings.fontScale,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: settings.autostart,
                                    onChanged: (bool value) {
                                      updateAutostart(value);
                                    },
                                    activeTrackColor: settings.primaryColor
                                        .withAlpha(100),
                                    activeThumbColor: settings.primaryColor,
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
                                leading: Icon(
                                  Icons.light_mode,
                                  color: settings.primaryColor,
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
                                    fontSize:
                                        ResponsiveUtils.sp(context, 12) *
                                        settings.fontScale,
                                  ),
                                ),
                                trailing: Switch(
                                  value: settings.keepScreenOn,
                                  onChanged: (bool value) {
                                    updateKeepScreenOn(value);
                                  },
                                  activeTrackColor: settings.primaryColor
                                      .withAlpha(100),
                                  activeThumbColor: settings.primaryColor,
                                  inactiveThumbColor: Colors.grey,
                                ),
                              ),
                              Divider(
                                color: settings.isDarkMode
                                    ? kLightBackground.withAlpha(20)
                                    : Colors.black12,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.font_download,
                                  color: settings.primaryColor,
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
                                leading: Icon(
                                  Icons.format_size,
                                  color: settings.primaryColor,
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
                                  activeColor: settings.primaryColor,
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
                                    fontSize:
                                        ResponsiveUtils.sp(context, 16) *
                                        settings.fontScale,
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
                                leading: Icon(
                                  Icons.line_weight,
                                  color: settings.primaryColor,
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
                                  activeColor: settings.primaryColor,
                                  inactiveColor: Colors.grey.withAlpha(77),
                                  label: settings.lineSpacing.toStringAsFixed(
                                    1,
                                  ),
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
                                    fontSize:
                                        ResponsiveUtils.sp(context, 16) *
                                        settings.fontScale,
                                    fontWeight: FontWeight.bold,
                                    color: settings.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildUnifiedColorPicker(context, settings),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveHeight(
                            context,
                            0.03,
                          ),
                        ),
                        _buildSettingCard(
                          settings: settings,
                          child: ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: settings.primaryColor,
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
                                    hour: int.parse(
                                      _reminderTime.split(':')[0],
                                    ),
                                    minute: int.parse(
                                      _reminderTime.split(':')[1],
                                    ),
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
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم تحديث التذكيرات — تبدأ من $timeString كل 3 ساعات',
                                        ),
                                        backgroundColor: settings.primaryColor,
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
                              Icon(
                                Icons.info_outline,
                                size: 60,
                                color: settings.primaryColor,
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
                              SizedBox(height: 10),

                              Text(
                                'جميع الحقوق محفوظة © 2026',
                                style: TextStyle(
                                  color: settings.textColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.getResponsiveHeight(
                                  context,
                                  0.025,
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
                  );
                },
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

  Widget _buildUnifiedColorPicker(
    BuildContext context,
    ThemeSettings settings,
  ) {
    return _buildSettingCard(
      settings: settings,
      child: Column(
        children: [
          _buildBgThemePicker(context, settings),
          Divider(
            color: settings.isDarkMode
                ? kLightBackground.withAlpha(20)
                : Colors.black12,
            indent: 12,
            endIndent: 12,
          ),
          _buildAccentColorPicker(context, settings),
          Divider(
            color: settings.isDarkMode
                ? kLightBackground.withAlpha(20)
                : Colors.black12,
            indent: 12,
            endIndent: 12,
          ),
          _buildTextColorPicker(context, settings),
        ],
      ),
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
              color: isSelected ? settings.primaryColor : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? settings.primaryColor.withAlpha(100)
                    : Colors.black.withAlpha(40),
                blurRadius: isSelected ? 8 : 3,
              ),
            ],
          ),
          child: isSelected
              ? Icon(Icons.check, color: settings.primaryColor, size: 22)
              : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: settings.primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'لون الخلفية',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: settings.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (settings.isDarkMode) ...[
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
                        fontSize:
                            ResponsiveUtils.sp(context, 9.5) *
                            settings.fontScale,
                        color: settings.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ] else ...[
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
                        fontSize:
                            ResponsiveUtils.sp(context, 9.5) *
                            settings.fontScale,
                        color: settings.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccentColorPicker(BuildContext context, ThemeSettings settings) {
    final currentKey = settings.accentColor;

    Widget colorBox(AccentColorOption opt, bool isSelected) {
      return GestureDetector(
        onTap: () {
          updateAccentColor(opt.key);
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
                  color: isSelected ? opt.color : Colors.grey.withAlpha(100),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: opt.color.withAlpha(80), blurRadius: 8)]
                    : null,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              opt.label,
              style: TextStyle(
                fontSize: ResponsiveUtils.sp(context, 10) * settings.fontScale,
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.color_lens, color: settings.primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'لون التمييز الأساسي',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: settings.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: kAccentColors
                .map((opt) => colorBox(opt, opt.key == currentKey))
                .toList(),
          ),
        ],
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
                  color: isSelected
                      ? settings.primaryColor
                      : Colors.grey.withAlpha(100),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: settings.primaryColor.withAlpha(80),
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
                fontSize: ResponsiveUtils.sp(context, 10) * settings.fontScale,
                color: settings.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_format, color: settings.primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'لون النص',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: settings.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (settings.isDarkMode) ...[
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
          ] else ...[
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
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeSettings settings) {
    final total = kThomunsTxt.length;
    final learned = progressService.learnedThomuns.length;
    final learnedAndRevised = progressService.learnedThomuns
        .intersection(progressService.revisedThomuns)
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
              ).textTheme.titleLarge!.copyWith(color: settings.primaryColor),
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
                  color: settings.primaryColor,
                  labelColor: settings.textColor.withValues(alpha: 0.7),
                ),
                _buildStatWidget(
                  context,
                  label: 'الأحزاب المحفوظة',
                  value: '${learned / 8}',
                  color: settings.primaryColor,
                  labelColor: settings.textColor.withValues(alpha: 0.7),
                ),
                _buildStatWidget(
                  context,
                  label: 'محفوظ ومراجع',
                  value: '$learnedAndRevised',
                  color: settings.primaryColor,
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
            _buildProgressDotsChart(settings),
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

  Widget _buildProgressDotsChart(ThemeSettings settings) {
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
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.sp(context, 12) * settings.fontScale,
                    color: settings.primaryColor,
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
                    final isRevised = progressService.revisedThomuns.contains(
                      index,
                    );
                    final isLearned = progressService.learnedThomuns.contains(
                      index,
                    );

                    Color dotColor;
                    if (isRevised && isLearned) {
                      dotColor =
                          settings.primaryColor; // Green: revised and learned
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
              'المطوّر',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: settings.primaryColor),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage(
                    'assets/devloper/NOR_MOHAMMED.png',
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'محمد نور\nفريق NOR It!',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: settings.textColor),
                  textAlign: TextAlign.right,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Support message ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: settings.primaryColor.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: settings.primaryColor.withAlpha(40)),
              ),
              child: Text(
                'إذا أعجبك التطبيق، ادعمنا بتقييم على متجر Google Play '
                'ومشاركته مع أصدقائك وأحبابك. دعمكم يساعدنا على '
                'تطوير المزيد من التطبيقات الإسلامية المجانية. '
                'جزاكم الله خيراً 🤲',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: settings.textColor.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Action buttons ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactButton(
                  icon: Icons.email,
                  label: 'البريد',
                  settings: settings,
                  onPressed: () {
                    _launchEmail('nor.it.services@gmail.com');
                  },
                ),
                const SizedBox(width: 10),
                _buildContactButton(
                  icon: Icons.code,
                  label: 'GitHub',
                  settings: settings,
                  onPressed: () {
                    _launchURL('https://github.com/mohammed-nor/');
                  },
                ),
                const SizedBox(width: 10),
                _buildContactButton(
                  icon: Icons.store,
                  label: 'تطبيقاتنا',
                  settings: settings,
                  onPressed: () {
                    _launchURL(
                      'https://play.google.com/store/apps/dev?id=6694339020319831911',
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildContactButton(
                  icon: Icons.share,
                  label: 'شارك التطبيق',
                  settings: settings,
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'مصحف الحفظ - ورش مثمن\n'
                            'تطبيق رائع لحفظ القرآن الكريم ومتابعة تقدمك 📖\n\n'
                            'حمّله الآن من متجر Google Play:\n'
                            'https://play.google.com/store/apps/dev?id=6694339020319831911',
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'الإصدار 1.0.1',
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
    required ThemeSettings settings,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: settings.primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: settings.primaryColor, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: settings.primaryColor,
                  fontSize:
                      ResponsiveUtils.sp(context, 12) * settings.fontScale,
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
