import 'package:collection/collection.dart';
import 'package:fc_core/src/logic/cycle_rendering.dart';
import 'package:fc_core/src/logic/observation_parser.dart';
import 'package:fc_core/src/models/chart.dart';
import 'package:fc_core/src/models/observation.dart';
import 'package:fc_core/src/widgets/chart_widget.dart';
import 'package:fc_core/src/widgets/cycle_widget.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

class CycleData {
  final LocalDate startDate;
  final List<String> observations;
  final bool isPostPartum;

  CycleData(
      {required this.startDate,
      required this.observations,
      required this.isPostPartum});
}

class SimpleChartWidget extends StatefulWidget {
  final Stream<List<CycleData>> cycles;
  final LocalDate startDate;
  final bool enableYellowStamps;
  final bool editingEnabled;

  const SimpleChartWidget({
    super.key,
    required this.startDate,
    required this.cycles,
    this.enableYellowStamps = false,
    this.editingEnabled = false,
  });

  @override
  State<StatefulWidget> createState() => _SimpleChartWidgetState();
}

class _SimpleChartWidgetState extends State<SimpleChartWidget> {
  late ChartController _controller;

  @override
  void initState() {
    _controller = ChartController(startOfCharting: widget.startDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.cycles,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        var cycles = snapshot.data!;
        if (cycles.isEmpty) {
          return const Text("No cycles to display.");
        }
        return ChartWidget(
          chart: _charts(cycles).first,
          controller: _controller,
          rightWidgetFn: (c) => null,
          stampEditingEnabled: widget.editingEnabled,
          enableYellow: widget.enableYellowStamps,
        );
      },
    );
  }

  List<Chart> _charts(List<CycleData> cycleDatas) {
    var currentDate = widget.startDate;
    List<Cycle> cycles = [];
    for (var cycleData in cycleDatas) {
      List<Observation> observations =
          cycleData.observations.mapIndexed((i, e) {
        try {
          return parseObservation(e);
        } catch (error) {
          print("Exception parsing $e (index $i): $error");
          return Observation();
        }
      }).toList();
      var renderedObservations = renderObservations(observations, null, null,
          startDate: currentDate, postPartum: cycleData.isPostPartum);
      currentDate = currentDate.addDays(renderedObservations.length);

      var entries =
          renderedObservations.map(ChartEntry.fromRenderedObservation).toList();
      cycles.add(Cycle(
          index: cycles.length,
          entries: entries,
          stickerCorrections: {},
          observationCorrections: {}));
    }
    return Chart.fromCycles(cycles, 6);
  }
}
