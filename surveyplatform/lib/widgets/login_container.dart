import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/hub.dart';
import 'package:surveyplatform/views/register.dart';
import 'package:surveyplatform/widgets/dialogs/forgot_password_dialog.dart';
import 'package:surveyplatform/widgets/lfield.dart';

class LoginContainer extends StatefulWidget {
  const LoginContainer({Key? key}) : super(key: key);

  @override
  _LoginContainerState createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  TextEditingController _usernameController =
      TextEditingController.fromValue(TextEditingValue(text: ""));
  TextEditingController _passwdController =
      TextEditingController.fromValue(TextEditingValue(text: ""));

  void attemptLogin() {
    String username = _usernameController.text;
    String password = _passwdController.text;

    var asn = Provider.of<AuthStateNotifier>(context, listen: false);
    if (username.isEmpty || password.isEmpty) {
      asn.setState(AuthLoginState.EmptyData);
    } else {
      asn.setState(AuthLoginState.Attempting);
      asn.login(context, username, password);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        Provider.of<AuthStateNotifier>(context, listen: false).setState(
          AuthLoginState.None,
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
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
          /* Container(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.home,
                  color: HomePage.primaryColor,
                )),
          ), */
          Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: Divider(
              color: HomePage.primaryColor,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Text(
              "SurveyPlatform",
              style: TextStyle(color: HomePage.primaryColor),
            ),
          ),
          Container(
            child: Consumer<AuthStateNotifier>(
              builder: (context, asn, _) {
                switch (asn.state) {
                  case AuthLoginState.Attempting:
                    return CircularProgressIndicator();

                  case AuthLoginState.EmptyData:
                    return Text(
                      "Fyll inn begge feltene før du prøver å logge inn",
                      style: TextStyle(color: Colors.red),
                    );

                  case AuthLoginState.Failed:
                    return Text(
                      "Feil brukernavn eller passsword",
                      style: TextStyle(color: Colors.red),
                    );

                  case AuthLoginState.Success:
                    return Text("Logger inn");

                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ),
          // LOGIN FIELDS
          LoginField(
            "brukernavn",
            _usernameController,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 5,
            ),
          ),
          LoginField(
            "passord",
            _passwdController,
            hide: true,
            onSubmit: attemptLogin,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            height: 80,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: HomePage.primaryColor),
              onPressed: attemptLogin,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Logg inn"), Icon(Icons.login)],
              ),
            ),
          ),
          // OTHER FIELDS
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 3,
            ),
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => LoginForgotPasswordDialog(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Glemt passord?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: InkWell(
              onTap: () {
                Provider.of<AuthStateNotifier>(context, listen: false)
                    .updateAuthStateGuest();

                GoRouter.of(context).push("/hub");
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Logg inn som gjest",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.lock_open,
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => RegisterPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Har ikke konto?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.account_circle_outlined,
                  )
                ],
              ),
            ),
          ),

          // END DIVIDER
          Divider(
            color: HomePage.primaryColor,
          )
        ],
      ),
    );
  }
}
