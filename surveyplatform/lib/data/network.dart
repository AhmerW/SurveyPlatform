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
  if (!path.endsWith("/")) {
    path = "$path/";
  }
  Uri url = Uri(
    scheme: scheme,
    host: host,
    path: path,
    queryParameters: queryParams,
    port: port,
  );

  late var response;
  if (requestType == RequestType.Post) {
    print("DATA: $data AND HEADERS $headers");
    response = await client.post(url, body: data, headers: headers);
    print("post response");
  } else if (requestType == RequestType.Delete) {
    response = await client.delete(url, body: data, headers: headers);
  } else {
    response = await client.get(url, headers: headers);
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
      path: path,
      port: serverPort,
      scheme: serverScheme,
      queryParams: queryParams,
      headers: headers,
      data: data);
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

  return await sendRequest(requestType, serverUrl,
      path: path,
      port: serverPort,
      scheme: serverScheme,
      queryParams: queryParams,
      headers: cheaders,
      data: data);
}
