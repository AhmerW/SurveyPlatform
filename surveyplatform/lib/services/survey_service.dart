import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/const.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/models/survey.dart';

class SurveyService {
  static String serverPath = "/surveys/";

  List<Survey> surveysFromResponse(ServerResponse response,
      {String key = "surveys"}) {
    if (!response.ok) {
      return [];
    }
    var surveys = response.data[key] ?? [];

    if (!(surveys is List)) {
      return [];
    }

    return surveys
        .map(
          (survey) => Survey.fromJson(survey),
        )
        .toList()
      ..removeWhere(
        (element) => !element.isValid,
      );
  }

  Survey? surveyFromResponse(ServerResponse response) {
    List<Survey> surveys = surveysFromResponse(response);
    if (surveys.isEmpty) {
      return null;
    }
    return surveys.elementAt(0);
  }

  Future<List<Survey>> getSurveys() async {
    ServerResponse response = await sendServerRequest(
      serverPath,
      RequestType.Get,
    );

    return surveysFromResponse(response);
  }

  Future<List<Survey>> getSurveyDrafts(BuildContext context) async {
    ServerResponse response = await sendServerRequestAuthenticated(
      "/drafts/",
      RequestType.Get,
      token: Provider.of<AuthStateNotifier>(context, listen: false).token,
    );
    return surveysFromResponse(response);
  }

  Future<ServerResponse> postSurvey(Survey survey, String token) async {
    print("sending authenticated request");
    Map<String, dynamic> sj = survey.toJson();
    if (sj["survey_id"] == Survey.invalidID) {
      sj.remove("survey_id");
    }
    return await sendServerRequestAuthenticated(
      serverPath,
      RequestType.Post,
      data: jsonEncode(sj),
      headers: {"Content-Type": "application/json"},
      token: token,
    );
  }
}
