import 'package:collection/collection.dart';
import 'package:fc_core/logic/cycle_rendering.dart';
import 'package:fc_core/logic/observation_parser.dart';
import 'package:fc_core/models/chart.dart';
import 'package:fc_core/widgets/chart_widget.dart';
import 'package:fc_core/widgets/cycle_widget.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ChartController _chartController = ChartController(
    startOfCharting: LocalDate.today(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ChartWidget(
          includeFooter: true,
          chart: Chart.fromCycles([cycle], 6).first,
          controller: _chartController,
          rightWidgetFn: (c) => null,
        ),
      ),
    );
  }
}

const observations = ["H", "M", "0 AD", "10 CK X2", "0 AD", "2 AD", "6CG X3"];
final renderedObservations = renderObservations(
  observations.map((s) => parseObservation(s)).toList(),
  null,
  null,
  startDate: LocalDate.today(),
).toList();
final entries = observations
    .mapIndexed(
      (i, o) => ChartEntry(
        observationText: o,
        additionalText: "",
        renderedObservation: renderedObservations[i],
      ),
    )
    .toList();
final cycle = Cycle(
  entries: entries,
  index: 0,
  stickerCorrections: {},
  observationCorrections: {},
);
