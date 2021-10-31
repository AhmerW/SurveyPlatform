import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/captcha_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/dialogs/captcha_dialog.dart';
import 'package:surveyplatform/widgets/dialogs/submit_survey_answer_dialog.dart';
import 'package:surveyplatform/widgets/surveys/survey_answer_question.dart';

class SurveyAnswerList extends StatefulWidget {
  final Survey survey;
  const SurveyAnswerList(this.survey);

  @override
  _SurveyAnswerListState createState() => _SurveyAnswerListState();
}

class _SurveyAnswerListState extends State<SurveyAnswerList> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.survey.questions.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.survey.questions.length) {
          return _SurveyAnswerDone(widget.survey);
        }
        Question question = widget.survey.questions[index];

        return Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: HomePage.darkBackgroundColor, width: .5)),
                      child: PhysicalModel(
                        color: HomePage.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              question.text.isEmpty
                                  ? "Spørsmålet har ingen tekst.."
                                  : question.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 20),
                              child: Consumer<SurveyAnswerState>(
                                builder: (context, sas, _) {
                                  QuestionAnswer? answer = sas.getAnswer(
                                      widget.survey.surveyID,
                                      question.questionID);

                                  if (answer != null) {
                                    return SaqGetWidget(
                                      question,
                                      answer,
                                    );
                                  }
                                  return Text("Widget not found");
                                },
                              ),
                            ),
                            Divider(),
                            Spacer(),
                            question.mandatory
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.all(30),
                                    child: Text(
                                      "Dette spørsmålet er obligatorisk!",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Consumer<SurveyAnswerState>(builder: (context, sas, _) {
                  bool isAnswered = sas.questionIsAnswered(
                    widget.survey.surveyID,
                    question.questionID,
                    isMandatory: question.mandatory,
                  );
                  return Container(
                    padding: EdgeInsets.only(top: 100),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: () => _pageController.nextPage(
                          duration: Duration(seconds: 1), curve: Curves.ease),
                      child: Text("Neste spørsmål"),
                      style: ElevatedButton.styleFrom(
                          primary: HomePage.primaryColor),
                    ),
                  );
                })
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SurveyAnswerDone extends StatefulWidget {
  final Survey survey;
  const _SurveyAnswerDone(this.survey);

  @override
  __SurveyAnswerDoneState createState() => __SurveyAnswerDoneState();
}

class __SurveyAnswerDoneState extends State<_SurveyAnswerDone> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SurveyAnswerState>(builder: (context, sas, _) {
      return sas.isAnswered(widget.survey.surveyID, widget.survey.questions)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Du har svart på alle spørsmål!",
                    style: GoogleFonts.merriweather(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: OutlinedButton(
                    onPressed: () {
                      CaptchaState captchaState =
                          Provider.of<CaptchaState>(context, listen: false);

                      showDialog(
                          context: context,
                          builder: (context) => CaptchaDialog()).then((_) {
                        if (captchaState.hasSolveToken)
                          showDialog(
                            context: context,
                            builder: (context) => SubmitSurveyAnswerDialog(
                              widget.survey.surveyID,
                            ),
                          ).then((value) {});
                        else
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Vennligst løs Captcha før du fortsetter")));
                      });
                    },
                    child: Text("Send svar"),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Vennligst svar på alle spørsmål først.",
                    style: GoogleFonts.merriweather(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
    });
  }
}
