import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'venus_city_finder_page.dart';

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your romatic city',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VenusCityFinderPage(),
    );
  }
}