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

    // Determine if this is an icon button or text button
    bool isIcon = text == "⌫" || text == "+/-";
    double fontSize;
    FontWeight fontWeight;
    
    if (isIcon) {
      fontSize = 28;
      fontWeight = FontWeight.w300;
    } else if (text.length > 1) {
      fontSize = 24;
      fontWeight = FontWeight.w500;
    } else {
      fontSize = 32;
      fontWeight = FontWeight.w400;
    }

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(3),
        child: AspectRatio(
          aspectRatio: 1.0, // Make buttons perfectly circular
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              shape: const CircleBorder(),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
