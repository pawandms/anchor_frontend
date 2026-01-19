import 'package:get/get.dart';

class NavController extends GetxController {
  // Observables
  var selectedIndex = 0.obs; // 0: Home, 1: Chat, 2: Channels, 3: Reels
  var isProfileDeckOpen = false.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void toggleDeck() {
    isProfileDeckOpen.value = !isProfileDeckOpen.value;
  }
}
