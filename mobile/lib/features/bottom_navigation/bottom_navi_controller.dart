import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class BottomNavigationContoller extends GetxController {
  var currentIndex = 0.obs;
  late PageController pageController;
  //

  @override
  void onInit() {
    super.onInit();
    print("Page Controller initialized");
    pageController = PageController(initialPage: 0);

    pageController.addListener(() {
      // pageController.page yeh decimal(0.0) hota hai .round() laga kr hum ishe integer krte haan.
      int page = pageController.page?.round() ?? 0;
      if (currentIndex.value != page) {
        currentIndex.value = page;
      }
    });
  }

  void onChangedPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
