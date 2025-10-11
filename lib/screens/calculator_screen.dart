import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String expression = '';
  String operation = '';
  double firstNumber = 0;
  double secondNumber = 0;
  bool isOperationPressed = false;
  bool showResult = false;

  String formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  void onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        display = '0';
        expression = '';
        operation = '';
        firstNumber = 0;
        secondNumber = 0;
        isOperationPressed = false;
        showResult = false;
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '×' ||
          buttonText == '÷') {
        if (operation.isNotEmpty && !isOperationPressed) {
          secondNumber = double.parse(display);
          switch (operation) {
            case '+':
              firstNumber = firstNumber + secondNumber;
              break;
            case '-':
              firstNumber = firstNumber - secondNumber;
              break;
            case '×':
              firstNumber = firstNumber * secondNumber;
              break;
            case '÷':
              firstNumber = secondNumber != 0 ? firstNumber / secondNumber : 0;
              break;
          }
          display = formatNumber(firstNumber);
          expression = '${formatNumber(firstNumber)} $buttonText ';
        } else {
          firstNumber = double.parse(display);
          expression = '${formatNumber(firstNumber)} $buttonText ';
        }
        operation = buttonText;
        isOperationPressed = true;
        showResult = false;
      } else if (buttonText == '=') {
        if (operation.isNotEmpty && !showResult) {
          secondNumber = double.parse(display);
          double result;
          switch (operation) {
            case '+':
              result = firstNumber + secondNumber;
              break;
            case '-':
              result = firstNumber - secondNumber;
              break;
            case '×':
              result = firstNumber * secondNumber;
              break;
            case '÷':
              result = secondNumber != 0 ? firstNumber / secondNumber : 0;
              break;
            default:
              result = 0;
          }

          if (result.isInfinite || result.isNaN) {
            display = 'Error';
            expression = '';
          } else {
            display = formatNumber(result);
            expression =
                '${formatNumber(firstNumber)} $operation ${formatNumber(secondNumber)} =';
          }

          operation = '';
          firstNumber = result.isInfinite || result.isNaN ? 0 : result;
          isOperationPressed = false;
          showResult = true;
        }
      } else if (buttonText == '.') {
        if (!display.contains('.')) {
          if (isOperationPressed || display == '0' || showResult) {
            display = '0.';
            isOperationPressed = false;
            showResult = false;
          } else {
            display += '.';
          }
        }
      } else if (buttonText == '⌫') {
        if (display.length > 1 && display != '0') {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
        }
        showResult = false;
      } else {
        if (isOperationPressed || display == '0' || showResult) {
          display = buttonText;
          isOperationPressed = false;
          showResult = false;
        } else {
          display += buttonText;
        }
      }
    });
  }

  Widget buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey.shade100,
            foregroundColor: textColor ?? Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () => onButtonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: const Color(0xFF9F7AEA),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (expression.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      expression,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Text(
                  display,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      buildButton(
                        'C',
                        color: Colors.red.shade100,
                        textColor: Colors.red.shade700,
                      ),
                      buildButton(
                        '⌫',
                        color: Colors.orange.shade100,
                        textColor: Colors.orange.shade700,
                      ),
                      buildButton(
                        '÷',
                        color: const Color(0xFF9F7AEA).withOpacity(0.1),
                        textColor: const Color(0xFF9F7AEA),
                      ),
                      buildButton(
                        '×',
                        color: const Color(0xFF9F7AEA).withOpacity(0.1),
                        textColor: const Color(0xFF9F7AEA),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton('7'),
                      buildButton('8'),
                      buildButton('9'),
                      buildButton(
                        '-',
                        color: const Color(0xFF9F7AEA).withOpacity(0.1),
                        textColor: const Color(0xFF9F7AEA),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton('4'),
                      buildButton('5'),
                      buildButton('6'),
                      buildButton(
                        '+',
                        color: const Color(0xFF9F7AEA).withOpacity(0.1),
                        textColor: const Color(0xFF9F7AEA),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildButton('1'),
                      buildButton('2'),
                      buildButton('3'),
                      Expanded(
                        child: Container(
                          height: 60,
                          margin: const EdgeInsets.all(4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => onButtonPressed('='),
                            child: const Text(
                              '=',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(children: [buildButton('0'), buildButton('.')]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
