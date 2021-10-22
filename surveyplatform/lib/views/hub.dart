import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/admin.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/views/verification.dart';
import 'package:surveyplatform/widgets/dialogs/user_dialog.dart';
import 'package:surveyplatform/widgets/surveys/survey_container.dart';
import 'package:surveyplatform/widgets/surveys/survey_list.dart';
import 'package:surveyplatform/widgets/surveys/surveysearch_container.dart';

// HubView
class HubPage extends StatefulWidget {
  final bool didPublishSurvey;
  const HubPage({this.didPublishSurvey: false});

  @override
  _HubPageState createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  @override
  void initState() {
    super.initState();
    print(widget.didPublishSurvey);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.didPublishSurvey) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Publisering vellykket!")));
      }
      AuthStateNotifier asn =
          Provider.of<AuthStateNotifier>(context, listen: false);
      print("ASN: ${asn.user} TOKEN ${asn.token}");
      if (!asn.user.verified) {
        Future.microtask(() => Navigator.push(context,
            MaterialPageRoute(builder: (_) => VerificationPage(asn.token))));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 650;
    AuthStateNotifier asn = Provider.of<AuthStateNotifier>(context);

    return Scaffold(
      backgroundColor: HomePage.backgroundColor,
      appBar: AppBar(
        backgroundColor: HomePage.backgroundColor,
        title: Provider.of<AuthStateNotifier>(context).isGuest
            ? null
            : Text(
                "Velkommen, ${asn.user.username}!",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
        centerTitle: true,
        actions: [
          Provider.of<AuthStateNotifier>(context).user.admin
              ? IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AdminPage()));
                  },
                  icon: Icon(Icons.admin_panel_settings),
                  color: Colors.red,
                )
              : SizedBox.shrink(),
          Provider.of<AuthStateNotifier>(context).isGuest
              ? SizedBox.shrink()
              : IconButton(
                  onPressed: () {},
                  color: Colors.green,
                  icon: Icon(Icons.card_giftcard),
                ),
          Consumer<AuthStateNotifier>(
            builder: (context, asn, _) {
              return IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Container(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [UserInfoDialog(asn)],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.account_circle,
                  color: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
      // SCAFFOLD BODY
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              children: [
                Consumer<AuthStateNotifier>(builder: (context, asn, _) {
                  return !asn.isGuest
                      ? SizedBox.shrink()
                      : Container(
                          alignment: Alignment.topLeft,
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.indieFlower(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              children: [
                                TextSpan(
                                    text: "Logg inn ",
                                    style: GoogleFonts.indieFlower(
                                        color: HomePage.primaryColor),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        LoginPage()))
                                          }),
                                TextSpan(
                                    text: "for å tilgang til alle funksjoner"),
                                TextSpan(text: "\nog få dine "),
                                TextSpan(
                                    text: "gratis",
                                    style: GoogleFonts.indieFlower(
                                        decoration: TextDecoration.underline)),
                                TextSpan(text: " poeng!")
                              ],
                            ),
                          ),
                        );
                }),
                Divider(
                  color: HomePage.primaryColor,
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /* SurveySearchContainer(), */
                      Expanded(
                        child: SurveyList(),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: HomePage.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
