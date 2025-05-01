import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:match2048/screens/game_screen.dart';
import 'package:match2048/widgets/banner_ad.dart';
import 'package:match2048/widgets/interstitial_ad.dart';
import 'blocs/game_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    _interstitialAdManager.loadInterstitialAd();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BannerAdWidget(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade900, Colors.indigo], // Gradient colors
              begin: Alignment.topLeft, // Start point
              end: Alignment.bottomRight, // End point
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: kToolbarHeight,
              ),
              Text(
                '2048 Game',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              BlocProvider(
                create: (context) => GameBloc(),
                child: GameScreen(interstitialAdManager: _interstitialAdManager,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
