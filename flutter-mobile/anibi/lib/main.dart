import 'package:flutter/material.dart';
// import 'package:anibi/pages/home_page.dart';
import 'package:anibi/pages/search_page.dart';
// import 'package:anibi/pages/history_page.dart';
// import 'package:anibi/pages/favorite_page.dart';
import 'package:anibi/pages/anime_details_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Streamer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SearchPage(),
        '/search': (context) => SearchPage(), // Routing to the Search Page
        // '/history': (context) => HistoryPage(),
        // '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}
