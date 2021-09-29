import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/surveys/survey_create.dart';
import 'package:surveyplatform/widgets/funcs.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HomePage.backgroundColor,
        appBar: AppBar(
          backgroundColor: HomePage.darkBackgroundnColor,
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
                    children: [
                      SimpleButton(
                          "Lag en ny spørreundersøkelse",
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SurveyCreatePage())))
                    ],
                  ),
                ),
              ],
            );
          },
        ));
  }
}
