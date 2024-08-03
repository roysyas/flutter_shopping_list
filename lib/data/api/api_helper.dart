import 'dart:convert';

import 'package:flutter_shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  final String baseUrl =
      'flutter-prep-d5f2a-default-rtdb.asia-southeast1.firebasedatabase.app';
  final headers = {'Content-type': 'application/json'};

  Future<http.Response?> postData(GroceryItem groceryItem) async {
    final url = Uri.https(
      baseUrl,
      'shopping-list.json',
    );

    try {
      final body = groceryItem.toJson();

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      return response;
    } catch (ex) {
      return null;
    }
  }

  Future<List<dynamic>> getData() async {
    final url = Uri.https(
      baseUrl,
      'shopping-list.json',
    );
    List<GroceryItem> groceryItems = [];

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 && response.body != 'null') {
        final Map<String, dynamic> listData = json.decode(response.body);

        for (var item in listData.entries) {
          groceryItems.add(GroceryItem.fromJson(item));
        }
      }
      return groceryItems;
    } catch (ex) {
      List<String> error = [ex.toString()];
      return error;
    }
  }

  Future<http.Response?> deleteData(GroceryItem groceryItem) async {
    final url = Uri.https(
      baseUrl,
      'shopping-list/${groceryItem.id}.json',
    );

    try {
      return await http.delete(url);
    } catch (ex) {
      return null;
    }
  }
}
