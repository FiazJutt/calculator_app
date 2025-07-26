# Calculator App - Technical Documentation

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [File Structure](#file-structure)
3. [Component Details](#component-details)
4. [State Management](#state-management)
5. [Error Handling](#error-handling)
6. [UI/UX Design](#uiux-design)
7. [Performance Considerations](#performance-considerations)
8. [Testing Strategy](#testing-strategy)

## 📖 Project Overview

This Flutter calculator app provides a modern, clean interface for mathematical calculations with comprehensive error handling and user-friendly features.

### Core Features
- **Mathematical Operations**: +, -, ×, ÷
- **Special Functions**: %, +/-, AC, Backspace (⌫)
- **High-Precision Input**: Up to 100-digit number support
- **Smart Display**: Previous expression + current result with cursor positioning
- **Advanced Error Handling**: Division by zero, enhanced overflow protection (up to 1e50)
- **Interactive Features**: Tap-to-position cursor, scientific notation formatting
- **Responsive Design**: Works across all Flutter platforms

## 📁 File Structure

```
lib/
├── main.dart              # Entry point, app initialization
├── calculator_page.dart   # Main calculator logic and UI
├── buttons.dart          # Button component definitions
└── calculator_utils.dart # Helper functions and utilities
```

### File Responsibilities

#### `main.dart` (23 lines)
- App initialization with `MyApp` widget
- Theme configuration (dark theme with specific scaffold color)
- Navigation setup to `CalculatorPage`

#### `calculator_page.dart` (358 lines)
- **State Management**: All calculator state variables
- **Event Handling**: Button press logic and calculations
- **UI Layout**: Complete calculator interface structure
- **Error Management**: Comprehensive error handling

#### `buttons.dart` (54 lines)
- **ButtonType Enum**: `function`, `operator`, `number`
- **CalculatorButton Class**: Static button builder with styling
- **Color Schemes**: Button-specific color configurations

#### `calculator_utils.dart` (24 lines)
- **Number Formatting**: Handles decimal precision and scientific notation
- **Input Validation**: Number and operator validation functions
- **Utility Functions**: Reusable helper methods

## 🔧 Component Details

### State Variables

```dart
class _CalculatorPageState {
  String _display = "0";              // Current display value
  String _previousExpression = "";    // Previous calculation expression
  double _num1 = 0;                   // First operand
  double _num2 = 0;                   // Second operand  
  String _operator = "";              // Current operator (+, -, ×, ÷)
  bool _shouldResetDisplay = false;   // Flag for display reset
  bool _hasError = false;             // Error state flag
  int _cursorPosition = -1;           // Cursor position for editing (-1 = no cursor)
  bool _showCursor = false;           // Cursor visibility flag
}
```

### Key Methods

#### `_onButtonPressed(String value)`
Central event handler that routes button presses to appropriate methods based on input type.

#### `_handleNumber(String value)`
- Manages number input including decimal points
- Prevents multiple decimal points
- Handles display reset after operations

#### `_handleOperator(String value)`
- Processes operator input (+, -, ×, ÷)
- Triggers calculation if previous operator exists
- Updates previous expression display

#### `_calculate()`
- Performs mathematical operations
- Handles edge cases (division by zero, overflow)
- Formats results appropriately

#### `_percentage()`
- Context-aware percentage calculations
- Calculates percentage of first number in operation context
- Example: `100 - 4%` calculates `4% of 100` then subtracts

#### `_backspace()`
- Handles backspace/delete functionality
- Supports cursor-based editing at any position
- Maintains display integrity with proper fallbacks

#### `_onDisplayTap(TapDownDetails details)`
- Processes tap events on the display area
- Calculates cursor position based on tap location
- Enables text editing at specific positions

#### `_buildDisplayWithCursor()`
- Constructs display widget with optional cursor
- Handles cursor positioning and visibility
- Supports both normal display and cursor-enabled editing

## 🎯 State Management

### State Flow
1. **Input Phase**: User presses numbers/operators
2. **Validation Phase**: Input validation and error checking
3. **Calculation Phase**: Mathematical operation execution
4. **Display Phase**: Result formatting and display update
5. **Reset Phase**: State preparation for next operation

### Error States
- `_hasError = true`: Blocks further input until AC is pressed
- Error messages replace display content
- Previous expression is cleared on error

## ⚠️ Error Handling

### Division by Zero
```dart
if (_num2 == 0) {
  _showError("Cannot divide by zero");
  return;
}
```

### Number Overflow (Enhanced)
```dart
// Enhanced overflow detection for large number support
if (result.abs() > 1e50) {
  _showError("Number too large");
  return;
}

// Check for infinity and NaN
if (result.isInfinite) {
  _showError("Result too large");
  return;
}

if (result.isNaN) {
  _showError("Invalid operation");
  return;
}
```

### Input Validation (Enhanced)
```dart
// Prevent multiple decimal points
if (value == "." && _display.contains(".")) {
  return;
}

// Enhanced input length limit for 100-digit support
if (_display.length >= 100) {
  _showError("Number too large");
  return;
}
```

### Cursor Management
```dart
// Cursor position validation and management
if (_cursorPosition != -1 && _showCursor) {
  // Insert at cursor position
  String before = _display.substring(0, _cursorPosition);
  String after = _display.substring(_cursorPosition);
  _display = before + value + after;
  _cursorPosition = _cursorPosition + 1;
}
```

## 🎨 UI/UX Design

### Color Scheme
- **Background**: Pure black (#000000)
- **Numbers**: Dark gray (#333333)
- **Functions**: Medium gray (#505050) 
- **Operators**: iOS blue (#007AFF)
- **Text**: White with gray secondary (#999999)

### Layout Structure
```
SafeArea
└── Column
    ├── Display Area (flex: 2)
    │   ├── Previous Expression
    │   └── Current Display
    └── Button Area (flex: 3)
        └── 5 Rows of Buttons
```

### Typography
- **Display**: 64px (48px for long numbers), font-weight 300
- **Previous**: 20px, gray color, font-weight 300
- **Buttons**: 36px (28px for multi-char), font-weight 400

### Button Styling
- **Shape**: Rounded rectangles (border-radius: 40px)
- **Size**: 80px height, responsive width
- **Spacing**: 4px margin between buttons
- **Animation**: Material elevation and ripple effects

## ⚡ Performance Considerations

### Optimizations
- **State Management**: Minimal state updates with `setState()`
- **Widget Reuse**: Static button builder prevents recreation
- **Memory Efficiency**: Primitive data types for calculations
- **Display Optimization**: Conditional text sizing based on length

### Responsive Design
- **Flexible Layout**: Uses `Expanded` widgets for responsive sizing
- **Text Scaling**: Dynamic font sizes based on content length
- **Platform Support**: Works across mobile, web, and desktop

## 🧪 Testing Strategy

### Unit Tests
```dart
// Example test cases
test('Addition calculation', () {
  // Test: 2 + 3 = 5
});

test('Percentage calculation', () {
  // Test: 100 - 4% = 96
});

test('Division by zero handling', () {
  // Test: 5 ÷ 0 = Error
});
```

### Integration Tests
- Button press sequences
- Display updates
- Error state transitions
- Cross-platform compatibility

### Manual Testing Checklist
- [ ] All basic operations (+, -, ×, ÷)
- [ ] Percentage calculations in different contexts
- [ ] Error handling (division by zero, enhanced overflow)
- [ ] Sign toggle functionality
- [ ] Clear (AC) functionality
- [ ] Backspace (⌫) functionality
- [ ] Long number display handling (up to 100 digits)
- [ ] Decimal point operations
- [ ] Cursor positioning by tapping display
- [ ] Cursor-based editing and insertion
- [ ] Scientific notation display for large results
- [ ] Large number calculations (testing 1e50 limit)
- [ ] Interactive cursor movement and deletion
- [ ] Horizontal scrolling for very long numbers

## 🔄 Future Enhancements

### Potential Features
- **Memory Functions**: M+, M-, MR, MC
- **Scientific Operations**: sin, cos, tan, log, sqrt
- **History**: Calculation history with undo/redo
- **Themes**: Multiple color schemes
- **Settings**: Decimal precision, angle units
- **Export**: Share calculations or results

### Code Improvements
- **Unit Tests**: Comprehensive test coverage
- **Documentation**: Inline code documentation
- **Accessibility**: Screen reader support, keyboard navigation
- **Internationalization**: Multi-language support
- **Animation**: Smooth transitions and micro-interactions

---

*Last updated: [Current Date]*
*Flutter Version: 3.0+*
*Dart Version: 3.0+*
