import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calculator_logic.dart';
import 'calculator_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculatorLogic(),
      child: MaterialApp(
        title: 'MyCal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          useMaterial3: true,
        ),
        home: const CalculatorScreen(),
      ),
    );
  }
}
