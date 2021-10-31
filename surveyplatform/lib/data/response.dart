import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

bool isNullOrNMap(dynamic value) {
  return value == null || (!(value is Map));
}

class StatusState {
  bool empty;
  bool ok;
  String detail;

  StatusState(this.ok, {required this.empty, required this.detail});
}

class Error {
  final String message;

  Error(this.message);
}

class ServerResponse {
  final bool ok;
  final String detail;
  final Map<String, dynamic> data;
  final Map<String, dynamic> headers;
  final Uint8List? body_bytes;
  final Error? error;
  final int statusCode;

  bool get hasError => error != null;
  bool get hasDetails => detail.isNotEmpty;

  ServerResponse(
    this.data, {
    required this.ok,
    required this.statusCode,
    this.headers: const {},
    this.body_bytes,
    this.detail: "",
    this.error,
  });

  factory ServerResponse.parse(Map<dynamic, dynamic> json, int statusCode) {
    var data = json['data'];
    var error = json['error'];
    var detail = json['detail'] ?? "";
    int status = statusCode;

    if (isNullOrNMap(data)) {
      data = {};
    }
    if (isNullOrNMap(error)) {
      error = {};
    }
    if (!(detail is String)) {
      detail = "";
    }
    if (!(status is int)) {
      status = 200;
    }

    return ServerResponse(
      data as Map<String, dynamic>,
      detail: detail,
      error: error["msg"] == null ? null : Error(error["msg"] ?? ""),
      statusCode: status,
      ok: json["ok"] ?? false,
    );
  }

  factory ServerResponse.fromResponse(http.Response response) {
    try {
      Map<dynamic, dynamic> json = jsonDecode(response.body);
    } catch (error) {
      return ServerResponse(
        {},
        ok: false,
        statusCode: 400,
        error: Error("Failed ${response.body}"),
        body_bytes: response.bodyBytes,
        headers: response.headers,
      );
    }
    Map<dynamic, dynamic> json = jsonDecode(response.body);

    return ServerResponse.parse(json, response.statusCode);
  }
}
