import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ungatekept',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xfff8f4f3),
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff41342b),
          primary: const Color(0xff916247),
          secondary: const Color(0xFFBFA292),
          tertiary: const Color(0xFFF8F4F3),
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.openSans(
            fontSize: 24
          ),
          displaySmall: GoogleFonts.openSans(),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      home: HomePage(),
    );
  }
}
