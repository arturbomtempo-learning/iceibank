import 'package:flutter/widgets.dart';
import 'package:iceibank/app.dart';
import 'package:iceibank/config/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await AppDependencies.create();

  runApp(IceiBankApp(authRepository: dependencies.authRepository));
}
