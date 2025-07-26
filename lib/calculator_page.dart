import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'buttons.dart';
import 'calculator_utils.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = "0";
  String _previousExpression = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operator = "";
  bool _shouldResetDisplay = false;
  bool _hasError = false;
  int _cursorPosition = -1; // -1 means no cursor, otherwise position in string
  bool _showCursor = false;

  void _onButtonPressed(String value) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      // Reset error state when user starts new input
      if (_hasError && value != "AC") {
        _clear();
        _hasError = false;
      }

      if (CalculatorUtils.isNumber(value) || value == ".") {
        _handleNumber(value);
      } else if (CalculatorUtils.isOperator(value)) {
        _handleOperator(value);
      } else if (value == "=") {
        _calculate();
      } else if (value == "AC") {
        _clear();
      } else if (value == "+/-") {
        _toggleSign();
      } else if (value == "%") {
        _percentage();
      } else if (value == "⌫") {
        _backspace();
      }
    });
  }

  void _handleNumber(String value) {
    if (_shouldResetDisplay) {
      _display = "";
      _shouldResetDisplay = false;
      _cursorPosition = -1;
      _showCursor = false;
    }

    // Error handling: Prevent multiple decimal points
    if (value == "." && _display.contains(".")) {
      return;
    }

    // Error handling: Limit display length to prevent overflow
    if (_display.length >= 100) {
      _showError("Number too large");
      return;
    }

    if (_display == "0" && value != ".") {
      _display = value;
      _cursorPosition = -1;
      _showCursor = false;
    } else {
      if (_cursorPosition != -1 && _showCursor) {
        // Insert at cursor position
        String before = _display.substring(0, _cursorPosition);
        String after = _display.substring(_cursorPosition);
        _display = before + value + after;
        _cursorPosition = _cursorPosition + 1; // Move cursor after inserted digit
      } else {
        // Default behavior: append to end
        _display += value;
      }
    }
  }

  void _handleOperator(String value) {
    if (_hasError) return;

    if (_operator.isNotEmpty && !_shouldResetDisplay) {
      _calculate();
      if (_hasError) return;
    }

    _num1 = double.tryParse(_display) ?? 0;
    _operator = value;
    _shouldResetDisplay = true;
    _previousExpression = "$_display $value";
    
    // Clear cursor when operator is pressed
    _cursorPosition = -1;
    _showCursor = false;
  }

  void _calculate() {
    if (_operator.isEmpty || _hasError) return;

    _num2 = double.tryParse(_display) ?? 0;
    double result = 0;

    try {
      switch (_operator) {
        case '+':
          result = _num1 + _num2;
          break;
        case '-':
          result = _num1 - _num2;
          break;
        case '×':
          result = _num1 * _num2;
          break;
        case '÷':
          if (_num2 == 0) {
            _showError("Cannot divide by zero");
            return;
          }
          result = _num1 / _num2;
          break;
      }

      // Error handling: Check for infinity and NaN
      if (result.isInfinite) {
        _showError("Result too large");
        return;
      }
      
      if (result.isNaN) {
        _showError("Invalid operation");
        return;
      }

      // Error handling: Check for overflow - increased limit for 100-digit support
      if (result.abs() > 1e50) {
        _showError("Number too large");
        return;
      }

      // Format the result
      _previousExpression = "$_num1 $_operator $_num2 =";
      if (result == result.toInt() && result.abs() < 1e15) {
        _display = result.toInt().toString();
      } else {
        _display = CalculatorUtils.formatNumber(result);
      }

      _operator = "";
      _shouldResetDisplay = true;
    } catch (e) {
      _showError("Calculation error");
    }
  }

  void _showError(String message) {
    _display = message;
    _hasError = true;
    _operator = "";
    _previousExpression = "";
  }

  void _clear() {
    _display = "0";
    _previousExpression = "";
    _num1 = 0;
    _num2 = 0;
    _operator = "";
    _shouldResetDisplay = false;
    _hasError = false;
    _cursorPosition = -1;
    _showCursor = false;
  }

  void _toggleSign() {
    if (_hasError) return;
    
    double currentValue = double.tryParse(_display) ?? 0;
    if (currentValue != 0) {
      currentValue = -currentValue;
      _display = currentValue == currentValue.toInt() 
          ? currentValue.toInt().toString() 
          : currentValue.toString();
    }
  }

  void _percentage() {
    if (_hasError || _operator.isEmpty) return;
    
    double currentValue = double.tryParse(_display) ?? 0;
    _num2 = (_num1 * currentValue) / 100;
    _display = CalculatorUtils.formatNumber(_num2);
    _shouldResetDisplay = true;
  }

  void _backspace() {
    if (_hasError) return;
    
    if (_cursorPosition != -1 && _cursorPosition > 0) {
      // Delete character at cursor position
      String before = _display.substring(0, _cursorPosition - 1);
      String after = _display.substring(_cursorPosition);
      _display = before + after;
      _cursorPosition = _cursorPosition - 1;
      
      if (_display.isEmpty) {
        _display = "0";
        _cursorPosition = -1;
        _showCursor = false;
      }
    } else {
      // Default behavior: delete from end
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = "0";
        _cursorPosition = -1;
        _showCursor = false;
      }
    }
  }

  void _onDisplayTap(TapDownDetails details) {
    if (_hasError || _display == "0") return;
    
    setState(() {
      double fontSize = _display.length > 8 ? 48 : 64;
      double tapX = details.localPosition.dx;
      
      // Use TextPainter for accurate text measurement
      TextStyle textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
      );
      
      // Measure the full text width first
      TextPainter fullTextPainter = TextPainter(
        text: TextSpan(text: _display, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      fullTextPainter.layout();
      double fullTextWidth = fullTextPainter.size.width;
      fullTextPainter.dispose();
      
      // If tap is beyond the text (with some tolerance), place cursor at end
      if (tapX >= fullTextWidth - fontSize * 0.1) {
        _cursorPosition = _display.length;
        _showCursor = true;
        return;
      }
      
      // Find the closest cursor position by measuring text widths
      int bestPosition = 0;
      double minDistance = double.infinity;
      
      for (int i = 0; i <= _display.length; i++) {
        String substring = _display.substring(0, i);
        
        TextPainter painter = TextPainter(
          text: TextSpan(text: substring, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        painter.layout();
        
        double textWidth = painter.size.width;
        double distance = (tapX - textWidth).abs();
        
        if (distance < minDistance) {
          minDistance = distance;
          bestPosition = i;
        }
        
        painter.dispose();
      }
      
      _cursorPosition = bestPosition;
      _showCursor = true;
    });
  }

  Widget _buildDisplayWithCursor() {
    double fontSize = _display.length > 8 ? 48 : 64;
    
    if (!_showCursor || _cursorPosition == -1) {
      return Text(
        _display,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
      );
    }
    
    // Build text with cursor
    String beforeCursor = _display.substring(0, _cursorPosition);
    String afterCursor = _display.substring(_cursorPosition);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          beforeCursor,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        Container(
          width: 2,
          height: fontSize,
          color: Colors.white,
        ),
        Text(
          afterCursor,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Previous expression (small gray text)
                    if (_previousExpression.isNotEmpty)
                      Text(
                        _previousExpression,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Main display with cursor functionality
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _onDisplayTap(details);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(right: 20), // Add right padding for easier end tapping
                          child: _buildDisplayWithCursor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Button Area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    // Row 1: AC, +/-, ⌫, ÷
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton.build(
                            text: "AC",
                            onPressed: () => _onButtonPressed("AC"),
                            type: ButtonType.function,
                          ),
                          CalculatorButton.build(
                            text: "+/-",
                            onPressed: () => _onButtonPressed("+/-"),
                            type: ButtonType.function,
                          ),
                          CalculatorButton.build(
                            text: "⌫",
                            onPressed: () => _onButtonPressed("⌫"),
                            type: ButtonType.function,
                          ),
                          CalculatorButton.build(
                            text: "÷",
                            onPressed: () => _onButtonPressed("÷"),
                            type: ButtonType.operator,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 2: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton.build(
                            text: "7",
                            onPressed: () => _onButtonPressed("7"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "8",
                            onPressed: () => _onButtonPressed("8"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "9",
                            onPressed: () => _onButtonPressed("9"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "×",
                            onPressed: () => _onButtonPressed("×"),
                            type: ButtonType.operator,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 3: 4, 5, 6, -
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton.build(
                            text: "4",
                            onPressed: () => _onButtonPressed("4"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "5",
                            onPressed: () => _onButtonPressed("5"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "6",
                            onPressed: () => _onButtonPressed("6"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "-",
                            onPressed: () => _onButtonPressed("-"),
                            type: ButtonType.operator,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton.build(
                            text: "1",
                            onPressed: () => _onButtonPressed("1"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "2",
                            onPressed: () => _onButtonPressed("2"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "3",
                            onPressed: () => _onButtonPressed("3"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "+",
                            onPressed: () => _onButtonPressed("+"),
                            type: ButtonType.operator,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 5: ., 0, %, =
                    Expanded(
                      child: Row(
                        children: [
                          CalculatorButton.build(
                            text: ".",
                            onPressed: () => _onButtonPressed("."),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "0",
                            onPressed: () => _onButtonPressed("0"),
                            type: ButtonType.number,
                          ),
                          CalculatorButton.build(
                            text: "%",
                            onPressed: () => _onButtonPressed("%"),
                            type: ButtonType.function,
                          ),
                          CalculatorButton.build(
                            text: "=",
                            onPressed: () => _onButtonPressed("="),
                            type: ButtonType.operator,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
