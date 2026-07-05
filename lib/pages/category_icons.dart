import 'package:flutter/material.dart';

class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> options = {
    'category': Icons.category,
    'work': Icons.work,
    'wallet': Icons.account_balance_wallet,
    'laptop': Icons.computer,
    'store': Icons.store,
    'restaurant': Icons.restaurant,
    'car': Icons.directions_car,
    'receipt': Icons.receipt_long,
    'movie': Icons.movie,
    'shopping_bag': Icons.shopping_bag,
    'health': Icons.local_hospital,
    'school': Icons.school,
    'trending_up': Icons.trending_up,
    'home': Icons.home,
    'pets': Icons.pets,
    'sports': Icons.sports_soccer,
    'flight': Icons.flight,
    'gift': Icons.card_giftcard,
    'coffee': Icons.local_cafe,
    'phone': Icons.phone_android,
    'book': Icons.menu_book,
    'music': Icons.music_note,
    'fitness': Icons.fitness_center,
    'savings': Icons.savings,
  };

  static IconData resolve(String? key) => options[key] ?? Icons.category;
}