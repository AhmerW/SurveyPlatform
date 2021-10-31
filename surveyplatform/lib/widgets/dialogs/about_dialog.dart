import 'package:flutter/material.dart';

class PageAboutDialog extends StatelessWidget {
  const PageAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Om oss"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "SurveyPlatform er en veldig enkel nettside der du kan svare på spørreundersøkelser og få poeng.\nDisse poengene kan veksles for blant annet gavekort.\n\nHar du noen andre spørsmål anngående bruk?\nDu kan kontakte oss på: surveyplatform.mail@gmail.com"),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Text("Copyright 2021"),
                Icon(
                  Icons.copyright,
                  size: 15,
                ),
                Text("SurveyPlatform")
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Alle bilder og ikoner er sjekket for opphavsrettskrav, og vi har rett til å bruke dem. \nVektorbilder hentet fra vecteezy.com",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
