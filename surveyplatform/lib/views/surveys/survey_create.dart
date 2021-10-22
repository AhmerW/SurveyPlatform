import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/survey_create_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/admin.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/hub.dart';
import 'package:surveyplatform/views/surveys/question_list.dart';
import 'package:surveyplatform/views/surveys/widget_list.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class SurveyCreatePage extends StatefulWidget {
  const SurveyCreatePage({Key? key}) : super(key: key);

  @override
  _SurveyCreatePageState createState() => _SurveyCreatePageState();
}

class _SurveyCreatePageState extends State<SurveyCreatePage> {
  TextEditingController _titleController = TextEditingController();

  void save() {
    NewSurveyState nss = Provider.of<NewSurveyState>(context, listen: false);
    nss.setTitle(_titleController.text);
  }

  Future<ServerResponse> postSurvey(bool draft) async {
    save();
    NewSurveyState nss = Provider.of<NewSurveyState>(context, listen: false);
    ServerResponse response = await nss.postSurvey(context, draft: draft);
    return response;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _titleController.text = Provider.of<NewSurveyState>(
        context,
        listen: false,
      ).title;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HomePage.darkBackgroundColor,
        appBar: AppBar(
          backgroundColor: HomePage.darkBackgroundColor,
          elevation: 20,
          centerTitle: true,
          title: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.3,
            ),
            child: TextField(
              controller: _titleController,
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  hintText: "Klikk for å endre tittel",
                  hintStyle: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        body: Row(
          children: [
            Flexible(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 10, color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        "Widgets",
                        style: GoogleFonts.merriweather(
                            color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Divider(),
                    Flexible(
                      flex: 15,
                      child: const SurveyCreateSurveyWidgetList(),
                    ),
                    Divider(),
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              postSurvey(true).then((response) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: response.ok
                                            ? Text("Lagring vellykket")
                                            : Text("Lagring feilet")));
                              });
                            },
                            child: Text("Lagre"),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                postSurvey(false).then((response) {
                                  print("POSTED");
                                  if (response.ok)
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => HubPage(
                                                  didPublishSurvey: true,
                                                )));
                                });
                              },
                              child: Text("Publiser"),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text("Forhåndsvis"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 7,
              child: Column(
                children: [
                  Flexible(
                      flex: 4,
                      child: Consumer<NewSurveyState>(
                        builder: (context, nss, _) {
                          return Container(
                            child: SingleValueField(
                                "Poeng",
                                InputFieldState(
                                  fieldWidth: 0.2,
                                  hintText: "${nss.points}",
                                ),
                                onValidate: (value) {
                                  int? val = int.tryParse(value);
                                  if (val == null) return false;
                                  return val > 0;
                                },
                                onSubmit: (value) =>
                                    nss.setPoints(int.parse(value))),
                          );
                        },
                      )),
                  Divider(),
                  Flexible(
                    flex: 15,
                    child: QuestionList(),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
