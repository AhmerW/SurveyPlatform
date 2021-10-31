import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/login_container.dart';
import 'package:surveyplatform/widgets/surveys/survey_answer_list.dart';

class SurveyAnswerPageData {
  final Survey survey;
  final bool preview;

  const SurveyAnswerPageData(this.survey, {this.preview: false});
}

class SurveyAnswerPage extends StatefulWidget {
  final SurveyAnswerPageData data;

  const SurveyAnswerPage(this.data);

  @override
  _SurveyAnswerPageState createState() => _SurveyAnswerPageState();
}

class _SurveyAnswerPageState extends State<SurveyAnswerPage> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        Provider.of<SurveyAnswerState>(context, listen: false).fromQuestions(
          widget.data.survey.surveyID,
          widget.data.survey.questions,
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePage.backgroundColor,
      body: Column(
        children: [
          Container(
            height: 50,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              widget.data.survey.title,
              style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 30,
                  fontStyle: FontStyle.italic),
            ),
          ),
          RichText(
              text: TextSpan(
            style: TextStyle(
              color: Colors.white,
            ),
            children: [
              TextSpan(text: "Belønning: "),
              TextSpan(
                  text: "${widget.data.survey.points}p",
                  style: TextStyle(fontStyle: FontStyle.italic))
            ],
          )),
          Row(
            children: [
              Tooltip(
                message: "Tilbake",
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back,
                        color: HomePage.darkBackgroundColor)),
              ),
              Tooltip(
                message: "Del undersøkelse",
                child: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                          text:
                              "https://surveyplatform.net/#/surveys?surveyid=${widget.data.survey.surveyID}"),
                    ).then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Linken har blitt kopiert!"),
                              ),
                            ));
                  },
                  icon: Icon(Icons.share, color: Colors.orange),
                ),
              )
            ],
          ),
          Divider(),
          Consumer<AuthStateNotifier>(
            builder: (context, asn, _) {
              return asn.isUser
                  ? SizedBox.shrink()
                  : Container(
                      child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (contxet) => AlertDialog(
                                backgroundColor: HomePage.backgroundColor,
                                title: Text("Logg inn",
                                    style: TextStyle(color: Colors.white)),
                                content: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: LoginContainer(),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "NB: Du er ikke logget inn, og du vil derfor ikke få poeng dersom du svarer på denne undersøkelsen!\nKlikk for å logge inn.",
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ));
            },
          ),
          Expanded(
            child: Container(
              child: SurveyAnswerList(
                widget.data.survey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
