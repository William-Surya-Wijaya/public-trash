import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart'; // To handle intent:// URLs
import 'dart:io';
import 'package:anibi/modules/gogoanime_service.dart'; // Assuming this contains fetchVideoUrl function

class WatchPage extends StatefulWidget {
  final String episodeUrl;

  WatchPage({required this.episodeUrl});

  @override
  _WatchPageState createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  String selectedSource = ''; // Currently selected video source
  List<String> videoSources = []; // List of video sources

  @override
  void initState() {
    super.initState();
    fetchAndLoadVideo();
  }

  // Fetch the video URL and load it into the WebView
  void fetchAndLoadVideo() async {
    try {
      // Fetch multiple video sources
      List<String> sources = await GogoanimeService.fetchVideoUrls(widget.episodeUrl);

      setState(() {
        isLoading = false;
        videoSources = sources;
        selectedSource = videoSources.isNotEmpty ? videoSources[0] : ''; // Select the first source by default
      });

      if (selectedSource.isNotEmpty) {
        loadVideo(selectedSource); // Load the selected video source
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loader in case of error
      });
      print("Error fetching video sources: $e");
    }
  }

  void loadVideo(String videoUrl) async {
    // Initialize the WebView and load the video URL
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    // Set JavaScript mode and load the fetched video URL
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('Loading progress: $progress%');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
          // Inject JavaScript to hide ad elements after the page is loaded
          _controller.runJavaScript('''
            // Hide the ad element
            var adElements = document.querySelectorAll("div[style*='padding: 5px']");
            adElements.forEach(function(ad) {
              ad.style.display = 'none';
            });
          ''');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('intent://')) {
            // Handle intent:// URLs by launching them outside the WebView
            print('Attempting to launch: ${request.url}');
            _launchExternalApp(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Error: ${error.description}');
        },
      ))
      ..loadRequest(Uri.parse(videoUrl));

    if (!Platform.isMacOS) {
      _controller.setBackgroundColor(const Color(0x80000000));
    }

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  // Function to launch external apps for intent:// URLs
  void _launchExternalApp(String url) async {
    final Uri parsedUrl = Uri.parse(url);
    if (await canLaunchUrl(parsedUrl)) {
      await launchUrl(parsedUrl);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Episode'),
        actions: [
          // Dropdown button for selecting the video source
          if (videoSources.isNotEmpty)
            DropdownButton<String>(
              value: selectedSource,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedSource = newValue;
                    loadVideo(selectedSource); // Load the selected video source
                  });
                }
              },
              items: videoSources.map((String source) {
                // Show more readable text like "Source 1", "Source 2"
                return DropdownMenuItem<String>(
                  value: source,
                  child: Text('Source ${videoSources.indexOf(source) + 1}'), // Display "Source 1", "Source 2", etc.
                );
              }).toList(),
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching the video URL
          : WebViewWidget(controller: _controller),
    );
  }
}
