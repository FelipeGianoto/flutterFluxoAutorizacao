import 'dart:convert';
import 'dart:io';

import 'package:flutter_webapi_first_course/services/webcliente.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String url = WebClient.url;
  http.Client client = WebClient().client;

  Future<bool> login({required String email, required String password}) async {
    Uri uri = Uri.parse('${url}login');
    http.Response response = await client.post(
      uri,
      body: {
        'email': email,
        'password': password
      }
    );
    if(response.statusCode != 200){
      String content = json.decode(response.body);
      switch(content){
        case "Cannot find user":
          throw UserNotFindException();
      }
      throw HttpException(response.body);
    }
    saveUserInfos(response.body);
    return true;
  }


  Future<bool> register({required String email, required String password}) async {
    Uri uri = Uri.parse('${url}register');
    http.Response response = await client.post(
        uri,
        body: {
          'email': email,
          'password': password
        }
    );
    if(response.statusCode != 201){
      throw HttpException(response.body);
    }

    saveUserInfos(response.body);

    return true;
  }

  saveUserInfos(String body) async{
    Map<String, dynamic> map = json.decode(body);

    String token = map['accessToken'];
    String email = map['user']['email'];
    int id = map['user']['id'];

    //print("$token\n$email\n$id");

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('accessToken', token);
    preferences.setString('email', email);
    preferences.setInt('id', id);
  }
}

class UserNotFindException implements Exception{}
