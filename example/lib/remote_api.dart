import 'dart:convert';
import 'dart:io';

import 'package:breaking_bapp/character_summary.dart';
import 'package:http/http.dart' as http;

// ignore: avoid_classes_with_only_static_members
class RemoteApi {
  static Future<List<CharacterSummary>> getCharacterList(
    int offset,
    int limit, {
    String? searchTerm,
  }) async =>
      http
          .get(
            _ApiUrlBuilder.characterList(offset, limit, searchTerm: searchTerm),
          )
          .mapFromResponse<List<CharacterSummary>, List<dynamic>>(
            (jsonArray) => _parseItemListFromJsonArray(
              jsonArray,
              (jsonObject) => CharacterSummary.fromJson(jsonObject),
            ),
          );

  static List<T> _parseItemListFromJsonArray<T>(
    List<dynamic> jsonArray,
    T Function(dynamic object) mapper,
  ) =>
      jsonArray.map(mapper).toList();
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}

// ignore: avoid_classes_with_only_static_members
class _ApiUrlBuilder {
  static const _baseUrl = 'https://api.thecatapi.com/v1/images/search';
  static const _apiKey = 'live_oUo7bpYXiLUyXgVyacz9IjDqQ5E8Z8uSiU1qKNI4Gs6SQN8zX6PFcbBsJjDiTEcS';

  static Uri characterList(
    int offset,
    int limit, {
    String? searchTerm,
  }) =>
      Uri.parse(
        '$_baseUrl?'
        'api_key=$_apiKey'
        '&page=$offset'
        '&limit=$limit',
      );
}

extension on Future<http.Response> {
  Future<R> mapFromResponse<R, T>(R Function(T) jsonParser) async {
    try {
      final response = await this;
      if (response.statusCode == 200) {
        return jsonParser(jsonDecode(response.body));
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}
