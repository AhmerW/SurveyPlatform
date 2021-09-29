// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/widgets/surveys/widgets/openended.dart';
import 'package:surveyplatform/widgets/surveys/widgets/ratingscale.dart';
import 'package:surveyplatform/widgets/surveys/widgets/slider.dart';

final Map<String, Map<String, dynamic>> surveyValues = {
  "Slider": {"min": 32, "max": 100, "divisions": 100},
  "OpenEnded": {"hint": "hint", "maxChars": 2000, "minChars": 0},
  "RatingScale": {"minValue": 0, "maxValue": 100}
};
final List<String> surveyWidgetsList = surveyValues.keys.toList();

Widget getSurveyWidget(QuestionState question) {
  switch (question.widget) {
    case "Slider":
      return SliderWidget(question);
    case "OpenEnded":
      return OpenEndedWidget(question);
    case "RatingScale":
      return RatingScaleWidget(question);
  }
  return SizedBox.shrink();
}

Map<String, dynamic> getQuestionValues(String widget) {
  return Map<String, dynamic>.from(surveyValues[widget] ?? {});
}
