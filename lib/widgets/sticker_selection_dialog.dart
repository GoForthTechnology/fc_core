import 'package:fc_core/models/chart.dart';
import 'package:fc_core/models/stickers.dart';
import 'package:fc_core/widgets/sticker_widget.dart';
import 'package:flutter/material.dart';

class StickerCorrectionDialog extends StatelessWidget {
  final Cycle cycle;
  final int entryIndex;
  final bool editingEnabled;
  final bool includeYellow;
  final StickerWithText? existingCorrection;

  final Function(int, int, StickerWithText?) editSticker;
  final Function(int, int, StickerWithText?) correctSticker;

  const StickerCorrectionDialog({
    super.key,
    required this.entryIndex,
    this.existingCorrection,
    required this.cycle,
    required this.editingEnabled,
    required this.editSticker,
    required this.correctSticker,
    required this.includeYellow,
  });

  @override
  Widget build(BuildContext context) {
    Sticker? selectedSticker = existingCorrection?.sticker;
    String? selectedStickerText = existingCorrection?.text;
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: editingEnabled
            ? const Text('Edit Stamp')
            : const Text("Correct Stamp"),
        content: _createStickerCorrectionContent(
            selectedSticker, selectedStickerText, includeYellow, (sticker) {
          setState(() {
            if (selectedSticker == sticker) {
              selectedSticker = null;
            } else {
              selectedSticker = sticker;
            }
          });
        }, (text) {
          setState(() {
            if (selectedStickerText == text) {
              selectedStickerText = null;
            } else {
              selectedStickerText = text;
            }
          });
        }),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              StickerWithText? correction;
              if (selectedSticker != null) {
                correction =
                    StickerWithText(selectedSticker!, selectedStickerText);
              }
              if (!editingEnabled) {
                correctSticker(cycle.index, entryIndex, correction);
              } else {
                editSticker(cycle.index, entryIndex, correction);
              }
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      );
    });
  }

  Widget _createStickerCorrectionContent(
      Sticker? selectedSticker,
      String? selectedStickerText,
      bool includeYellow,
      void Function(Sticker?) onSelectSticker,
      void Function(String?) onSelectText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Select the correct sticker")),
        StickerSelectionRow(
          selectedSticker: selectedSticker,
          onSelect: onSelectSticker,
          includeYellow: includeYellow,
        ),
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Select the correct text")),
        StickerTextSelectionRow(
          selectedText: selectedStickerText,
          onSelect: onSelectText,
          sticker: Sticker.white,
        ),
      ],
    );
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

class StickerTextSelectionRow extends StatelessWidget {
  final String? selectedText;
  final Sticker sticker;
  final void Function(String?) onSelect;

  const StickerTextSelectionRow(
      {super.key,
      this.selectedText,
      required this.onSelect,
      required this.sticker});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dialogTextSticker(""),
        _dialogTextSticker("P"),
        _dialogTextSticker("1"),
        _dialogTextSticker("2"),
        _dialogTextSticker("3"),
      ],
    );
  }

  Widget _dialogTextSticker(String text) {
    Widget sticker = StickerWidget(
        stickerWithText: StickerWithText(this.sticker, text),
        onTap: () => onSelect(text));
    var message = text == "" ? "No Text" : text;
    sticker = Tooltip(message: message, child: sticker);
    if (selectedText == text) {
      sticker = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: sticker,
      );
    }
    return Padding(padding: const EdgeInsets.all(2), child: sticker);
  }
}
