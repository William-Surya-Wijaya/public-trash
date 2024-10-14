import 'package:flutter/material.dart';
import 'package:anibi/modules/gogoanime_service.dart';
import 'watch_page.dart';

class AnimeDetailsPage extends StatefulWidget {
  final String animeUrl;

  AnimeDetailsPage({required this.animeUrl});

  @override
  _AnimeDetailsPageState createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  String title = '';
  String description = '';
  String genre = '';
  String coverImage = '';
  List<Map<String, String>> episodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnimeDetails(); // Fetches the anime details
  }

  // Fetch anime details using GogoanimeService
  void fetchAnimeDetails() async {
    try {
      var details = await GogoanimeService.fetchAnimeDetails(widget.animeUrl);

      if (mounted) { // Ensure the widget is still mounted before calling setState
        setState(() {
          title = details['title'] ?? 'Unknown title';
          description = details['description'] ?? 'No description';
          genre = details['genre'] ?? 'No genre';
          coverImage = details['coverImage'] ?? '';
          episodes = details['episodes'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          title = 'Failed to load anime details';
        });
      }
      print("Error fetching anime details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (coverImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(coverImage, height: 200, fit: BoxFit.cover),
                      ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Genre: $genre',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Episodes:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        var episode = episodes[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 16.0,
                            ),
                            title: Text(
                              episode['title'] ?? 'Episode',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Click to watch this episode',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Icon(Icons.play_circle_fill, color: Colors.blueAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WatchPage(episodeUrl: episode['url'] ?? ''),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
