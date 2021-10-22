import 'dart:convert';
import 'dart:io';

import 'package:surveyplatform/data/const.dart';
import 'package:surveyplatform/data/response.dart';

import 'package:http/http.dart' as http;
import 'package:surveyplatform/data/states/auth_state.dart';

enum RequestType { Post, Get, Delete }
enum RequestProto { Http, Https }

Future<ServerResponse> sendRequest(
  RequestType requestType,
  String host, {
  String path: "",
  String scheme: "http",
  int? port,
  Map<String, dynamic>? queryParams,
  Map<String, String>? headers,
  Object? data,
}) async {
  final client = http.Client();

  Uri url = Uri(
    scheme: scheme,
    host: host,
    path: path,
    queryParameters: queryParams,
    port: port,
  );
  print(url);

  late http.Response response;
  if (requestType == RequestType.Post) {
    response = await client.post(url, body: data, headers: headers);
  } else if (requestType == RequestType.Delete) {
    response = await client.delete(url, body: data, headers: headers);
  } else {
    response = await client.get(url, headers: headers);
  }

  if (response.statusCode == 307) {
    return ServerResponse.fromResponse(
      http.Response(
        '{"ok": false, "error": {"msg": "not found"}, "detail": "error", "data": {}}',
        404,
      ),
    );
  }
  return ServerResponse.fromResponse(response);
}

Future<ServerResponse> sendServerRequest(
  String path,
  RequestType requestType, {
  Map<String, String>? queryParams,
  Map<String, String>? headers,
  Object? data,
}) async {
  return await sendRequest(requestType, serverUrl,
      path: "$basePath$path",
      scheme: serverScheme,
      queryParams: queryParams,
      headers: headers,
      data: data,
      port: serverPort);
}

Future<ServerResponse> sendServerRequestAuthenticated(
  String path,
  RequestType requestType, {
  required String token,
  Map<String, String>? queryParams,
  Map<String, String>? headers,
  Object? data,
}) async {
  Map<String, String> cheaders = Map.from(headers ?? {});
  cheaders["Authorization"] = "bearer ${token}";

  return await sendRequest(
    requestType,
    serverUrl,
    path: "$basePath$path",
    scheme: serverScheme,
    queryParams: queryParams,
    headers: cheaders,
    port: serverPort,
    data: data,
  );
}
