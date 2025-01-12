import 'package:flutter/cupertino.dart';

class Question {
  static int invalidID = 0;

  final int questionID;
  int position;
  int page;

  String text;
  bool mandatory;
  final String widget;
  final Map<String, dynamic> widget_values;

  bool get isValid =>
      questionID != invalidID && widget.isNotEmpty && page != invalidID ||
      position != invalidID;

  Question({
    required this.questionID,
    required this.text,
    required this.position,
    required this.widget,
    required this.widget_values,
    this.page = 1,
    this.mandatory = true,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionID: json["question_id"] ?? 0,
      text: json["text"] ?? "",
      position: json["position"] ?? 0,
      widget: json["widget"] ?? "",
      widget_values: json["widget_values"] ?? {},
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "question_id": questionID,
      "text": text,
      "position": position,
      "widget": widget,
      "widget_values": widget_values,
    };
  }
}

class Survey {
  static int invalidID = 0;
  final int surveyID;
  bool draft;

  List<Question> questions;

  final String title;
  final int points;

  bool get isValid => surveyID != 0;

  Survey(
    this.surveyID, {
    this.draft: false,
    required this.title,
    required this.questions,
    required this.points,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    List questions = json["questions"] ?? [];
    if (!(questions is List)) {
      questions = [];
    }

    var survey = Survey(
      json["survey_id"] ?? 0,
      title: json["title"] ?? "",
      points: json["points"] ?? 0,
      questions: questions
          .map(
            (question) => Question.fromJson(question),
          )
          .toList()
        ..removeWhere((question) => !question.isValid),
    );

    return survey;
  }

  Map<String, dynamic> toJson() {
    var j = {
      "survey_id": surveyID,
      "title": title,
      "points": points,
      "questions": questions.map((question) => question.toJson()).toList()
    };

    return j;
  }
}
