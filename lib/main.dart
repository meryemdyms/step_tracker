
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adım Takip',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adım Takip'),
      ),
      body: Center(
        child: Text(
          'Adım Takip Uygulaması',
          style: Theme.of(context).textTheme.headlineSmall, //Theme.of(context) ile widget'ın bulunduğu BuildContext üzerinden aktif temaya erişiyoruz. 
        ),
      ),
    );
  }
}
