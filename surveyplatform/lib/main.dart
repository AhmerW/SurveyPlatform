import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui' as ui;

import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/data/states/survey_create_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/services/answer_service.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/services/gift_service.dart';
import 'package:surveyplatform/services/survey_service.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/views/tos.dart';
import 'package:surveyplatform/widgets/surveys/survey_answer_list.dart';

GetIt locator = GetIt.instance;

void main() {
  locator.registerLazySingleton<SurveyService>(() => SurveyService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<GiftService>(() => GiftService());
  locator.registerLazySingleton<AnswerService>(() => AnswerService());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthStateNotifier(),
      ),
      ChangeNotifierProvider(
        create: (_) => SurveyStateNotifier(),
      ),
      ChangeNotifierProvider(
        create: (_) => NewSurveyState(),
        lazy: false,
      ),
      ChangeNotifierProvider(
        create: (_) => SurveyAnswerState(),
      ),
      ChangeNotifierProvider(
        create: (_) => GiftStateNotifier(),
      ),
    ],
    child: SurveyPlatform(),
  ));
}

class SurveyPlatform extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SurveyPlatform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryIconTheme: IconThemeData(
            color: Colors.white,
          ),
          primaryTextTheme:
              TextTheme(bodyText1: TextStyle(color: Colors.white))),
      home: HomePage(),
    );
  }
}

class Footer extends StatelessWidget {
  final Color bg;
  final Color fg;
  const Footer(this.bg, {this.fg: Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TOSPage()));
            },
            child: Text(
              "Vilkår og betingelser",
              style: TextStyle(color: fg),
            ),
          )
        ],
      ),
    );
  }
}
