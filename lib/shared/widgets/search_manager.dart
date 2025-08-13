import 'package:flutter/material.dart';
import '../../features/search/screens/search_screen.dart';

class SearchManager {
  static void showSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }
}
