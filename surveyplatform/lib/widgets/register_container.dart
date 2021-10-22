import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/views/verification.dart';
import 'package:surveyplatform/widgets/lfield.dart';

class RegisterContainer extends StatefulWidget {
  const RegisterContainer({Key? key}) : super(key: key);

  @override
  _RegisterContainerState createState() => _RegisterContainerState();
}

class _RegisterContainerState extends State<RegisterContainer> {
  StatusState statusState = StatusState(
    true,
    empty: true,
    detail: "",
  );

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwdController = TextEditingController();
  TextEditingController _passwd2Controller = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _passwd2Controller.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 30,
      ),
      constraints: BoxConstraints(
        maxHeight: 500,
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      child: Column(
        children: [
          statusState.empty
              ? SizedBox.shrink()
              : Text(
                  statusState.detail,
                  style: TextStyle(
                    color: statusState.ok ? Colors.green : Colors.red,
                  ),
                ),
          Container(
            height: 50,
          ),
          LoginField("brukernavn", _usernameController),
          LoginField("email", _emailController),
          Container(
            height: 25,
          ),
          LoginField(
            "passord",
            _passwdController,
            hide: true,
          ),
          LoginField(
            "repeter passord",
            _passwd2Controller,
            hide: true,
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            height: 70,
            width: MediaQuery.of(context).size.width * 0.15,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: HomePage.primaryColor),
                onPressed: () {
                  String email = _emailController.text;
                  String username = _usernameController.text;
                  String password = _passwdController.text;
                  String password2 = _passwd2Controller.text;
                  bool _success = false;

                  setState(() {
                    statusState.ok = false;
                    statusState.empty = false;
                    if (username.isEmpty) {
                      statusState.detail =
                          "Vennligst fyll ut brukernavn feltet.";
                    } else if (email.isEmpty) {
                      statusState.detail =
                          "Vennligst skriv inn epost adressen din.\nAdressen blir bare brukt for verifisering.";
                    } else if (password.isEmpty || password2.isEmpty) {
                      statusState.detail =
                          "Vennligst skriv inn passordet ditt i begge felt.";
                    } else if (password != password2) {
                      statusState.detail = "Passordene stemmer ikke.";
                    } else {
                      _success = true;
                      statusState.detail = "Vent...";
                    }
                  });
                  if (_success)
                    Provider.of<AuthStateNotifier>(context, listen: false)
                        .register(context, username, password, email)
                        .then((response) {
                      if (!response.ok && response.hasError) {
                        setState(() {
                          statusState.detail = response.error!.message;
                        });
                      } else {
                        String? token = response.data["token"];
                        print(token);
                        if (token != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => VerificationPage(token)));
                        }
                      }
                    });
                },
                child: Text("Fortsett")),
          ),
          Divider(),
          Container(
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Logg inn istedenfor",
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
    );
  }
}
