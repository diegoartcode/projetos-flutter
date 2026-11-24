import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';
Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 if (const bool.fromEnvironment('USAR_EMULADORES')) {
  const host = String.fromEnvironment('EMULADOR_HOST', defaultValue: '10.0.2.2');
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
 }
 runApp(MaterialApp(debugShowCheckedModeBanner:false,title:'AdotaPet',theme:AppTheme.tema,home:const AuthGate()));
}
