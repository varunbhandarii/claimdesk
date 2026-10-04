import 'package:flutter/material.dart';
import 'client.dart';
import 'screens/sign_in_screen.dart';
import 'ui/desk_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ClaimDesk',
    debugShowCheckedModeBanner: false,
    theme: buildDeskTheme(Brightness.light),
    darkTheme: buildDeskTheme(Brightness.dark),
    home: const SignInScreen(),
  );
}
