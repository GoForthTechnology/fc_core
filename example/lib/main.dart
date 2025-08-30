import 'package:fc_core/widgets/simple_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

const observations = ["H", "M", "0 AD", "10 CK X2", "0 AD", "2 AD", "6CG X3"];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SimpleChartWidget(
          observations: [observations],
          startDate: LocalDate.today(),
          enableYellowStamps: true,
        ),
      ),
    );
  }
}
