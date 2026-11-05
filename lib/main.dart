import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/splash_gate.dart';
import 'data/providers.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'sync/sync_providers.dart';

/// Started in main() but NOT awaited, so the first frame (splash) is drawn
/// immediately instead of a black screen.
late final Future<void> supabaseReady;

Future<void> _initSupabase() async {
  try {
    await Supabase.initialize(
      url: kSupabaseUrl,
      publishableKey: kSupabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  } catch (e) {
    debugPrint('Supabase initialization warning/error (offline mode active): $e');
  }
}

/// Completes when Supabase is up and the local database is open + seeded.
final appReadyProvider = FutureProvider<void>((ref) async {
  await Future.wait<void>([
    supabaseReady,
    ref.read(initializeAppProvider.future),
  ]);
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  supabaseReady = _initSupabase();

  runApp(
    const ProviderScope(
      child: UniversalBillingApp(),
    ),
  );
}

class UniversalBillingApp extends ConsumerWidget {
  const UniversalBillingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Universal Billing',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.getLightTheme(locale),
      darkTheme: AppTheme.getDarkTheme(locale),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => SplashGate(
        ready: ref.read(appReadyProvider.future),
        child: _SyncStarter(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Starts the background sync worker only after the splash (Supabase is ready).
class _SyncStarter extends ConsumerWidget {
  const _SyncStarter({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncBootstrapProvider);
    return child;
  }
}
