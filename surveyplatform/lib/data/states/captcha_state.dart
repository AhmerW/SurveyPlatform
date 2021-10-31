import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';

class CaptchaState extends ChangeNotifier {
  static final String path = "/captchas/";
  String? _captcha_id;
  String? _solve_token;

  String? get captcha_id => _captcha_id;
  String? get solve_token => _solve_token;
  bool get hasSolveToken => _solve_token != null;

  Image? _image;

  void reset() {
    _image = null;
    _captcha_id = null;
  }

  void usedSolveToken() {
    _solve_token = null;
    _image = null;
    _captcha_id = null;
    notifyListeners();
  }

  Future<Image?> getCaptcha() async {
    if (_image != null) return _image;
    ServerResponse response = await sendServerRequest(path, RequestType.Get);

    if (response.body_bytes == null) {
      return null;
    }
    if (response.headers.containsKey("captcha-id")) {
      if (_captcha_id == null) _captcha_id = response.headers["captcha-id"];
    }

    _image = Image.memory(response.body_bytes!);
    return _image;
  }

  Future<ServerResponse> solveCaptcha(int value) async {
    ServerResponse response = await sendServerRequest(
      path,
      RequestType.Post,
      data: jsonEncode({"captcha_id": captcha_id, "value": value}),
      headers: {"Content-Type": "application/json"},
    );
    if (response.ok) {
      _image = null;
      _captcha_id = null;
      _solve_token = response.data["solve_token"];
    }

    return response;
  }
}
