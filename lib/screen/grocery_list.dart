import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/data/api/api_helper.dart';
import 'package:flutter_shopping_list/screen/new_item.dart';
import 'package:flutter_shopping_list/models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  final _apiHelper = ApiHelper();
  var _isLoading = true;
  List<String> _error = [];

  @override
  void initState() {
    super.initState();

    _loadItem();
  }

  void _loadItem() async {
    var data = await _apiHelper.getData();
    setState(() {
      if (data is List<String>) {
        _error = data;
      } else {
        _groceryItems = data as List<GroceryItem>;
      }
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);

    setState(() {
      _groceryItems.remove(groceryItem);
    });
    final res = await _apiHelper.deleteData(groceryItem);

    if (!context.mounted) {
      return;
    }

    if (res == null || res.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('delete failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'empty groceries',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'try add grocery (+)',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (_error.isNotEmpty) {
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error[0],
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        );
      } else {
        if (_groceryItems.isNotEmpty) {
          content = ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(_groceryItems[index]);
              },
              key: ValueKey(_groceryItems[index].id),
              child: ListTile(
                title: Text(_groceryItems[index].name!),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItems[index].category?.color,
                ),
                trailing: Text(_groceryItems[index].quantity.toString()),
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
