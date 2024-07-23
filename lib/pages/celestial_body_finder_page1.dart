import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/celestial_bodies/celestial_body.dart';
import '../utils/city_data.dart';
import '../utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'date_time_selector.dart';
import 'map_view.dart';
import 'city_search.dart';
import 'result_formatter.dart';

class CelestialBodyFinderPage extends StatefulWidget {
  final CelestialBody celestialBody;

  const CelestialBodyFinderPage({Key? key, required this.celestialBody}) : super(key: key);

  @override
  _CelestialBodyFinderPageState createState() => _CelestialBodyFinderPageState();
}

class _CelestialBodyFinderPageState extends State<CelestialBodyFinderPage> {
  DateTime _selectedDateTime = DateTime.now();
  String _result = '';
  bool _isLoading = false;
  late tz.Location _selectedTimeZone;
  City? _selectedCity;
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> _allNearestCities = [];

  @override
  void initState() {
    super.initState();
    _selectedTimeZone = tz.getLocation('UTC');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.celestialBody.name} ${AppLocalizations.of(context)!.cityFinder}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CitySearchWidget(
              controller: _locationController,
              onCitySelected: _selectCity,
            ),
            SizedBox(height: 20),
            DateTimeSelector(
              initialDateTime: _selectedDateTime,
              onDateTimeSelected: _updateDateTime,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.findRomanticCities),
              onPressed: _isLoading || _selectedCity == null ? null : _findCities,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
              children: [
                Text(_result),
                SizedBox(height: 20),
                MapView(cities: _allNearestCities),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectCity(City city) {
    setState(() {
      _selectedCity = city;
      _selectedTimeZone = tz.getLocation(city.timeZone);
      _locationController.text = city.name;
    });
  }

  void _updateDateTime(DateTime dateTime) {
    setState(() {
      _selectedDateTime = dateTime;
    });
  }

  void _findCities() {
    if (_selectedCity == null) {
      print('No city selected');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
      _allNearestCities = [];
    });

    tz.TZDateTime selectedTZDateTime = tz.TZDateTime.from(_selectedDateTime, _selectedTimeZone);
    tz.TZDateTime utcDateTime = selectedTZDateTime.toUtc();

    double jd = julianDay(utcDateTime);

    List<double> risingPos = widget.celestialBody.calculateRisingPosition(
        jd, _selectedCity!.latitude, _selectedCity!.longitude);
    List<double> settingPos = widget.celestialBody.calculateSettingPosition(
        jd, _selectedCity!.latitude, _selectedCity!.longitude);
    List<double> culminatingPos = widget.celestialBody.calculateCulminatingPosition(
        jd, _selectedCity!.latitude, _selectedCity!.longitude);

    List<Map<String, dynamic>> nearestRising = findNearestCities(risingPos[0], risingPos[1]);
    List<Map<String, dynamic>> nearestSetting = findNearestCities(settingPos[0], settingPos[1]);
    List<Map<String, dynamic>> nearestCulminating = findNearestCities(culminatingPos[0], culminatingPos[1]);

    _allNearestCities = [...nearestRising, ...nearestSetting, ...nearestCulminating];
    _allNearestCities.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    _allNearestCities = _allNearestCities.take(9).toList();  // Limit to 9 cities

    setState(() {
      _result = formatResults(_allNearestCities, widget.celestialBody.name, context);
      _isLoading = false;
    });
  }
}