import 'dart:convert';
import 'dart:io';

import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/webcliente.dart';
import 'package:http/http.dart' as http;

class JournalService {
  String url = WebClient.url;
  http.Client client = WebClient().client;

  static const String resource = "journals/";

  String getUrl(){
    return "$url$resource";
  }

  Future<bool> register(Journal journal, {required String token}) async {
    Uri uri = Uri.parse(getUrl());
    String jsonJournal = json.encode(journal.toMap());
    http.Response response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonJournal,
    );

    if (response.statusCode != 201) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }

  Future<List<Journal>> getAll({required String id, required String token}) async {
    Uri uri = Uri.parse('${url}users/$id/$resource');
    var response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw Exception();
    }

    List<Journal> list = [];
    List<dynamic> listDynamic = json.decode(response.body);

    for (var jsonMap in listDynamic) {
      list.add(Journal.fromMap(jsonMap));
    }
    return list;
  }

  Future<bool> edit(String id, Journal journal, {required String token}) async {
    Uri uri = Uri.parse("${getUrl()}/$id");
    journal.updatedAt = DateTime.now();
    String jsonJournal = json.encode(journal.toMap());
    http.Response response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonJournal,
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }

  Future<bool> delete(String id, {required String token}) async {
    Uri uri = Uri.parse("${getUrl()}/$id");
    http.Response response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      if(json.decode(response.body) == "jwt expired"){
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }
}

class TokenNotValidException implements Exception {}
