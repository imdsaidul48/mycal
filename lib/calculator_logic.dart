import 'package:flutter/foundation.dart';

class CalculatorLogic extends ChangeNotifier {
  String _display = '0';
  String _expression = '';
  String _result = '';
  bool _startNewInput = true;
  String _lastOperation = '';
  double _storedValue = 0;
  List<String> _history = [];

  String get display => _display;
  String get expression => _expression;
  String get result => _result;
  List<String> get history => _history;

  void clear() {
    _display = '0';
    _expression = '';
    _result = '';
    _startNewInput = true;
    _lastOperation = '';
    _storedValue = 0;
    notifyListeners();
  }

  void clearEntry() {
    _display = '0';
    _startNewInput = true;
    notifyListeners();
  }

  void backspace() {
    if (_startNewInput) return;
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
      _startNewInput = true;
    }
    notifyListeners();
  }

  void inputNumber(String number) {
    if (_startNewInput) {
      _display = number;
      _startNewInput = false;
    } else {
      if (_display == '0' && number != '.') {
        _display = number;
      } else if (number == '.' && _display.contains('.')) {
        return;
      } else {
        _display = _display + number;
      }
    }
    notifyListeners();
  }

  void inputOperator(String operator) {
    if (_display == '0' && _expression.isEmpty) return;

    if (_expression.isNotEmpty && !_startNewInput) {
      _calculate();
    }

    _expression = _display + ' ' + operator + ' ';
    _startNewInput = true;
    _lastOperation = operator;
    notifyListeners();
  }

  void calculate() {
    if (_expression.isEmpty) return;

    try {
      double result = _evaluateExpression(_expression.trim());
      _result = _formatResult(result);
      _history.insert(0, '${_expression.trim()} = $_result');
      if (_history.length > 20) {
        _history.removeLast();
      }
      _display = _result;
      _expression = '';
      _startNewInput = true;
    } catch (e) {
      _display = 'Error';
      _expression = '';
      _startNewInput = true;
    }
    notifyListeners();
  }

  double _evaluateExpression(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

    // Handle percentage
    if (expr.contains('%')) {
      expr = expr.replaceAll(RegExp(r'(\d+\.?\d*)%'), r'($1/100)');
    }

    // Simple expression evaluator
    List<String> tokens = _tokenize(expr);
    List<double> values = [];
    List<String> ops = [];

    for (String token in tokens) {
      if (double.tryParse(token) != null) {
        values.add(double.parse(token));
      } else {
        ops.add(token);
      }
    }

    // Handle * and / first
    for (int i = 0; i < ops.length; i++) {
      if (ops[i] == '*' || ops[i] == '/') {
        double left = values[i];
        double right = values[i + 1];
        double result = ops[i] == '*' ? left * right : left / right;
        values[i] = result;
        values.removeAt(i + 1);
        ops.removeAt(i);
        i--;
      }
    }

    // Handle + and -
    for (int i = 0; i < ops.length; i++) {
      if (ops[i] == '+' || ops[i] == '-') {
        double left = values[i];
        double right = values[i + 1];
        double result = ops[i] == '+' ? left + right : left - right;
        values[i] = result;
        values.removeAt(i + 1);
        ops.removeAt(i);
        i--;
      }
    }

    return values[0];
  }

  List<String> _tokenize(String expr) {
    List<String> tokens = [];
    StringBuffer current = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];
      if ('0123456789.'.contains(char)) {
        current.write(char);
      } else {
        if (current.isNotEmpty) {
          tokens.add(current.toString());
          current = StringBuffer();
        }
        tokens.add(char);
      }
    }

    if (current.isNotEmpty) {
      tokens.add(current.toString());
    }

    return tokens;
  }

  String _formatResult(double result) {
    if (result.isNaN || result.isInfinite) {
      return 'Error';
    }
    if (result == result.roundToDouble() && result.abs() < 1e15) {
      return result.toInt().toString();
    }
    return result.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void applyPercent() {
    try {
      double value = double.parse(_display);
      double result = value / 100;
      _display = _formatResult(result);
      _startNewInput = true;
    } catch (e) {
      _display = 'Error';
    }
    notifyListeners();
  }

  void applySquareRoot() {
    try {
      double value = double.parse(_display);
      if (value < 0) {
        _display = 'Error';
      } else {
        _display = _formatResult(value.sqrt());
      }
      _startNewInput = true;
    } catch (e) {
      _display = 'Error';
    }
    notifyListeners();
  }

  void applySquare() {
    try {
      double value = double.parse(_display);
      _display = _formatResult(value * value);
      _startNewInput = true;
    } catch (e) {
      _display = 'Error';
    }
    notifyListeners();
  }

  void applyReciprocal() {
    try {
      double value = double.parse(_display);
      if (value == 0) {
        _display = 'Error';
      } else {
        _display = _formatResult(1 / value);
      }
      _startNewInput = true;
    } catch (e) {
      _display = 'Error';
    }
    notifyListeners();
  }

  void toggleSign() {
    if (_display != '0' && _display != 'Error') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    }
    notifyListeners();
  }

  void _calculate() {
    try {
      double result = _evaluateExpression(_expression.trim());
      _display = _formatResult(result);
    } catch (e) {
      _display = 'Error';
    }
  }
}
