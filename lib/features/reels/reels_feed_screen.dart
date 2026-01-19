import 'package:flutter/material.dart';

class ReelsFeedScreen extends StatelessWidget {
  const ReelsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reels')),
      body: const Center(child: Text('Reels Feed (Vertical Video)')),
    );
  }
}
