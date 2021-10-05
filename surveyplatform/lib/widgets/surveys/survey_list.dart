import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/services/survey_service.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/survey_answer.dart';

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
                print(survey.questions);
                if (!surveyStates.containsKey(survey.surveyid)) {
                  surveyStates[survey.surveyid] = defaultWidth;
                }

                return Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    constraints: BoxConstraints(
                      maxHeight: 350,
                      maxWidth: 350,
                    ),
                    width: getSurveySize(survey.surveyid),
                    child: Material(
                      shadowColor: Colors.blue,
                      elevation: 30,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => SurveyAnswerPage(survey))),
                        onHover: (isHovering) {
                          setState(() {
                            surveyStates[survey.surveyid] =
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
                                  )
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
