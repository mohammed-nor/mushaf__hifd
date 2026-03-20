import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mushaf_hifd/src/theme/theme_settings.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/src/utils/responsive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Set<int> _learnedThomuns = {};
  Set<int> _revisedThomuns = {};

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedList = prefs.getStringList('learned_thomuns_txt') ?? [];
    final revisedList = prefs.getStringList('revised_thomuns_txt') ?? [];

    if (mounted) {
      setState(() {
        _learnedThomuns = learnedList.map((e) => int.tryParse(e) ?? 0).toSet();
        _revisedThomuns = revisedList.map((e) => int.tryParse(e) ?? 0).toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E2C), Color(0xFF12121D)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'الإعدادات',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall!.copyWith(color: Color(0xFF64FFDA)),
          ),
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
                    /* Text(
                      'تخصيص الخط',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: const Color(0xFF64FFDA)),
                    ), */
                    _buildSettingCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.font_download,
                              color: Color(0xFF1DE9B6),
                            ),
                            title: const Text('نوع الخط'),
                            trailing: DropdownButton<String>(
                              value: settings.fontFamily,
                              dropdownColor: const Color(0xFF1E1E2C),
                              underline: Container(),
                              items:
                                  [
                                    'System',
                                    'Andalus',
                                    'Cairo',
                                    'DroidArabicNaskh',
                                    'Gara',
                                    'TraditionalArabic',
                                    'AmiriQuran',
                                  ].map((String value) {
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
                                      child: Text(
                                        displayNames[value] ?? value,
                                        style: const TextStyle(
                                          color: Colors.white,
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
                          const Divider(color: Colors.white10),
                          ListTile(
                            leading: const Icon(
                              Icons.format_size,
                              color: Color(0xFF1DE9B6),
                            ),
                            title: const Text('حجم الخط'),
                            subtitle: Slider(
                              value: settings.fontSize,
                              min: 14,
                              max: 30,
                              divisions: 16,
                              activeColor: const Color(0xFF64FFDA),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(color: Colors.white10),
                          ListTile(
                            leading: const Icon(
                              Icons.line_weight,
                              color: Color(0xFF1DE9B6),
                            ),
                            title: const Text('تباعد الأسطر'),
                            subtitle: Slider(
                              value: settings.lineSpacing,
                              min: 1.0,
                              max: 2.0,
                              divisions: 20,
                              activeColor: const Color(0xFF64FFDA),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    /*  Text(
                      'حول التطبيق',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: const Color(0xFF64FFDA)),
                    ), */
                    _buildProgressCard(context),
                    const SizedBox(height: 32),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Icon(
                            Icons.info_outline,
                            size: 60,
                            color: Color(0xFF64FFDA),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'مصحف الحفظ - ورش مثمن',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تطبيق صمم خصيصاً لمساعدتك على حفظ القرآن الكريم وتسجيل ما تحفظه بسهولة.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 8),
                          const ListTile(
                            leading: Icon(
                              Icons.copyright,
                              color: Color(0xFF1DE9B6),
                              size: 35,
                            ),
                            title: Text('حقوق النشر'),
                            subtitle: Text(
                              'جميع الحقوق محفوظة © 2026',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDeveloperCard(context),
                    const SizedBox(height: 16),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final total = kThomunsTxt.length;
    final learned = _learnedThomuns.length;
    final revised = _revisedThomuns.length;
    final learnedAndRevised = _learnedThomuns
        .intersection(_revisedThomuns)
        .length;
    final learnedOnly = learned - learnedAndRevised;
    final advancement = total > 0
        ? (learned / total * 100).toStringAsFixed(1)
        : '0.0';

    return _buildSettingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقدم الحفظ',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: const Color(0xFF64FFDA)),
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
                  color: const Color(0xFF64FFDA),
                ),
                _buildStatWidget(
                  context,
                  label: 'الأحزاب المحفوظة',
                  value: '${learned / 8}',
                  color: const Color(0xFF64FFDA),
                ),
                _buildStatWidget(
                  context,
                  label: 'محفوظ ومراجع',
                  value: '$learnedAndRevised',
                  color: const Color(0xFF1DE9B6),
                ),
                _buildStatWidget(
                  context,
                  label: 'محفوظ فقط',
                  value: '$learnedOnly',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Progress dots chart
            Text(
              'خريطة الحفظ (8 ثمن في كل صف)',
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: Colors.white70),
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
          ).textTheme.labelSmall!.copyWith(color: Colors.white70),
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
                    color: Color(0xFF64FFDA),
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
                      dotColor = const Color(
                        0xFF1DE9B6,
                      ); // Green: revised and learned
                    } else if (isLearned) {
                      dotColor = Colors.orange; // Orange: learned only
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

  Widget _buildDeveloperCard(BuildContext context) {
    return _buildSettingCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'المطور',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: const Color(0xFF64FFDA)),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/devloper/NOR_MOHAMMED.png'),
            ),
            const SizedBox(height: 16),
            Text(
              'Mohammed Nor',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Phys/Chem Teacher - Phd in Chemistry - Apps developer\nLaboratory of Research and Development in Engineering Sciences (LRDES)\nUAE University, Tanger - Morocco',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactButton(
                  icon: Icons.email,
                  label: 'البريد',
                  onPressed: () {
                    _launchEmail('nour1608@gmail.com');
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
              'الإصدار 3.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.white54),
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
            border: Border.all(color: const Color(0xFF64FFDA), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF64FFDA), size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64FFDA),
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
