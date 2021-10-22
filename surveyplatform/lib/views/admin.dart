import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/surveys/survey_create.dart';
import 'package:surveyplatform/widgets/dialogs/gifts/gift_dialog.dart';
import 'package:surveyplatform/widgets/funcs.dart';
import 'package:surveyplatform/widgets/surveys/widgets/admin_survey_list.dart';

typedef void CallbackFn(BuildContext context);

class AdminPageButton {
  final String title;
  final CallbackFn callback;

  AdminPageButton(this.title, this.callback);
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<AdminPageButton> _adminPageButtons = [
    AdminPageButton(
      "Administrer spørreundersøkelser",
      (BuildContext context) => showDialog(
        context: context,
        builder: (context) => _AdminSurveyDialog(),
      ),
    ),
    AdminPageButton(
      "Lag en ny spørreundersøkelse",
      (BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SurveyCreatePage(),
        ),
      ),
    ),
    AdminPageButton(
      "Administrer gaver",
      (context) {
        showDialog(
          context: context,
          builder: (context) => GiftDialog(),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HomePage.backgroundColor,
        appBar: AppBar(
          backgroundColor: HomePage.darkBackgroundColor,
          title: Text("Admin panel",
              style: GoogleFonts.merriweather(color: Colors.white)),
        ),
        body: Consumer<AuthStateNotifier>(
          builder: (context, asn, _) {
            return Column(
              children: [
                Center(
                    child: RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(text: "Velkommen til admin panelet!"),
                        TextSpan(
                            text:
                                "\nHer kan du få tilgang til eksisterende spørreundersøkelser, og lage nye."),
                        asn.user.owner
                            ? TextSpan(
                                text: "\nDu er logget inn som eier",
                                style: GoogleFonts.indieFlower(
                                    fontStyle: FontStyle.italic))
                            : TextSpan()
                      ],
                      style: GoogleFonts.indieFlower(
                          color: Colors.white, fontSize: 20)),
                )),
                CustomDivider(),
                Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _adminPageButtons
                          .map((btn) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 50),
                                    height:
                                        (MediaQuery.of(context).size.height *
                                                0.7) /
                                            _adminPageButtons.length,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: SimpleButton(
                                      btn.title,
                                      () => btn.callback(context),
                                    ),
                                  ),
                                ],
                              ))
                          .toList()),
                ),
              ],
            );
          },
        ));
  }
}

//

class _AdminSurveyDialog extends StatefulWidget {
  const _AdminSurveyDialog({Key? key}) : super(key: key);

  @override
  __AdminSurveyDialogState createState() => __AdminSurveyDialogState();
}

class __AdminSurveyDialogState extends State<_AdminSurveyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HomePage.darkBackgroundColor,
      title: Text(
        "Spørreundersøkelser",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      content: Container(
        color: HomePage.darkBackgroundColor,
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
        child: AdminSurveyList(),
      ),
    );
  }
}
