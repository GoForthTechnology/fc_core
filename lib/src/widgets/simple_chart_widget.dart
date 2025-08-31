import 'package:collection/collection.dart';
import 'package:fc_core/src/logic/cycle_rendering.dart';
import 'package:fc_core/src/logic/observation_parser.dart';
import 'package:fc_core/src/models/chart.dart';
import 'package:fc_core/src/models/observation.dart';
import 'package:fc_core/src/widgets/chart_widget.dart';
import 'package:fc_core/src/widgets/cycle_widget.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

class SimpleChartWidget extends StatefulWidget {
  final List<List<String>> observations;
  final LocalDate startDate;
  final bool enableYellowStamps;
  final bool editingEnabled;
  final bool isPostPartum;

  const SimpleChartWidget({
    super.key,
    required this.observations,
    required this.startDate,
    this.enableYellowStamps = false,
    this.editingEnabled = false,
    this.isPostPartum = false,
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
    return ChartWidget(
      chart: _charts().first,
      controller: _controller,
      rightWidgetFn: (c) => null,
      stampEditingEnabled: widget.editingEnabled,
      enableYellow: widget.enableYellowStamps,
    );
  }

  List<Chart> _charts() {
    var currentDate = widget.startDate;
    List<Cycle> cycles = [];
    for (var observationStrs in widget.observations) {
      List<Observation> observations = observationStrs.mapIndexed((i, e) {
        try {
          return parseObservation(e);
        } catch (error) {
          print("Exception parsing $e (index $i): $error");
          return Observation();
        }
      }).toList();
      var renderedObservations = renderObservations(observations, null, null,
          startDate: currentDate, postPartum: widget.isPostPartum);
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
