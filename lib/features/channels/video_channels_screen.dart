import 'package:flutter/material.dart';

class VideoChannelsScreen extends StatelessWidget {
  const VideoChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: const Center(child: Text('Video Channels Grid')),
    );
  }
}
