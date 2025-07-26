import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonType { function, operator, number }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      ),
      home: const CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

  void _onButtonPressed(String value) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      // Reset error state when user starts new input
      if (_hasError && value != "AC") {
        _clear();
        _hasError = false;
      }

      if (_isNumber(value) || value == ".") {
        _handleNumber(value);
      } else if (_isOperator(value)) {
        _handleOperator(value);
      } else if (value == "=") {
        _calculate();
      } else if (value == "AC") {
        _clear();
      } else if (value == "+/-") {
        _toggleSign();
      } else if (value == "%") {
        _percentage();
      }
    });
  }

  bool _isNumber(String value) {
    return RegExp(r'^[0-9]$').hasMatch(value);
  }

  bool _isOperator(String value) {
    return ['+', '-', '×', '÷'].contains(value);
  }

  void _handleNumber(String value) {
    if (_shouldResetDisplay) {
      _display = "";
      _shouldResetDisplay = false;
    }

    // Error handling: Prevent multiple decimal points
    if (value == "." && _display.contains(".")) {
      return;
    }

    // Error handling: Limit display length to prevent overflow
    if (_display.length >= 12 && !_display.contains(".")) {
      _showError("Number too large");
      return;
    }

    if (_display == "0" && value != ".") {
      _display = value;
    } else {
      _display += value;
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

      // Error handling: Check for overflow
      if (result.abs() > 1e15) {
        _showError("Number too large");
        return;
      }

      // Format the result
      _previousExpression = "$_num1 $_operator $_num2 =";
      if (result == result.toInt() && result.abs() < 1e10) {
        _display = result.toInt().toString();
      } else {
        _display = _formatNumber(result);
      }

      _operator = "";
      _shouldResetDisplay = true;
    } catch (e) {
      _showError("Calculation error");
    }
  }

  String _formatNumber(double number) {
    if (number.abs() < 1e-6) return "0";
    
    String formatted = number.toStringAsFixed(10);
    formatted = formatted.replaceAll(RegExp(r'0*$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    
    // Scientific notation for very large or small numbers
    if (formatted.length > 12) {
      return number.toStringAsExponential(6);
    }
    
    return formatted;
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
    _display = _formatNumber(_num2);
    _shouldResetDisplay = true;
  }

  Widget _buildButton({
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    // Main display
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _display,
                        style: TextStyle(
                          fontSize: _display.length > 8 ? 48 : 64,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Row 1: AC, +/-, %, ÷
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            text: "AC",
                            onPressed: () => _onButtonPressed("AC"),
                            type: ButtonType.function,
                          ),
                          _buildButton(
                            text: "+/-",
                            onPressed: () => _onButtonPressed("+/-"),
                            type: ButtonType.function,
                          ),
                          _buildButton(
                            text: "%",
                            onPressed: () => _onButtonPressed("%"),
                            type: ButtonType.function,
                          ),
                          _buildButton(
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
                          _buildButton(
                            text: "7",
                            onPressed: () => _onButtonPressed("7"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "8",
                            onPressed: () => _onButtonPressed("8"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "9",
                            onPressed: () => _onButtonPressed("9"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
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
                          _buildButton(
                            text: "4",
                            onPressed: () => _onButtonPressed("4"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "5",
                            onPressed: () => _onButtonPressed("5"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "6",
                            onPressed: () => _onButtonPressed("6"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
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
                          _buildButton(
                            text: "1",
                            onPressed: () => _onButtonPressed("1"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "2",
                            onPressed: () => _onButtonPressed("2"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "3",
                            onPressed: () => _onButtonPressed("3"),
                            type: ButtonType.number,
                          ),
                          _buildButton(
                            text: "+",
                            onPressed: () => _onButtonPressed("+"),
                            type: ButtonType.operator,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 5: 0 (double width), ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            text: "0",
                            onPressed: () => _onButtonPressed("0"),
                            type: ButtonType.number,
                            flex: 2,
                          ),
                          _buildButton(
                            text: ".",
                            onPressed: () => _onButtonPressed("."),
                            type: ButtonType.number,
                          ),
                          _buildButton(
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
