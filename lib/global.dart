import 'package:get/get.dart';
import 'package:flutter/material.dart';

double screenHeight = 0;
double screenWidth = 0;



Color primary = const Color.fromARGB(253, 236, 17, 28);

LinearGradient customGradientWithOpacity() {
  return LinearGradient(
    colors: [
      Colors.black.withOpacity(0.7),
      Colors.red.shade700.withOpacity(0.7),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.3, 0.6],
  );
}

void CustomSnackBar(String titleText, String messageText, Color backgroundColor) {

  Get.snackbar('', "",
      titleText: Text(
        textAlign: TextAlign.center,
        titleText,
        style: const TextStyle(
            fontFamily: "NexaBold", fontSize: 22, color: Colors.white),
      ),
      messageText: Text(
        textAlign: TextAlign.center,
        messageText,
        style: const TextStyle(fontFamily: "NexaBold", color: Colors.white),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      backgroundColor: backgroundColor);
}


