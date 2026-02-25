import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BabyChef());
}

class BabyChef extends StatefulWidget {
  const BabyChef({super.key});

  @override
  State<BabyChef> createState() => _BabyChefState();
}

class _BabyChefState extends State<BabyChef> {
  final ValueNotifier<ThemeMode> _themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final current = _themeNotifier.value;
    if (current == ThemeMode.system) {
      _themeNotifier.value = ThemeMode.light;
    } else if (current == ThemeMode.light) {
      _themeNotifier.value = ThemeMode.dark;
    } else {
      _themeNotifier.value = ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          home: LoginScreen(
            themeNotifier: _themeNotifier,
            onToggleTheme: _toggleTheme,
          ),
        );
      },
    );
  }
}
