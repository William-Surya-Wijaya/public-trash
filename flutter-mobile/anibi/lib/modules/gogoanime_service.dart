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

      // Extract anime title (handle different structures)
      String title = document.querySelector('.anime_info_body_bg h1')?.text.trim() ?? 
                     document.querySelector('h1.title')?.text.trim() ?? 'No title found';

      // Extract genres (handle different structures)
      var genreElements = document.querySelectorAll('.anime_info_body_bg a[href*="/genre/"]');
      String genre = genreElements.map((element) => element.text.trim()).join(', ') ?? 
                     document.querySelectorAll('.genres a').map((element) => element.text.trim()).join(', ');

      // Extract description (handle different structures)
      var infoElements = document.querySelectorAll('.anime_info_body_bg p.type');
      String description = infoElements.isNotEmpty ? infoElements[1].text.trim() : 
                          document.querySelector('.description')?.text.trim() ?? 'No description found';

      // Extract cover image (handle different structures)
      String coverImage = document.querySelector('.anime_info_body_bg img')?.attributes['src'] ?? 
                          document.querySelector('.cover img')?.attributes['src'] ?? '';

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

      // Try to find the <iframe> tag (old structure)
      var iframeElement = document.querySelector('iframe');
      String videoUrl = iframeElement?.attributes['src'] ?? '';

      // If no iframe is found, look for video inside #video-wrapper (new structure)
      if (videoUrl.isEmpty) {
        var videoWrapper = document.querySelector('#video-wrapper');
        var videoElement = videoWrapper?.querySelector('video source');
        videoUrl = videoElement?.attributes['src'] ?? '';
      }

      // If no video URL is found, try finding links in alternative structures
      if (videoUrl.isEmpty) {
        var alternativeVideoSources = document.querySelectorAll('.alternative-source-selector a');
        for (var source in alternativeVideoSources) {
          String alternativeUrl = source.attributes['href'] ?? '';
          if (alternativeUrl.isNotEmpty) {
            videoUrl = alternativeUrl;
            break; // Use the first valid source found
          }
        }
      }

      if (videoUrl.isEmpty) {
        videoUrl = 'No video URL found'; // If still empty, return an error message
      }

      print(videoUrl); // Debugging output to ensure correct URL is fetched
      return videoUrl;
    } else {
      throw Exception('Failed to load video page');
    }
  }

   static Future<List<String>> fetchVideoUrls(String episodeUrl) async {
    final response = await http.get(Uri.parse(episodeUrl));

    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      List<String> videoUrls = [];

      // Try to find the <iframe> tag (old structure)
      var iframeElements = document.querySelectorAll('iframe');
      for (var iframe in iframeElements) {
        String iframeUrl = iframe.attributes['src'] ?? '';
        if (iframeUrl.isNotEmpty && !iframeUrl.contains('ads') && !iframeUrl.contains('pop')) {
          // Exclude known ad URLs by checking for common keywords like 'ads', 'pop', etc.
          videoUrls.add(iframeUrl);
        }
      }

      // If no iframe is found, look for video inside #video-wrapper (new structure)
      var videoWrapper = document.querySelector('#video-wrapper');
      if (videoWrapper != null) {
        var videoElement = videoWrapper.querySelectorAll('video source');
        for (var source in videoElement) {
          String videoSourceUrl = source.attributes['src'] ?? '';
          if (videoSourceUrl.isNotEmpty && videoSourceUrl.contains('.mp4')) {
            videoUrls.add(videoSourceUrl);
          }
        }
      }

      // If no video URL is found, check for alternative structures (but still exclude ad-related links)
      if (videoUrls.isEmpty) {
        var alternativeVideoSources = document.querySelectorAll('.alternative-source-selector a');
        for (var source in alternativeVideoSources) {
          String altSourceUrl = source.attributes['href'] ?? '';
          if (altSourceUrl.isNotEmpty && !altSourceUrl.contains('ads') && altSourceUrl.contains('.mp4')) {
            videoUrls.add(altSourceUrl); // Exclude ads, include .mp4
          }
        }
      }

      if (videoUrls.isEmpty) {
        print('No valid video sources found.');
        throw Exception('No video URL found');
      }

      print(videoUrls); // Debugging output to ensure correct URLs are fetched
      return videoUrls;
    } else {
      throw Exception('Failed to load video page');
    }
  }
}
