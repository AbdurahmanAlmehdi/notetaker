import 'package:flutter/material.dart';
import 'package:notetaker/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An Error has occurred',
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
