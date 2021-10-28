import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/const.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/services/survey_service.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/surveys/survey_answer.dart';
import 'package:surveyplatform/widgets/dialogs/simple_options_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSurveyList extends StatefulWidget {
  const AdminSurveyList({Key? key}) : super(key: key);

  @override
  _AdminSurveyListState createState() => _AdminSurveyListState();
}

class _AdminSurveyListState extends State<AdminSurveyList> {
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
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => SurveyAnswerPage(survey))),
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
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Tooltip(
                                            message: "Slett",
                                            child: IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      SimpleOptionsDialog(
                                                    onSubmit: () {
                                                      setState(() {
                                                        Provider.of<
                                                                SurveyStateNotifier>(
                                                          context,
                                                          listen: false,
                                                        )
                                                            .deleteSurvey(
                                                          survey,
                                                          getToken(context),
                                                        )
                                                            .then((response) {
                                                          if (response.ok) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } else if (response
                                                              .hasError) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                          title:
                                                                              Text("error"),
                                                                          content: Text(response
                                                                              .error!
                                                                              .message),
                                                                        ));
                                                          }
                                                        });
                                                      });
                                                    },
                                                    title:
                                                        "Er du sikker på at du vil slette denne undersøkelsen?",
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          Tooltip(
                                            message: "Rediger",
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.edit),
                                            ),
                                          ),
                                          Tooltip(
                                            message: "Synlighet",
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {});
                                              },
                                              icon: survey.draft
                                                  ? Icon(Icons.visibility_off)
                                                  : Icon(Icons.visibility),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Tooltip(
                                            message: "Last ned",
                                            child: IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      backgroundColor: HomePage
                                                          .darkBackgroundColor,
                                                      title: Text(
                                                        "Last ned alle svar",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      content: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        color: HomePage
                                                            .darkBackgroundColor,
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                              title: Text("CSV",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  launch(
                                                                      "$fullServerUrl/surveys/${survey.surveyID}/answers?format=csv",
                                                                      headers: {
                                                                        "Authorization":
                                                                            "bearer ${getToken(context)}"
                                                                      });
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .download,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                              ),
                                                            ),
                                                            ListTile(
                                                              title: Text(
                                                                  "JSON",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                              trailing:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  launch(
                                                                    "$fullServerUrl/surveys/${survey.surveyID}/answers?format=json",
                                                                    headers: {
                                                                      "Authorization":
                                                                          "bearer ${getToken(context)}"
                                                                    },
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .download,
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.download,
                                                )),
                                          ),
                                        ],
                                      )
                                    ],
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
