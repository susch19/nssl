import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nssl/helper/iterable_extensions.dart';
import 'package:flutter_riverpod/legacy.dart';

class TestClass {
  int test;
  String? o;

  TestClass(this.test, this.o);

  TestClass.intOnly(this.test);
}

final shoppingItemsProvider = StateProvider<List<ShoppingItem>>(((ref) => []));

final shoppingItemsPerListProvider = Provider.family<List<ShoppingItem>, int>((
  ref,
  listId,
) {
  var items = ref.watch(shoppingItemsProvider);
  return items.where((element) => element.listId == listId).toList();
});

final shoppingItemProvider = Provider.family<ShoppingItem?, int>((ref, itemId) {
  var items = ref.watch(shoppingItemsProvider);
  return items.firstOrNull((element) => element.id == itemId);
});

@immutable
class ShoppingItem {
  final int amount;
  final String name;
  final int id;
  final DateTime? created;
  final DateTime? changed;
  final bool crossedOut;
  final int sortOrder;
  final int listId;

  int get sortWithOffset => sortOrder + (crossedOut ? 0xFFFFFFFF : 0);
  String get cleanedName => name.replaceFirst('0.0', '').replaceAll('null', '');

  const ShoppingItem(
    this.name,
    this.listId,
    this.sortOrder, {
    this.amount = 1,
    this.id = -1,
    this.crossedOut = false,
    this.created,
    this.changed,
  });

  @override
  String toString() {
    return name + "\u{1F}" + amount.toString() + "\u{1F}" + id.toString();
  }

  /// Creates a copy, with only including [amount] and [name]
  ShoppingItem copy() {
    return ShoppingItem(name, listId, sortOrder, amount: amount);
  }

  /// Creates an identical clone, where all fields are the same as
  /// the parent item
  ShoppingItem clone() {
    return ShoppingItem(
      name,
      listId,
      sortOrder,
      amount: amount,
      id: id,
      changed: changed,
      created: created,
      crossedOut: crossedOut,
    );
  }

  ShoppingItem cloneWith({
    String? newName,
    int? newListId,
    int? newAmount,
    int? newId,
    DateTime? newCreated,
    DateTime? newChanged,
    bool? newCrossedOut,
    int? newSortOrder,
  }) {
    return ShoppingItem(
      newName ?? name,
      newListId ?? listId,
      newSortOrder ?? sortOrder,
      amount: newAmount ?? amount,
      id: newId ?? id,
      changed: newChanged ?? changed,
      created: newCreated ?? created,
      crossedOut: newCrossedOut ?? crossedOut,
    );
  }

  // ShoppingItem.fromJson(String s) :  name = s;

  Map<String, dynamic> toJson() => {'name': name};

  @override
  bool operator ==(final Object other) =>
      other is ShoppingItem &&
      other.name == name &&
      other.amount == amount &&
      other.id == id &&
      other.crossedOut == crossedOut &&
      other.sortOrder == sortOrder &&
      other.listId == listId;

  @override
  int get hashCode =>
      Object.hash(name, amount, id, crossedOut, sortOrder, listId);

  void exchange(ShoppingItem newItem, WidgetRef ref) {
    var items = ref.watch(shoppingItemsProvider.notifier);
    var newState = items.state.toList();
    newState.remove(this);
    newState.add(newItem);
    items.state = newState;
  }
}
