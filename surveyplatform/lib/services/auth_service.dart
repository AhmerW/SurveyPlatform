import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/models/user.dart';

class UserResponse {
  User user;
  String token;

  UserResponse(this.user, this.token);
}

class AuthService {
  static String endpoint = "/auth/";

  Future<String?> getToken(String username, String password) async {
    var response = await sendServerRequest(
      endpoint,
      RequestType.Post,
      data: {"username": username, "password": password},
    );

    if (!response.ok) {
      return null;
    }
    return response.data["token"] ?? null;
  }

  Future<User?> getUser(String token) async {
    ServerResponse userdata = await sendServerRequestAuthenticated(
      "/auth/",
      RequestType.Get,
      token: token,
    );
    Map<String, dynamic> user = userdata.data["user"] ?? {};
    if (user.isNotEmpty) {
      try {
        return User.fromJson(user);
      } catch (error) {
        null;
      }
    }
  }

  Future<UserResponse?> login(String username, String password) async {
    var response = await sendServerRequest(
      endpoint,
      RequestType.Post,
      data: {"username": username, "password": password},
    );

    if (!response.ok) {
      return null;
    }
    String? token = response.data["token"];
    if (token != null) {
      User? user = await getUser(token);

      if (user != null) return UserResponse(user, token);
    }
  }

  Future<ServerResponse> register(
      String username, String password, String email) async {
    return await sendServerRequest(
      "/users/",
      RequestType.Post,
      data: {"username": username, "password": password, "email": email},
    );
  }

  Future<ServerResponse> sendMail(String token) async {
    return await sendServerRequestAuthenticated(
      "/users/verification/",
      RequestType.Get,
      token: token,
    );
  }

  Future<ServerResponse> verify(String token, String code) async {
    return await sendServerRequestAuthenticated(
      "/users/verification/",
      RequestType.Post,
      token: token,
      headers: {"Content-Type": "application/json"},
      data: jsonEncode({"code": code}),
    );
  }

  Future<ServerResponse> forgotPassword({required String value}) async {
    return await sendServerRequest(
      "/users/forgot/",
      RequestType.Get,
      headers: {"Content-Type": "application/json"},
      queryParams: {"value": value},
    );
  }

  Future<ServerResponse> changePassword(
      {required String token, required String password}) async {
    return await sendServerRequest(
      "/users/forgot/",
      RequestType.Post,
      headers: {"Content-Type": "application/json"},
      data: jsonEncode(
        {"password": password, "token": token},
      ),
    );
  }
}
