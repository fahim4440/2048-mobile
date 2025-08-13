import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:match2048/screens/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // MobileAds.instance.initialize();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

  // @override
  // void initState() {
  //   super.initState();
  //   if (!kIsWeb) {
  //     _interstitialAdManager.loadInterstitialAd();
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // bottomNavigationBar: kIsWeb ? const SizedBox() : BannerAdWidget(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade900, Colors.indigo], // Gradient colors
              begin: Alignment.topLeft, // Start point
              end: Alignment.bottomRight, // End point
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                  ),
                  Expanded(child: MenuScreen())
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}