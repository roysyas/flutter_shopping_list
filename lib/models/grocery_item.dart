import 'dart:convert';

import 'package:flutter_shopping_list/data/categories.dart';
import 'package:flutter_shopping_list/models/category.dart';

class GroceryItem {
  GroceryItem({
    this.id,
    this.name,
    this.quantity,
    this.category,
  });

  String? id;
  String? name;
  int? quantity;
  Category? category;

  GroceryItem.fromJson(MapEntry<String, dynamic> json) {
    final cat = categories.entries
        .firstWhere((item) => item.value.title == json.value['category'])
        .value;
    category = cat;
    name = json.value['name'];
    quantity = json.value['quantity'];
    id = json.key;
  }

  String toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category!.title;
    data['name'] = name;
    data['quantity'] = quantity;
    return json.encode(data);
  }
}
