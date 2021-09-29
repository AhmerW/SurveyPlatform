import 'package:flutter/material.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/login.dart';

class UserInfoDialog extends StatelessWidget {
  final AuthStateNotifier asn;
  const UserInfoDialog(this.asn);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Bruker info",
      ),
      content: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "Logget inn som "),
                TextSpan(
                  text: "${asn.user.username}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () => asn.logout(context: context),
              child: Row(
                children: [
                  Text(
                    "Logout",
                  ),
                  Icon(Icons.logout),
                ],
              ),
            ),
          )
        ],
      ),
    );
    ;
  }
}
