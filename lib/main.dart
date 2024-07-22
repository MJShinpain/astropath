import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/celestial_bodies/moon.dart';
import 'models/celestial_bodies/venus.dart';
import 'pages/celestial_body_finder_page.dart';

void main() {
  tz.initializeTimeZones();
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: MyApp(),
    ),
  );
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Romantic City',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: Provider.of<LocaleProvider>(context).locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('ko', ''),
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> celestialBodies = [
    {'name': 'Moon', 'body': Moon()},
    {'name': 'Venus', 'body': Venus()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          PopupMenuButton<Locale>(
            icon: Icon(Icons.language),
            onSelected: (Locale locale) {
              Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                PopupMenuItem(
                  value: Locale('ko'),
                  child: Text('한국어'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: celestialBodies.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            child: Text('${celestialBodies[index]['name']} ${AppLocalizations.of(context)!.cityFinder}'),
            onPressed: () {
              print('Button pressed for ${celestialBodies[index]['name']}'); // Debug log
              final celestialBody = celestialBodies[index]['body'];
              if (celestialBody != null) {
                try {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CelestialBodyFinderPage(
                        celestialBody: celestialBody,
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error navigating to CelestialBodyFinderPage: $e'); // Debug log
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Could not open page')),
                  );
                }
              } else {
                print('Celestial body is null'); // Debug log
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: Celestial body not found')),
                );
              }
            },
          );
        },
      ),
    );
  }
}