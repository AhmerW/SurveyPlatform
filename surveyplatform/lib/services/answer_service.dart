import 'dart:convert';

import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';

class AnswerService {
  static final String path = "/surveys/";

  static String constructPath(int survey_id) => "$path$survey_id/answers/";

  Future<ServerResponse> postAnswer(
    int survey_id,
    Map<String, dynamic> answer, {
    required String token,
    required String solve_token,
    bool isGuest: false,
  }) {
    if (isGuest) {
      return sendServerRequest(
        constructPath(survey_id),
        RequestType.Post,
        data: jsonEncode(answer),
        headers: {
          "Content-Type": "application/json",
          "solve-token": solve_token,
        },
      );
    }
    return sendServerRequestAuthenticated(
      constructPath(survey_id),
      RequestType.Post,
      data: jsonEncode(answer),
      headers: {
        "Content-Type": "application/json",
        "solve-token": solve_token,
      },
      token: token,
    );
  }

  Future<bool> isSurveyAnswered(
    int survey_id,
    int uid, {
    required String token,
  }) async {
    ServerResponse response = await sendServerRequestAuthenticated(
      "$path$survey_id/answered",
      RequestType.Get,
      token: token,
    );

    if (response.data.containsKey("answered") &&
        (response.data["answered"] is bool)) {
      return response.data["answered"];
    }
    return false;
  }
}
