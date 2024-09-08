import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ItemListScreen<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) buildItemTile;
  final Future<void> Function() fetchItems;
  final void Function(T item) onEditItem;
  final Future<void> Function(T item) onDeleteItem;
  final Widget addItemScreen;

  const ItemListScreen({
    super.key,
    required this.title,
    required this.items,
    required this.buildItemTile,
    required this.fetchItems,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.addItemScreen,
  });

  @override
  State<ItemListScreen<T>> createState() => _ItemListScreenState<T>();
}

class _ItemListScreenState<T> extends State<ItemListScreen<T>> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.fetchItems();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(widget.addItemScreen);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return widget.buildItemTile(item);
        },
      ),
    );
  }

  Future<void> _confirmDeleteItem(T item) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text("Delete this item?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result == true) {
      await widget.onDeleteItem(item);
    }
  }
}
