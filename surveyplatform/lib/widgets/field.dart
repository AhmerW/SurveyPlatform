import 'package:flutter/material.dart';

class InputFieldState extends ChangeNotifier {
  final TextEditingController _controller = TextEditingController();

  String hintText;
  double fieldWidth;

  final TextInputType inputType;

  InputFieldState({
    this.inputType: TextInputType.text,
    this.hintText: "",
    this.fieldWidth: 0.8,
  });

  TextEditingController get controller => _controller;
  String get text => _controller.text;

  void setHintText(String text) {
    hintText = text;
    notifyListeners();
  }
}

class InputField extends StatefulWidget {
  final InputFieldState _state;
  final void Function(String)? onSubmit;

  InputField(this._state, {this.onSubmit});

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widget._state.fieldWidth,
      child: TextField(
        onChanged: widget.onSubmit,
        controller: widget._state._controller,
        keyboardType: widget._state.inputType,
        decoration: InputDecoration(
          hintText: widget._state.hintText,
        ),
      ),
    );
  }
}
