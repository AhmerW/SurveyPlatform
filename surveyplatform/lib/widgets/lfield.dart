import 'package:flutter/material.dart';

class LoginField extends StatefulWidget {
  final String content;
  final bool hide;
  final TextEditingController controller;
  final double? size;

  LoginField(this.content, this.controller, {this.hide: false, this.size});

  @override
  _LoginFieldState createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  @override
  Widget build(BuildContext context) {
    double _size = MediaQuery.of(context).size.width > 1000 ? 0.4 : 0.8;
    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.size ?? MediaQuery.of(context).size.width * _size,
      ),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.content,
          labelText: widget.content,
        ),
        enableSuggestions: !widget.hide,
        obscureText: widget.hide,
        autocorrect: !widget.hide,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
