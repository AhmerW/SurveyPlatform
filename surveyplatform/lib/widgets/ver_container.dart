import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/models/user.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/views/hub.dart';
import 'package:surveyplatform/widgets/lfield.dart';

class VerContainer extends StatefulWidget {
  final String token;
  const VerContainer(this.token);

  @override
  _VerContainerState createState() => _VerContainerState();
}

class _VerContainerState extends State<VerContainer> {
  final StatusState statusState = StatusState(
    true,
    empty: true,
    detail: "",
  );

  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              : Container(
                  child: Text(
                    statusState.detail,
                    style: TextStyle(
                        color: statusState.ok ? Colors.green : Colors.red),
                  ),
                ),
          Container(
            height: 20,
          ),
          LoginField("Verifiseringskode", _controller),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            width: MediaQuery.of(context).size.width * 0.3,
            child: ElevatedButton(
              onPressed: () {
                String code = _controller.text;
                if (code.isEmpty) {
                  setState(() {
                    statusState.empty = false;
                    statusState.ok = false;
                    statusState.detail =
                        "Vennligst skriv inn koden du har fått på mail.";
                  });
                } else {
                  AuthStateNotifier asn = Provider.of<AuthStateNotifier>(
                    context,
                    listen: false,
                  );
                  asn.verify(widget.token, code).then(
                    (response) {
                      print("ROK: ${response.ok}");
                      print("RER: ${response.hasError}");
                      if (response.ok) {
                        asn.getUser(widget.token).then((user) {
                          print("tor $user");
                          if (user != null) {
                            asn.updateAuthState(user, widget.token);
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => HubPage()));
                          }
                        });
                      } else if (response.hasError) {
                        setState(() {
                          statusState.empty = false;
                          statusState.ok = false;
                          statusState.detail = response.error!.message;
                        });
                      }
                    },
                  );
                }
              },
              child: Text("Fortsett"),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: OutlinedButton(
              onPressed: () {
                Provider.of<AuthStateNotifier>(context, listen: false)
                    .sendEmail(widget.token)
                    .then((response) {
                  setState(
                    () {
                      statusState.ok = response.ok;
                      statusState.detail = response.detail;
                    },
                  );
                });
              },
              child: Text("Send kode på mail"),
            ),
          )
        ],
      ),
    );
  }
}
