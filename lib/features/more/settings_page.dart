import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/tr_text.dart';
import '../../core/widgets/belling_ui.dart';
import '../../l10n/app_localizations.dart';
import 'app_lock_card.dart';

final _appVersionProvider = FutureProvider.autoDispose<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Settings: language, app lock, legal and app version in one place.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final version = ref.watch(_appVersionProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BellingHeader(title: 'Settings', subtitle: 'Language, lock, app info', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconTile(
                              icon: Icons.language,
                              color: AppColors.accent,
                              background: AppColors.warnBg,
                              size: 38,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.language,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(value: 'en', label: Text(l10n.english)),
                              ButtonSegment<String>(value: 'hi', label: Text(l10n.hindi)),
                              ButtonSegment<String>(value: 'gu', label: Text(l10n.gujarati)),
                            ],
                            selected: {locale.languageCode},
                            onSelectionChanged: (s) {
                              if (s.isNotEmpty) {
                                ref.read(localeProvider.notifier).setLanguageCode(s.first);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppLockCard(),
                  const SizedBox(height: 16),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const IconTile(
                        icon: Icons.policy_outlined,
                        color: Color(0xFF0F9D8A),
                        background: Color(0xFFDDF5F1),
                        size: 38,
                      ),
                      title: const Text('Privacy & legal', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Data aur GST records'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/more/legal'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Row(
                      children: [
                        const IconTile(
                          icon: Icons.info_outline,
                          color: AppColors.blue,
                          background: AppColors.blueBg,
                          size: 38,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Belling', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                        Text(version == null ? '' : 'v$version',
                            style: const TextStyle(color: AppColors.lightMuted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
