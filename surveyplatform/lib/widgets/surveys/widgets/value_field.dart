import 'package:flutter/material.dart';
import 'package:surveyplatform/widgets/field.dart';

typedef bool ValidatorFunction(String);
typedef void SubmitFunction(String);

class SingleValueField extends StatelessWidget {
  final String text;
  final InputFieldState inputFieldState;
  final ValidatorFunction? onValidate;
  final SubmitFunction? onSubmit;
  final SubmitFunction? onChangeCurrentText;

  SingleValueField(this.text, this.inputFieldState,
      {this.onValidate, this.onSubmit, this.onChangeCurrentText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            text,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        InputField(
          inputFieldState,
          onChangeCurrentText: onChangeCurrentText,
          onSubmit: (String value) {
            bool validated = true;
            if (onValidate != null) {
              validated = onValidate!(value);
            }
            if (validated) {
              if (onSubmit != null) {
                onSubmit!(value);
              }
            } else {
              inputFieldState.controller.text = "";
            }
          },
        )
      ],
    );
  }
}
