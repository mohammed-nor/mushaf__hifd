import 'package:flutter/material.dart';

import 'package:mushaf_hifd/src/theme/theme_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E1E2C), Color(0xFF12121D)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('الإعدادات', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Color(0xFF64FFDA))),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ValueListenableBuilder<ThemeSettings>(
            valueListenable: themeSettingsNotifier,
            builder: (context, settings, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('تخصيص الخط', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: const Color(0xFF64FFDA))),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.font_download, color: Color(0xFF1DE9B6)),
                            title: const Text('نوع الخط'),
                            trailing: DropdownButton<String>(
                              value: settings.fontFamily,
                              dropdownColor: const Color(0xFF1E1E2C),
                              underline: Container(),
                              items: ['System', 'Andalus', 'Cairo', 'DroidArabicNaskh', 'Gara', 'TraditionalArabic', 'AmiriQuran'].map((String value) {
                                final displayNames = {
                                  'System': 'خط النظام',
                                  'Andalus': 'خط الأندلس',
                                  'Cairo': 'خط القاهرة',
                                  'DroidArabicNaskh': 'خط Droid العربي',
                                  'Gara': 'خط غارة (أردي)',
                                  'TraditionalArabic': 'خط عربي تقليدي',
                                  'AmiriQuran': 'خط عمير القرآني',
                                };
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(displayNames[value] ?? value, style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  updateThemeSettings(newValue, settings.fontSize, settings.lineSpacing);
                                }
                              },
                            ),
                          ),
                          const Divider(color: Colors.white10),
                          ListTile(
                            leading: const Icon(Icons.format_size, color: Color(0xFF1DE9B6)),
                            title: const Text('حجم الخط'),
                            subtitle: Slider(
                              value: settings.fontSize,
                              min: 14,
                              max: 30,
                              divisions: 8,
                              activeColor: const Color(0xFF64FFDA),
                              label: settings.fontSize.round().toString(),
                              onChanged: (double value) {
                                updateThemeSettings(settings.fontFamily, value, settings.lineSpacing);
                              },
                            ),
                            trailing: Text(settings.fontSize.round().toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const Divider(color: Colors.white10),
                          ListTile(
                            leading: const Icon(Icons.line_weight, color: Color(0xFF1DE9B6)),
                            title: const Text('تباعد الأسطر'),
                            subtitle: Slider(
                              value: settings.lineSpacing,
                              min: 1.0,
                              max: 2.0,
                              divisions: 10,
                              activeColor: const Color(0xFF64FFDA),
                              label: settings.lineSpacing.toStringAsFixed(1),
                              onChanged: (double value) {
                                updateThemeSettings(settings.fontFamily, settings.fontSize, value);
                              },
                            ),
                            trailing: Text(settings.lineSpacing.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('حول التطبيق', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: const Color(0xFF64FFDA))),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Icon(Icons.info_outline, size: 60, color: Color(0xFF64FFDA)),
                          const SizedBox(height: 16),
                          Text(
                            'مصحف الحفظ - ورش مثمن',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تطبيق صمم خصيصاً لمساعدتك على حفظ القرآن الكريم وتسجيل ما تحفظه بسهولة.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10),
                          const ListTile(
                            leading: Icon(Icons.copyright, color: Color(0xFF1DE9B6)),
                            title: Text('حقوق النشر'),
                            subtitle: Text('جميع الحقوق محفوظة للمطور محمد نور © 2026', style: TextStyle(color: Colors.white54)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'الإصدار 1.0.0',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
