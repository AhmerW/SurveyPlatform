import 'package:flutter/material.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

Widget SaqGetWidget(Question question, QuestionAnswer qa) {
  switch (question.widget) {
    case "Slider":
      return Container();
    case "OpenEnded":
      return SaqOpenEnded(question, qa);
    case "RatingScale":
      return Container();
  }
  return SizedBox.shrink();
}

// Widgets

class SaqOpenEnded extends StatefulWidget {
  final QuestionAnswer questionAnswer;
  final Question question;
  SaqOpenEnded(this.question, this.questionAnswer);

  @override
  _SaqOpenEndedState createState() => _SaqOpenEndedState();
}

class _SaqOpenEndedState extends State<SaqOpenEnded> {
  String getHint() {
    return widget.question.widget_values["hint"] ?? "";
  }

  int getMax() {
    int? value = widget.question.widget_values["maxChars"];
    if (!(value is int)) return 100;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SingleValueField(
            "",
            InputFieldState(
              hintText: getHint(),
              fieldWidth: 0.5,
              customDecoration: InputDecoration(
                hintText: getHint(),
              ),
              maxLength: getMax(),
            ),
            onSubmit: (s) => widget.questionAnswer.setValue(s),
          ),
        ],
      ),
    );
  }
}
