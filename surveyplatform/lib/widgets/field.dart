import 'package:flutter/material.dart';

typedef void StringCallback(String);

class InputFieldState {
  final TextEditingController _controller = TextEditingController();

  String hintText;
  double fieldWidth;

  final TextInputType inputType;
  final InputDecoration? customDecoration;
  final int? maxLength;
  final Color? textColor;

  InputFieldState({
    this.inputType: TextInputType.text,
    this.hintText: "",
    this.fieldWidth: 0.8,
    this.customDecoration,
    this.textColor,
    this.maxLength,
  });

  TextEditingController get controller => _controller;
  String get text => _controller.text;
}

class InputField extends StatefulWidget {
  FocusNode _focusNode = FocusNode();

  final InputFieldState _state;
  final void Function(String)? onSubmit;
  final StringCallback? onChange, onChangeCurrentText;

  InputField(this._state,
      {this.onSubmit, this.onChange, this.onChangeCurrentText});

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  FocusNode _focusNode = FocusNode();

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (widget.onSubmit != null) widget.onSubmit!(widget._state.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget._state._controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widget._state.fieldWidth,
      child: TextField(
        focusNode: _focusNode,
        onChanged: widget.onChange,
        onSubmitted: widget.onSubmit,
        controller: widget._state._controller,
        keyboardType: widget._state.inputType,
        maxLength: widget._state.maxLength,
        decoration: widget._state.customDecoration ??
            InputDecoration(
                hintText: widget._state.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey,
                )),
        style: TextStyle(
          color: widget._state.textColor ?? Colors.white,
        ),
      ),
    );
  }
}
