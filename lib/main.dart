import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'core/providers/locale_provider.dart';
import 'core/reminder_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/splash_gate.dart';
import 'data/providers.dart';
import 'features/more/app_lock_gate.dart';
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
  // Make sure the real business/device ids are loaded before any screen can
  // build a repository with the 'local-*' fallback ids.
  await ref.read(activeBusinessProvider.future);
  await ref.read(activeDeviceProvider.future);
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
        child: AppLockGate(child: _SyncStarter(child: _ReminderScheduler(child: child ?? const SizedBox.shrink()))),
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

/// Re-plans the daily udhar notification when the app opens and whenever it
/// goes to the background (so the numbers in it are fresh).
class _ReminderScheduler extends ConsumerStatefulWidget {
  const _ReminderScheduler({required this.child});
  final Widget child;

  @override
  ConsumerState<_ReminderScheduler> createState() => _ReminderSchedulerState();
}

class _ReminderSchedulerState extends ConsumerState<_ReminderScheduler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refresh() {
    ReminderService.instance.refresh(ref.read(databaseProvider), ref.read(partyRepositoryProvider));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _refresh();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
