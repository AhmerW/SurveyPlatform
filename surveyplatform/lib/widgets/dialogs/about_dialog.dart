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
              "SurveyPlatform er en veldig enkel nettside der du kan svare på spørreundersøkelser og få poeng.\nDisse poengene kan veksles for blant annet gavekort.\n\nHar du noen andre spørsmål anngående bruk?\nDu kan kontakte oss på: surveyplatform.mail@gmail.com")
        ],
      ),
    );
  }
}
