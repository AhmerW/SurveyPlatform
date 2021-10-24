import 'package:flutter/material.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/widgets/dialogs/gifts/user_gifts_list.dart';

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
            alignment: Alignment.topLeft,
            child: Text("Poeng: ${asn.user.points}"),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
              ),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => UserGiftsListDialog()),
              child: Row(
                children: [
                  Text(
                    "Mine gaver",
                  ),
                  Icon(Icons.card_giftcard),
                ],
              ),
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
                    "Logg ut",
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
