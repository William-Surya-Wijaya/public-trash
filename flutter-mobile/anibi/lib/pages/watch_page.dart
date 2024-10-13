import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
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
  String videoUrl = ''; // Store the final video URL

  @override
  void initState() {
    super.initState();
    fetchAndLoadVideo();
  }

  // Fetch the video URL and load it into the WebView
  void fetchAndLoadVideo() async {
    try {
      videoUrl = await GogoanimeService.fetchVideoUrl(widget.episodeUrl); // Fetch the video URL
      setState(() {
        isLoading = false; // Stop showing the loader once the video URL is fetched
      });

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
    } catch (e) {
      print("Error fetching video URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Episode'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching the video URL
          : WebViewWidget(controller: _controller),
    );
  }
}
