import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/user.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/views/hub.dart';
import 'package:surveyplatform/views/login.dart';

const int guestID = 0;

User getGuest() => User(guestID, "gjest", verified: true);

enum AuthLoginState { None, Attempting, EmptyData, Failed, Success }

String getToken(BuildContext context) =>
    Provider.of<AuthStateNotifier>(context, listen: false).token;

class AuthStateNotifier extends ChangeNotifier {
  User _user = getGuest();
  bool _session = false;
  String _token = "";
  AuthLoginState _state = AuthLoginState.None;

  User get user => _user;
  bool get isGuest => _user.uid == guestID;
  bool get isUser => !isGuest;
  String get token => _token;
  AuthLoginState get state => _state;

  void setState(AuthLoginState state) {
    this._state = state;
    notifyListeners();
  }

  void _baseUpdateAuth() {
    this._session = true;
    notifyListeners();
  }

  void updateAuthState(User user, String token) {
    this._user = user;
    this._token = token;
    _baseUpdateAuth();
  }

  void updateAuthStateGuest() {
    this._user = getGuest();
    _baseUpdateAuth();
  }

  void logout({BuildContext? context}) {
    updateAuthStateGuest();
    _token = "";
    this._session = false;
    setState(AuthLoginState.None);
    if (context != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  void login(BuildContext context, String username, String password) async {
    UserResponse? response =
        await GetIt.I<AuthService>().login(username, password);

    if (response == null) {
      setState(AuthLoginState.Failed);
    } else {
      User user = response.user;

      updateAuthState(user, response.token);
      this._state = AuthLoginState.None;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => HubPage()));
    }
  }

  Future<ServerResponse> register(BuildContext context, String username,
      String password, String email) async {
    var response =
        await locator<AuthService>().register(username, password, email);
    if (response.ok) {
      String? token = await locator<AuthService>().getToken(username, password);
      if (token != null) {
        response.data["token"] = token;
      }
    }
    return response;
  }

  Future<User?> getUser(String token) async {
    return await locator<AuthService>().getUser(token);
  }

  Future<ServerResponse> sendEmail(String token) async {
    return await locator<AuthService>().sendMail(token);
  }

  Future<ServerResponse> verify(String token, String code) async {
    return await locator<AuthService>().verify(token, code);
  }
}
