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
          title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2)),
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
                    const Text(
                      'تخصيص الخط',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF64FFDA)),
                    ),
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
                              items: ['Andalus', 'System'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value == 'System' ? 'خط النظام' : value, style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  updateThemeSettings(newValue, settings.fontSize);
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
                                updateThemeSettings(settings.fontFamily, value);
                              },
                            ),
                            trailing: Text(settings.fontSize.round().toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'حول التطبيق',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF64FFDA)),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Icon(Icons.info_outline, size: 60, color: Color(0xFF64FFDA)),
                          const SizedBox(height: 16),
                          const Text(
                            'مصحف الحفظ - ورش مثمن',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'تطبيق صمم خصيصاً لمساعدتك على حفظ القرآن الكريم وتسجيل ما تحفظه بسهولة.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white70),
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
                    const Text(
                      'الإصدار 1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
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
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: child,
    );
  }
}
