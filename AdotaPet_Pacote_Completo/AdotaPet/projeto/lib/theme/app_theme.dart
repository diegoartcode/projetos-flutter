import 'package:flutter/material.dart';
class AppTheme {
 static ThemeData get tema => ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff276749)),scaffoldBackgroundColor:const Color(0xfff7f9f7),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder()),appBarTheme:const AppBarTheme(backgroundColor:Color(0xff276749),foregroundColor:Colors.white));
}
