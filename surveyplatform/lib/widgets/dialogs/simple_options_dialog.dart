import 'package:flutter/material.dart';

class SimpleOptionsDialog extends StatelessWidget {
  final String title, submitText, cancelText;
  VoidCallback? onSubmit, onCancel;
  SimpleOptionsDialog(
      {this.submitText: "OK",
      this.cancelText: "Avbryt",
      this.title: "",
      this.onSubmit,
      this.onCancel});

  close(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: onSubmit ?? () => close(context),
                child: Text(submitText)),
            OutlinedButton(
                onPressed: onCancel ?? () => close(context),
                child: Text(cancelText))
          ],
        ),
      ),
    );
  }
}
