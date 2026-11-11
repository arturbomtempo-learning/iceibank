import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: child,
    );
  }
}
