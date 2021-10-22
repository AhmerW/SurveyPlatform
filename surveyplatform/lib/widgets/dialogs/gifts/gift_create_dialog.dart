import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/converters.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class CreateGiftDialog extends StatefulWidget {
  @override
  _CreateGiftDialogState createState() => _CreateGiftDialogState();
}

class _CreateGiftDialogState extends State<CreateGiftDialog> {
  String? error;
  String _title = "";
  String _description = "";
  int _price = 0;

  void create() {
    GiftStateNotifier gsn = Provider.of<GiftStateNotifier>(
      context,
      listen: false,
    );
    gsn
        .createGift(
      title: _title,
      description: _description,
      price: _price,
      token: getToken(context),
    )
        .then(
      (response) {
        if (response.ok) {
          Navigator.pop(context);
        } else if (response.hasError) {
          setState(() {
            error = response.error!.message;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.3,
      child: AlertDialog(
        backgroundColor: HomePage.backgroundColor,
        title: Text("Legg til gave"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            error == null
                ? SizedBox.shrink()
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
            SingleValueField(
              "",
              InputFieldState(
                fieldWidth: 0.5,
                hintText: "tittel",
                maxLength: 100,
              ),
              onSubmit: (s) => _title = s,
            ),
            SingleValueField(
              "",
              InputFieldState(
                fieldWidth: 0.5,
                hintText: "beskrivelse",
                maxLength: 100,
              ),
              onSubmit: (s) => _description = s,
            ),
            SingleValueField(
              "",
              InputFieldState(
                fieldWidth: 0.5,
                hintText: "pris",
                maxLength: 100,
              ),
              onValidate: (s) {
                int? val = int.tryParse(s);
                if (val == null) return false;
                return val > 0;
              },
              onSubmit: (s) => _price = int.parse(s),
            ),
            ElevatedButton(
              onPressed: create,
              child: Text("Legg til"),
            )
          ],
        ),
      ),
    );
  }
}
