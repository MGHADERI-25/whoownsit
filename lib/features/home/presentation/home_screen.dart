import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhoOwnsIt'),
      ),
      body: const Center(
        child: Text(
          'Corporate ownership lookup starts here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}