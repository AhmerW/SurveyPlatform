import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/converters.dart';
import 'package:surveyplatform/data/states/captcha_state.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class CaptchaDialog extends StatefulWidget {
  final Function? onSubmit;
  const CaptchaDialog({this.onSubmit});

  @override
  _CaptchaDialogState createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  String? text;
  bool solving = false;

  void solve(int value) {
    if (!solving) {
      setState(() {
        solving = true;
      });
      CaptchaState captchaState = Provider.of<CaptchaState>(
        context,
        listen: false,
      );

      captchaState.solveCaptcha(value).then(
        (response) {
          if (response.hasError) {
            setState(() {
              solving = false;

              text = response.error!.message;
            });
          } else {
            if (widget.onSubmit != null) widget.onSubmit!();
            Navigator.of(context).pop();
          }
        },
      );
    }
  }

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

                  if (image != null && !solving) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                solving = false;
                                cs.reset();
                              });
                            },
                          ),
                        ),
                        image,
                        text == null
                            ? SizedBox.shrink()
                            : Container(
                                alignment: Alignment.center,
                                child: Text(
                                  text!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                        Container(
                          padding: EdgeInsets.all(50),
                          child: SingleValueField(
                            "",
                            InputFieldState(
                              hintText: "answer",
                              fieldWidth: 0.3,
                              textColor: Colors.black,
                            ),
                            onValidate: (value) => validateInteger(value),
                            onSubmit: (value) => solve(int.parse(value)),
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
