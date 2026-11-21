import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calculator_logic.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildDisplay(context),
              const SizedBox(height: 20),
              Expanded(child: _buildButtonGrid(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'MyCal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Consumer<CalculatorLogic>(
          builder: (context, calculator, _) {
            return IconButton(
              icon: const Icon(Icons.history, color: Colors.white70),
              onPressed: () => _showHistory(context, calculator),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDisplay(BuildContext context) {
    return Consumer<CalculatorLogic>(
      builder: (context, calculator, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A4A), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calculator.expression,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                calculator.display,
                style: TextStyle(
                  fontSize: calculator.display.length > 12 ? 36 : 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtonGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final buttons = [
          'C', '(', ')', '÷',
          '7', '8', '9', '×',
          '4', '5', '6', '-',
          '1', '2', '3', '+',
          '%', '√', 'x²', '1/x',
          '0', '.', '±', '=',
        ];

        String button = buttons[index];
        Color backgroundColor;
        Color textColor;
        IconData? icon;

        if (button == 'C') {
          backgroundColor = const Color(0xFFE94560);
          textColor = Colors.white;
        } else if (button == '=') {
          backgroundColor = const Color(0xFF0F3460);
          textColor = Colors.white;
        } else if (button == '÷' || button == '×' || button == '-' || button == '+') {
          backgroundColor = const Color(0xFF16213E);
          textColor = const Color(0xFF00B4D8);
        } else if (button == '%' || button == '√' || button == 'x²' || button == '1/x') {
          backgroundColor = const Color(0xFF1A1A2E);
          textColor = const Color(0xFF00B4D8);
        } else if (button == '(' || button == ')') {
          backgroundColor = const Color(0xFF1A1A2E);
          textColor = Colors.white70;
        } else {
          backgroundColor = const Color(0xFF16213E);
          textColor = Colors.white;
        }

        return _buildButton(context, button, backgroundColor, textColor, icon);
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
    IconData? icon,
  ) {
    return Consumer<CalculatorLogic>(
      builder: (context, calculator, _) {
        return Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onButtonPressed(context, calculator, label),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: textColor, size: 24)
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _onButtonPressed(
    BuildContext context,
    CalculatorLogic calculator,
    String label,
  ) {
    switch (label) {
      case 'C':
        calculator.clear();
        break;
      case '÷':
      case '×':
      case '-':
      case '+':
        calculator.inputOperator(label);
        break;
      case '=':
        calculator.calculate();
        break;
      case '%':
        calculator.applyPercent();
        break;
      case '√':
        calculator.applySquareRoot();
        break;
      case 'x²':
        calculator.applySquare();
        break;
      case '1/x':
        calculator.applyReciprocal();
        break;
      case '±':
        calculator.toggleSign();
        break;
      case '(':
      case ')':
        calculator.inputNumber(label);
        break;
      default:
        calculator.inputNumber(label);
    }
  }

  void _showHistory(BuildContext context, CalculatorLogic calculator) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: calculator.history.isEmpty
                      ? const Center(
                          child: Text(
                            'No history yet',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: calculator.history.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16213E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  calculator.history[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
