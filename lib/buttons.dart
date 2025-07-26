import 'package:flutter/material.dart';

enum ButtonType { function, operator, number }

class CalculatorButton {
  static Widget build({
    required String text,
    required VoidCallback onPressed,
    required ButtonType type,
    int flex = 1,
  }) {
    Color backgroundColor = const Color(0xFF333333);
    Color textColor = Colors.white;
    
    switch (type) {
      case ButtonType.function:
        backgroundColor = const Color(0xFF505050);
        textColor = Colors.white;
        break;
      case ButtonType.operator:
        backgroundColor = const Color(0xFF007AFF);
        textColor = Colors.white;
        break;
      case ButtonType.number:
        backgroundColor = const Color(0xFF333333);
        textColor = Colors.white;
        break;
    }

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 80,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            elevation: 0,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: text.length > 1 ? 28 : 36,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
