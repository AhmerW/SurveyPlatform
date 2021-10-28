import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/services/survey_service.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/surveys/survey_answer.dart';
import 'package:surveyplatform/widgets/dialogs/captcha_dialog.dart';

class SurveyList extends StatefulWidget {
  const SurveyList({Key? key}) : super(key: key);

  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  Future<List<Survey>> fakeSurveys() async {
    return Future.delayed(
      Duration.zero,
      () => List<Survey>.generate(
          10,
          (index) =>
              Survey(index, title: index.toString(), questions: [], points: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, double> surveyStates = {};
    double defaultWidth = 300;
    double hoverWidth = 350;

    double getSurveySize(int survey_id) {
      return surveyStates[survey_id]!;
    }

    return Center(
      child: FutureBuilder(
        future: Provider.of<SurveyStateNotifier>(context, listen: false)
            .getSurveys(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed loading surveys",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          if (snapshot.hasData) {
            List<Survey> surveys = (snapshot.data ?? []) as List<Survey>;

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                Survey survey = surveys[index];

                if (!surveyStates.containsKey(survey.surveyID)) {
                  surveyStates[survey.surveyID] = defaultWidth;
                }

                return Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    constraints: BoxConstraints(
                      maxHeight: 350,
                      maxWidth: 350,
                    ),
                    width: getSurveySize(survey.surveyID),
                    child: Material(
                      shadowColor: HomePage.primaryColor,
                      elevation: 30,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          AuthStateNotifier asn =
                              Provider.of<AuthStateNotifier>(context,
                                  listen: false);
                          if (asn.isUser) {
                            Provider.of<SurveyAnswerState>(context,
                                    listen: false)
                                .surveyIsAnswered(
                              asn.user.uid,
                              survey.surveyID,
                              token: getToken(context),
                            )
                                .then((value) {
                              if (!value) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SurveyAnswerPage(survey),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Du har allerede svart på denne undersøkelsen"),
                                  ),
                                );
                              }
                            });
                          } else if (asn.isGuest) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SurveyAnswerPage(survey),
                              ),
                            );
                          }
                        },
                        onHover: (isHovering) {
                          setState(() {
                            surveyStates[survey.surveyID] =
                                isHovering ? hoverWidth : defaultWidth;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                survey.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.merriweather(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Spacer(),
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.emoji_events,
                                      color: HomePage.primaryColor),
                                  Text(
                                    "${survey.points} poeng",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                CaptchaDialog());
                                      },
                                      icon: Icon(Icons.device_hub)),
                                  OutlinedButton(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  SurveyAnswerPage(survey))),
                                      child: Text("Svar"))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
