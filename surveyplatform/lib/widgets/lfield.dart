import 'package:flutter/material.dart';
import 'package:surveyplatform/views/home.dart';

class LoginField extends StatefulWidget {
  final String content;
  final bool hide;
  final TextEditingController controller;
  final double? size;
  final Function? onSubmit;

  LoginField(this.content, this.controller,
      {this.hide: false, this.size, this.onSubmit});

  @override
  _LoginFieldState createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  bool? _hidden;

  @override
  Widget build(BuildContext context) {
    double _size = MediaQuery.of(context).size.width > 1000 ? 0.4 : 0.8;

    return Container(
        constraints: BoxConstraints(
          maxWidth: widget.size ?? MediaQuery.of(context).size.width * _size,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                enableInteractiveSelection: false,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.content,
                  labelText: widget.content,
                ),
                enableSuggestions: !widget.hide,
                obscureText: _hidden == null ? widget.hide : _hidden!,
                autocorrect: !widget.hide,
                style: TextStyle(
                  color: Colors.white,
                ),
                onSubmitted: (_) {
                  if (widget.onSubmit != null) {
                    widget.onSubmit!();
                  }
                },
              ),
            ),
            widget.hide
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        if (_hidden == null)
                          _hidden = !widget.hide;
                        else
                          _hidden = !_hidden!;
                      });
                    },
                    icon: Icon(
                        (_hidden ?? widget.hide)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: HomePage.primaryColor),
                  )
                : SizedBox.shrink(),
          ],
        ));
  }
}
