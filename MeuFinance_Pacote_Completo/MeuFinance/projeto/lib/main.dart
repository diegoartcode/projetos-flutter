import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MeuFinance());
}
class MeuFinance extends StatelessWidget {
  const MeuFinance({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MeuFinance', debugShowCheckedModeBanner: false,
    theme: appTheme, locale: const Locale('pt','BR'),
    supportedLocales: const [Locale('pt','BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const AuthGate(),
  );
}
