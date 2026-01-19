import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mobile_scaffold.dart';
import 'desktop_scaffold.dart';
import 'nav_controller.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NavController()); // Initialize NavController

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return const MobileScaffold();
        } else {
          return const DesktopScaffold();
        }
      },
    );
  }
}
