import 'package:flutter/cupertino.dart';

@immutable
class Product extends Object {
  final int id;
  final String name;

  Product({required this.id, required this.name});

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Product && other.name == name && other.id == id;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() {
    return '$name';
  }
}