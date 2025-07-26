class CalculatorUtils {
  static String formatNumber(double number) {
    if (number.abs() < 1e-6) return "0";
    
    String formatted = number.toStringAsFixed(10);
    formatted = formatted.replaceAll(RegExp(r'0*$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    
    // Scientific notation for very large or small numbers
    if (formatted.length > 20 || number.abs() >= 1e15) {
      return number.toStringAsExponential(8);
    }
    
    return formatted;
  }

  static bool isNumber(String value) {
    return RegExp(r'^[0-9]$').hasMatch(value);
  }

  static bool isOperator(String value) {
    return ['+', '-', '×', '÷'].contains(value);
  }
}
