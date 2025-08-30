import 'dart:math';
import 'dart:ui' as ui;

import 'package:fc_core/models/chart.dart';
import 'package:fc_core/models/rendered_observation.dart';
import 'package:fc_core/models/stickers.dart';
import 'package:fc_core/widgets/chart_cell_widget.dart';
import 'package:fc_core/widgets/chart_row_widget.dart';
import 'package:fc_core/widgets/chart_widget.dart';
import 'package:fc_core/widgets/sticker_selection_dialog.dart';
import 'package:fc_core/widgets/sticker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart' as time;

class ChartController {
  final time.LocalDate _startOfCharting;
  late List<time.LocalDate> _followUps;
  final time.LocalDate? _currentFollowUpDate;

  ChartController(
      {required time.LocalDate startOfCharting,
      List<time.LocalDate> followUps = const [],
      time.LocalDate? currentFollowUpDate})
      : _startOfCharting = startOfCharting,
        _currentFollowUpDate = currentFollowUpDate {
    _followUps = followUps;
  }

  time.LocalDate startOfCharting() => _startOfCharting;
  List<time.LocalDate> followUps() => _followUps;
  time.LocalDate? currentFollowUpDate() => _currentFollowUpDate;
}

class CycleWidget extends StatefulWidget {
  final Cycle? cycle;
  final ChartController controller;
  final int dayOffset;
  final bool correctingEnabled;
  final bool stampEditingEnabled;
  final bool observationEditingEnabled;
  final bool showErrors;
  final bool autoStamp;
  final bool enableYellow;
  final SoloCell? soloCell;
  final Widget? Function(Cycle?) rightWidgetFn;
  final Function()? onTapObservation;
  final Function()? onTapSticker;

  static const int nSectionsPerCycle = 5;
  static const int nEntriesPerSection = 7;

  const CycleWidget({
    required this.cycle,
    required this.controller,
    this.onTapObservation,
    this.onTapSticker,
    this.stampEditingEnabled = false,
    this.observationEditingEnabled = false,
    this.correctingEnabled = false,
    this.showErrors = false,
    this.autoStamp = true,
    this.enableYellow = false,
    this.dayOffset = 0,
    this.soloCell,
    super.key,
    required this.rightWidgetFn,
  });

  @override
  State<StatefulWidget> createState() => CycleWidgetState();
}

class CycleWidgetState extends State<CycleWidget> {
  @override
  Widget build(BuildContext context) {
    return ChartRowWidget(
      dayOffset: widget.dayOffset,
      topCellCreator: _createStickerCell,
      bottomCellCreator: _createObservationCell,
      rightWidget: widget.rightWidgetFn(widget.cycle),
    );
  }

  void _editSticker(int entryIndex, StickerWithText? sticker) {
    setState(() {
      if (widget.cycle == null) {
        return;
      }
      var existingEntry = widget.cycle!.entries[entryIndex];
      widget.cycle!.entries[entryIndex] =
          existingEntry.withManualSticker(sticker);
    });
  }

  void _correctSticker(int entryIndex, StickerWithText? sticker) {
    setState(() {
      if (widget.cycle == null) {
        return;
      }
      if (sticker != null) {
        widget.cycle!.stickerCorrections[entryIndex] = sticker;
      } else {
        widget.cycle!.stickerCorrections.remove(entryIndex);
      }
    });
  }

  ChartEntry? _getChartEntry(int entryIndex) {
    if (widget.cycle == null) {
      return null;
    }
    if (entryIndex >= widget.cycle!.entries.length) {
      return null;
    }
    var hasCycle = widget.cycle != null;
    if (widget.soloCell == null &&
        hasCycle &&
        entryIndex < widget.cycle!.entries.length) {
      return widget.cycle?.entries[entryIndex];
    } else if (widget.soloCell != null &&
        widget.soloCell!.entryIndex >= entryIndex) {
      return widget.cycle?.entries[entryIndex];
    }
    return null;
  }

  Widget _createObservationCell(int entryIndex) {
    var entry = _getChartEntry(entryIndex);
    var entryDate = entry?.renderedObservation?.date;
    var currentFollowUpDate = widget.controller.currentFollowUpDate();
    bool showDate =
        entryDate != null && entryDate >= widget.controller.startOfCharting();
    bool showObservation = showDate;
    if (currentFollowUpDate != null) {
      showDate = showDate && entryDate <= currentFollowUpDate;
      showObservation = showObservation && entryDate < currentFollowUpDate;
    }
    var textBackgroundColor = Colors.white;
    if (widget.showErrors && (entry?.hasErrors() ?? false) && showObservation) {
      textBackgroundColor = const Color(0xFFEECDCD);
    }
    if (!showObservation) {
      if (entryDate != null && currentFollowUpDate == entryDate) {
        entry = ChartEntry(
          observationText: '',
          additionalText: '',
          renderedObservation: RenderedObservation.blank(entryDate),
        );
      } else {
        entry = null;
      }
    }
    bool hasFollowup =
        entryDate != null && widget.controller.followUps().contains(entryDate);
    String? observationCorrection =
        widget.cycle?.observationCorrections[entryIndex];
    Widget content = CustomPaint(
      painter: ObservationPainter(
        entry,
        observationCorrection,
        drawOval: showDate && hasFollowup,
      ),
    );
    var canShowDialog =
        widget.observationEditingEnabled || widget.correctingEnabled;
    return ChartCellWidget(
      alignment: Alignment.topCenter,
      content: content,
      backgroundColor: textBackgroundColor,
      onTap:
          (!canShowDialog || entry == null || widget.onTapObservation == null)
              ? () {}
              : widget.onTapObservation!,
      onLongPress: () {
        if (kDebugMode) {
          print(entry?.toJson());
        }
      },
    );
  }

