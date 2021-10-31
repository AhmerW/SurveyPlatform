import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui' as ui;

import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/captcha_state.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/data/states/survey_create_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/services/answer_service.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/services/gift_service.dart';
import 'package:surveyplatform/services/survey_service.dart';
import 'package:surveyplatform/views/forgot_password.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/hub.dart';
import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/views/register.dart';
import 'package:surveyplatform/views/surveys/survey_answer.dart';
import 'package:surveyplatform/views/surveys/survey_create.dart';
import 'package:surveyplatform/views/surveys/surveyid_answer.dart';
import 'package:surveyplatform/views/tos.dart';
import 'package:surveyplatform/views/verification.dart';
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
      ChangeNotifierProvider(
        create: (_) => CaptchaState(),
      ),
    ],
    child: SurveyPlatform(),
  ));
}

class SurveyPlatform extends StatelessWidget {
  final _router = GoRouter(
    initialLocation: "/home",
    routes: [
      GoRoute(
        path: "/home",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: "/hub",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: HubPage(
            data: state.extra == null
                ? HubPageData()
                : (state.extra as HubPageData),
          ),
        ),
      ),
      GoRoute(
        path: "/login",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: "/register",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: RegisterPage(),
        ),
      ),
      GoRoute(
        path: "/verification",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: VerificationPage(state.extra as String),
        ),
      ),
      GoRoute(
        path: "/tos",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: TOSPage(),
        ),
      ),
      GoRoute(
          path: "/surveys",
          pageBuilder: (context, state) {
            if (state.queryParams.containsKey("surveyid")) {
              int? surveyid =
                  int.tryParse(state.queryParams["surveyid"] as String);
              if (surveyid != null) {
                return MaterialPage<void>(
                  key: state.pageKey,
                  child: SurveyIDAnswerPage(surveyid),
                );
              }
            }
            return MaterialPage<void>(
              key: state.pageKey,
              child: HubPage(),
            );
          }),
      GoRoute(
        path: "/surveys/create",
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: SurveyCreatePage(),
        ),
      ),
      GoRoute(
        path: "/surveys/answer",
        pageBuilder: (context, state) {
          if (state.queryParams.containsKey("survey_id")) {}
          return MaterialPage<void>(
            key: state.pageKey,
            child: SurveyAnswerPage(state.extra as SurveyAnswerPageData),
          );
        },
      ),
      GoRoute(
        path: "/forgot",
        pageBuilder: (context, state) {
          if (state.queryParams["token"] == null ||
              state.queryParams["token"]!.isEmpty) {
            return MaterialPage<void>(
                key: state.pageKey,
                child: Scaffold(
                  body: Center(
                    child: Text("No token provided"),
                  ),
                ));
          }

          return MaterialPage<void>(
            key: state.pageKey,
            child: LoginForgotPassword(state.queryParams["token"]!),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage<void>(
      child: Scaffold(
        key: state.pageKey,
        body: Center(
          child: Text(
            state.error.toString(),
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SurveyPlatform',
      debugShowCheckedModeBanner: false,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryIconTheme: IconThemeData(
            color: Colors.white,
          ),
          primaryTextTheme:
              TextTheme(bodyText1: TextStyle(color: Colors.white))),
    );
  }
}
