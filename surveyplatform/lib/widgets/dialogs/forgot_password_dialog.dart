import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class LoginForgotPasswordDialog extends StatefulWidget {
  const LoginForgotPasswordDialog({Key? key}) : super(key: key);

  @override
  _LoginForgotPasswordDialogState createState() =>
      _LoginForgotPasswordDialogState();
}

class _LoginForgotPasswordDialogState extends State<LoginForgotPasswordDialog> {
  bool done = false;
  String text = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Nullstill ditt passord",
          style: TextStyle(
            color: Colors.white,
          )),
      backgroundColor: HomePage.backgroundColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          children: [
            !done
                ? SizedBox.shrink()
                : Container(
                    alignment: Alignment.center,
                    child: Text(
                        "En email har blitt sent til din konto hvis den oppgitte email og/eller brukernavn eksisterer i våre systemer.",
                        style: TextStyle(color: Colors.white)),
                  ),
            SingleValueField(
              "",
              InputFieldState(
                  hintText: "Brukernavn eller email", fieldWidth: 0.3),
              onSubmit: (s) => text = s,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  if (text.isNotEmpty) {
                    GetIt.I<AuthService>().forgotPassword(
                      value: text,
                    );
                    setState(() {
                      done = true;
                    });
                  }
                },
                child: Text("Send email"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