  Widget _createStickerCell(int entryIndex) {
    var soloingCell =
        widget.soloCell != null && widget.soloCell!.entryIndex == entryIndex;
    var alreadySoloed =
        widget.soloCell != null && widget.soloCell!.entryIndex > entryIndex;
    var entry = _getChartEntry(entryIndex);
    RenderedObservation? observation = entry?.renderedObservation;

    StickerWithText? sticker = entry?.manualSticker;
    if (sticker == null && widget.autoStamp && observation != null) {
      sticker = observation.getStickerWithText();
    }
    var entryDate = entry?.renderedObservation?.date;
    var currentFollowUpDate = widget.controller.currentFollowUpDate();
    bool showSticker = entryDate != null &&
        entryDate >= widget.controller.startOfCharting() &&
        (currentFollowUpDate == null || entryDate < currentFollowUpDate);
    if (!showSticker) {
      sticker = null;
    }
    if (soloingCell && sticker == null) {
      sticker = StickerWithText(Sticker.grey, "?");
    }
    var showStickerDialog = !soloingCell ||
        alreadySoloed ||
        (soloingCell && (observation != null || entry?.manualSticker != null));
    Widget stickerWidget = StickerWidget(
      stickerWithText: sticker,
      onTap: _showCorrectionDialog(
          context, entryIndex, /*this is sketchy*/ entry?.manualSticker),
    );
    StickerWithText? stickerCorrection =
        widget.cycle?.stickerCorrections[entryIndex];
    if (showStickerDialog && stickerCorrection != null) {
      stickerWidget = Stack(children: [
        stickerWidget,
        Transform.rotate(
          angle: -pi / 12.0,
          child: StickerWidget(
            stickerWithText: StickerWithText(
              stickerCorrection.sticker,
              stickerCorrection.text,
            ),
            onTap:
                _showCorrectionDialog(context, entryIndex, stickerCorrection),
          ),
        )
      ]);
    }
    return stickerWidget;
  }

  void Function() _showCorrectionDialog(BuildContext context, int entryIndex,
      StickerWithText? existingCorrection) {
    return () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StickerCorrectionDialog(
            entryIndex: entryIndex,
            cycle: widget.cycle!,
            includeYellow: widget.enableYellow,
            editingEnabled: widget.stampEditingEnabled,
            existingCorrection: existingCorrection,
            correctSticker: (cycleIndex, entryIndex, correction) =>
                _correctSticker(entryIndex, correction),
            editSticker: (cycleIndex, entryIndex, correction) =>
                _editSticker(entryIndex, correction),
          );
        },
      );
    };
  }
}

class ObservationPainter extends CustomPainter {
  final ChartEntry? entry;
  final String? observationCorrection;
  final bool drawOval;

  ObservationPainter(this.entry, this.observationCorrection,
      {this.drawOval = false});

  @override
  void paint(Canvas canvas, Size size) {
    _drawText(canvas, size);
    if (drawOval) {
      _drawOval(canvas);
    }
  }

  void _drawText(Canvas canvas, Size size) {
    TextPainter textPainter = TextPainter(
      text: _getText(),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    const yCenter = 0.0;
    final Offset offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  void _drawOval(Canvas canvas) {
    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, 6),
          width: 36,
          height: 20,
        ),
        paint);
  }

  TextSpan _getText() {
    RenderedObservation? observation = entry?.renderedObservation;
    bool hasObservationCorrection =
        (observation != null || entry?.manualSticker != null) &&
            observationCorrection != null;
    String? dateString = entry?.renderedObservation?.date?.toString("MM/dd");
    String observationText = [entry?.observationText, entry?.additionalText]
        .where((e) => e != null)
        .join("\n");
    return TextSpan(
      style: const TextStyle(fontSize: 10, color: Colors.black),
      children: [
        if (dateString != null)
          TextSpan(
            text: "$dateString\n",
          ),
        const TextSpan(
          text: "\n",
          style: TextStyle(fontSize: 5),
        ),
        TextSpan(
          text: observationText,
          style: hasObservationCorrection
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough, fontSize: 10)
              : null,
        ),
        if (hasObservationCorrection)
          TextSpan(
            text: "\n$observationCorrection",
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10),
          ),
      ],
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class StickerSelectionRow extends StatelessWidget {
  final bool includeYellow;
  final Sticker? selectedSticker;
  final void Function(Sticker?) onSelect;

  const StickerSelectionRow(
      {super.key,
      this.selectedSticker,
      required this.onSelect,
      this.includeYellow = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _createDialogSticker(Sticker.red, selectedSticker, onSelect),
        _createDialogSticker(Sticker.green, selectedSticker, onSelect),
        _createDialogSticker(Sticker.greenBaby, selectedSticker, onSelect),
        _createDialogSticker(Sticker.whiteBaby, selectedSticker, onSelect),
        if (includeYellow)
          _createDialogSticker(Sticker.yellow, selectedSticker, onSelect),
        if (includeYellow)
          _createDialogSticker(Sticker.yellowBaby, selectedSticker, onSelect),
      ],
    );
  }
}

Widget _createDialogSticker(Sticker sticker, Sticker? selectedSticker,
    void Function(Sticker?) onSelect) {
  Widget child = StickerWidget(
      stickerWithText: StickerWithText(sticker, null),
      onTap: () => onSelect(sticker));
  child = Tooltip(message: sticker.name, child: child);
  if (selectedSticker == sticker) {
    child = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: child,
    );
  }
  return Padding(padding: const EdgeInsets.all(2), child: child);
}
