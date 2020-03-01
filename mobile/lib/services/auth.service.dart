import 'dart:convert';

import '../models/Users.model.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class AuthService {
  static Future<UserModel> authenticateToken({Map authBody, Map user}) async {
    http.Response response;
    if (user == null) {
      response = await http.post(
        '$hostURL/user/login/social', 
        headers: {"Content-type": "application/json"}, 
        body: json.encode(authBody)
      );
      if (response.statusCode == 200) user = json.decode(response.body);
    }
  
    if (user != null) {
      // If server returns an OK response, parse the JSON.
      await UserModel.t.insertUser(UserModel.fromJson(user));
      return UserModel.fromJson(user);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<bool> validateToken() async {
    List<UserModel> user = await UserModel.t.fetchCurrentUser();
    if (user.length > 0) {
      String data = json.encode({"token": user[0].token, "authProvider": user[0].authProvider, "email": user[0].email});
      final response = await http.post('$hostURL/user/validate/token', headers: {"Content-type": "application/json"}, body: data);
      var res = response.statusCode == 200;
      if (!res) await UserModel.t.dropTable();
      return res;
    }
    return false;
  }
}
