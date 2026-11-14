import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iceibank/config/dependencies.dart';
import 'package:iceibank/ui/auth/widgets/login_screen.dart';
import 'package:iceibank/ui/core/themes/app_theme.dart';
import 'package:iceibank/ui/home/widgets/home_screen.dart';

class IceiBankApp extends StatelessWidget {
  const IceiBankApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final authRepository = dependencies.authRepository;

    return CupertinoApp(
      title: 'ICEIBank',
      theme: AppTheme.data,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalCupertinoLocalizations.delegates,
      home: ListenableBuilder(
        listenable: authRepository,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: authRepository.isAuthenticated
              ? HomeScreen(
                  key: const ValueKey('home'),
                  authRepository: authRepository,
                  accountRepository: dependencies.accountRepository,
                  userRepository: dependencies.userRepository,
                  agencyRepository: dependencies.agencyRepository,
                  leadershipRepository: dependencies.leadershipRepository,
                )
              : LoginScreen(key: const ValueKey('login'), authRepository: authRepository),
        ),
      ),
    );
  }
}
