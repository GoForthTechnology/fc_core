import 'package:fc_core/widgets/simple_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

const observations = [
  "10cx2",
  "2W X1",
  "2W x1",
  "6c X1",
  "0AD",
  "10c X3",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "10c x1",
  "0 AD",
  "10c x1",
  "0 AD",
  "4 X2",
  "8c X2",
  "8c x2",
  "6c X1",
  "6c X2",
  "6cg X1",
  "6c x1",
  "4 X2",
  "PY X1",
  "4 AD",
  "4 X2",
  "4x3",
  "10c X2",
  "0 AD",
  "10c x2",
  "4 X1",
  "8c X2",
  "",
  "4 X2",
  "10c x2",
  "4x2",
  "4 AD",
  "8c x2",
  "8c x1",
  "6cx3",
  "8c x3",
  "8c x2",
  "10ck X1",
  "4x1",
  "8c X1",
  "6cx2",
  "8c X2",
  "6cg x2",
  "0 AD",
  "6cg X2",
  "6cg x1",
  "8c x1",
  "6cg x1", // confirm 8/29
];

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
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool editingEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                editingEnabled = !editingEnabled;
              });
            },
            icon: Icon(editingEnabled ? Icons.edit : Icons.edit_off),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SimpleChartWidget(
          observations: [observations],
          startDate: LocalDate(2025, 7, 6),
          enableYellowStamps: true,
          editingEnabled: editingEnabled,
          isPostPartum: true,
        ),
      ),
    );
  }
}
