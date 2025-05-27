// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wefund/BottomNavigationBar.dart';
import 'package:wefund/api/login.dart';
import 'package:wefund/ThemeProvider.dart';
import 'package:wefund/account_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We clear any auto-login flag at startup so we always show login screen
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              title: 'WEFUND',
              debugShowCheckedModeBanner: false,
              theme: theme.isDarkMode ? ThemeData.dark() : ThemeData.light(),
              home: const LoginScreen(),
              // after successful login you do:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BottomNavigationBarWidget()));
            );
          },
        );
      },
    );
  }
}
