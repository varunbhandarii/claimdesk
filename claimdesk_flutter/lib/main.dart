import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const MyApp());
}

ThemeData buildDeskTheme(Brightness brightness) {
  final colours = ColorScheme.fromSeed(
    seedColor: const Color(0xff185c49),
    brightness: brightness,
  );
  final base = ThemeData(
    colorScheme: colours,
    useMaterial3: true,
    brightness: brightness,
  );
  final text = GoogleFonts.publicSansTextTheme(base.textTheme);
  return base.copyWith(
    textTheme: text.copyWith(
      headlineLarge: GoogleFonts.manrope(
        textStyle: text.headlineLarge,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: text.headlineMedium,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: text.titleLarge,
        fontWeight: FontWeight.w700,
      ),
    ),
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xfff7f6ef)
        : const Color(0xff141d19),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ClaimDesk',
    theme: buildDeskTheme(Brightness.light),
    darkTheme: buildDeskTheme(Brightness.dark),
    home: const SignInScreen(),
  );
}
