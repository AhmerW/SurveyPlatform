import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/captcha_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class CaptchaDialog extends StatefulWidget {
  const CaptchaDialog({Key? key}) : super(key: key);

  @override
  _CaptchaDialogState createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Captcha"),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Consumer<CaptchaState>(
            builder: (context, cs, _) {
              return FutureBuilder(
                future: cs.getCaptcha(),
                builder: (context, snapshot) {
                  Image? image =
                      (snapshot.data != null ? (snapshot.data as Image) : null);
                  print(snapshot.data);
                  if (image != null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        image,
                        Container(
                          padding: EdgeInsets.all(50),
                          child: SingleValueField(
                            "",
                            InputFieldState(
                              hintText: "answer",
                              fieldWidth: 0.3,
                              textColor: Colors.black,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
