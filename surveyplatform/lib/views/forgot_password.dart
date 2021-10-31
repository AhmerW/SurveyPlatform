import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/lfield.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class LoginForgotPassword extends StatefulWidget {
  final String token;
  const LoginForgotPassword(this.token);

  @override
  _LoginForgotPasswordState createState() => _LoginForgotPasswordState();
}

class _LoginForgotPasswordState extends State<LoginForgotPassword> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  String? text;
  bool isError = false;
  bool hasReset = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePage.backgroundColor,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  "Endre ditt passord",
                  style: GoogleFonts.merriweather(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              Divider(
                color: HomePage.primaryColor,
              ),
              text == null
                  ? SizedBox.shrink()
                  : Container(
                      child: Text(
                        text!,
                        style: TextStyle(
                          fontSize: 15,
                          color: isError ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
              LoginField(
                "Passord",
                _controller1,
                hide: true,
              ),
              LoginField(
                "Repeter passord",
                _controller2,
                hide: true,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  child: Text("Endre passord"),
                  onPressed: () {
                    if (_controller1.text.isEmpty ||
                        (_controller1.text != _controller2.text)) {
                      setState(() {
                        text = "Passwords does not match";
                        isError = true;
                      });
                    } else {
                      if (!hasReset)
                        GetIt.I<AuthService>()
                            .changePassword(
                          token: widget.token,
                          password: _controller1.text,
                        )
                            .then((response) {
                          setState(() {
                            hasReset = true;
                            text = response.hasError
                                ? response.error!.message
                                : response.detail;
                            isError = response.hasError;
                          });
                        });
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () => GoRouter.of(context).go("/login"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Til login",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        Icons.login,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
