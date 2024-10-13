import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class GogoanimeService {
  // Method to search anime with links
  static Future<List<Map<String, String>>> searchAnimeWithLinks(String query) async {
    final searchQuery = query.replaceAll(' ', '+');
    final url = 'https://ww8.gogoanimes.org//search?keyword=$searchQuery';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);

      var results = document.querySelectorAll('.name a').map((element) {
        final title = element.text.trim();
        final url = element.attributes['href'] ?? '';
        return {
          'title': title,
          'url': 'https://ww8.gogoanimes.org$url',
        };
      }).toList();

      return results;
    } else {
      throw Exception('Failed to load anime');
    }
  }

  // Method to fetch anime details and episodes
  static Future<Map<String, dynamic>> fetchAnimeDetails(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);

      // Extract anime title
      String title = document.querySelector('.anime_info_body_bg h1')?.text.trim() ?? 'No title found';

      // Extract genres
      var genreElements = document.querySelectorAll('.anime_info_body_bg a[href*="/genre/"]');
      String genre = genreElements.map((element) => element.text.trim()).join(', ');

      // Extract description
      var infoElements = document.querySelectorAll('.anime_info_body_bg p.type');
      String description = infoElements.isNotEmpty ? infoElements[1].text.trim() : 'No description found';

      // Extract cover image
      String coverImage = document.querySelector('.anime_info_body_bg img')?.attributes['src'] ?? '';

      // Extract episodes list
      String alias = url.split('/').last;
      var episodes = await fetchEpisodes(alias);

      return {
        'title': title,
        'genre': genre,
        'description': description,
        'coverImage': coverImage,
        'episodes': episodes,
      };
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  // Method to fetch the list of episodes for an anime
  static Future<List<Map<String, String>>> fetchEpisodes(String alias) async {
    final apiUrl =
        'https://ww8.gogoanimes.org/ajaxajax/load-list-episode?ep_start=0&ep_end=&id=0&default_ep=&alias=/category/$alias';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);

      var episodesElement = document.querySelectorAll('#episode_related li a');

      List<Map<String, String>> episodes = episodesElement.map((element) {
        final episodeUrl = (element.attributes['href'] ?? '').trim();
        final episodeTitle = element.text.trim();

        return {
          'title': episodeTitle,
          'url': 'https://ww8.gogoanimes.org$episodeUrl',
        };
      }).toList();

      return episodes;
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  // Method to fetch the direct video URL from an episode page
  static Future<String> fetchVideoUrl(String episodeUrl) async {
    final response = await http.get(Uri.parse(episodeUrl));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);

      // Try to find the <iframe> tag containing the video URL
      var iframeElement = document.querySelector('iframe');
      String videoUrl = iframeElement?.attributes['src'] ?? 'No video URL found';

      // If there is no iframe, you could also check for a <video> tag (just in case)
      var videoElement = document.querySelector('video');
      if (videoElement != null) {
        videoUrl = videoElement.attributes['src'] ?? videoUrl;
      }

      print(videoUrl);

      return videoUrl;
    } else {
      throw Exception('Failed to load video page');
    }
  }
}
