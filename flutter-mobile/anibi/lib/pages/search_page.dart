import 'package:flutter/material.dart';
import 'package:anibi/modules/gogoanime_service.dart';
import 'anime_details_page.dart'; // Import the Anime Details Page

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, String>> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';

  void searchAnime(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = 'Please enter a search term';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Call the correct search method
      var results = await GogoanimeService.searchAnimeWithLinks(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load anime. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Anime'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for anime...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchAnime(value);
              },
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var anime = searchResults[index];
                return ListTile(
                  title: Text(anime['title']!),
                  onTap: () {
                    // Navigate to Anime Details Page with the anime URL
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimeDetailsPage(animeUrl: anime['url']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
