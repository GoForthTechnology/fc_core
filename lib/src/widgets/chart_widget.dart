import 'package:fc_core/src/models/chart.dart';
import 'package:fc_core/src/widgets/cycle_widget.dart';
import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final Chart chart;
  final Widget? titleWidget;
  final ChartController controller;
  final bool stampEditingEnabled;
  final bool observationEditingEnabled;
  final bool correctingEnabled;
  final bool showErrors;
  final bool autoStamp;
  final bool enableYellow;
  final SoloCell? soloCell;
  final bool includeFooter;
  final Widget? Function(Cycle?) rightWidgetFn;

  const ChartWidget({
    required this.chart,
    required this.controller,
    this.stampEditingEnabled = false,
    this.observationEditingEnabled = false,
    this.correctingEnabled = false,
    this.showErrors = false,
    this.includeFooter = true,
    this.autoStamp = true,
    this.titleWidget,
    this.soloCell,
    super.key,
    required this.rightWidgetFn,
    this.enableYellow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget ?? Container(),
            _createHeaderRow(),
            ..._createCycleRows(),
            if (includeFooter) _createFooterRow(),
          ],
        ));
  }

  Widget _createHeaderRow() {
    List<Widget> sections = [];
    for (int i = 0; i < CycleWidget.nSectionsPerCycle; i++) {
      List<Widget> entries = [];
      for (int j = 0; j < CycleWidget.nEntriesPerSection; j++) {
        int entryNum = i * CycleWidget.nEntriesPerSection + j + 1;
        entries.add(Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          alignment: Alignment.center,
          height: 40,
          width: 40,
          child: Text("$entryNum"),
        ));
      }
      sections.add(Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Row(children: entries),
      ));
    }
    return Row(
      children: sections,
    );
  }

  List<Widget> _createCycleRows() {
    List<Widget> rows = [];
    for (var slice in chart.cycles) {
      rows.add(CycleWidget(
        cycle: slice.cycle,
        controller: controller,
        stampEditingEnabled: stampEditingEnabled,
        observationEditingEnabled: observationEditingEnabled,
        correctingEnabled: correctingEnabled,
        showErrors: showErrors,
        enableYellow: enableYellow,
        dayOffset: slice.offset,
        soloCell: soloCell,
        autoStamp: autoStamp,
        rightWidgetFn: rightWidgetFn,
      ));
    }
    return rows;
  }

  Widget _createFooterRow() {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Text(
          "Use these signs: P = Peak, 123 = Fertile days following Peak, I = Intercourse"),
    );
  }
}

class SoloCell {
  final int cycleIndex;
  final int entryIndex;
  final bool showSticker;

  SoloCell({
    required this.cycleIndex,
    required this.entryIndex,
    required this.showSticker,
  });
}
