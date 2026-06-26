import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';

class WhoOwnsItApp extends StatelessWidget {
  const WhoOwnsItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhoOwnsIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}