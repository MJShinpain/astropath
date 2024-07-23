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
  String _debugInfo = '';
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
            Text("${AppLocalizations.of(context)!.selectedLocation} ${_selectedCity?.name ?? AppLocalizations.of(context)!.notSelected}"),
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
                Text(_debugInfo),
                SizedBox(height: 10),
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
    if (_selectedCity == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
      _debugInfo = '';
      _allNearestCities = [];
    });

    tz.TZDateTime selectedTZDateTime = tz.TZDateTime.from(_selectedDateTime, _selectedTimeZone);
    tz.TZDateTime utcDateTime = selectedTZDateTime.toUtc();
    double jd = julianDay(utcDateTime);

    _debugInfo = _generateDebugInfo(utcDateTime, jd);

    List<String> positionTypes = ['Rising', 'Setting', 'Culminating', 'Nadir'];
    for (var type in positionTypes) {
      var position = _calculatePosition(type, jd);
      _debugInfo += '$type Position: (${position[0].toStringAsFixed(2)}, ${position[1].toStringAsFixed(2)})\n';
      var nearestCities = findNearestCities(position[0], position[1]);
      _allNearestCities.addAll(nearestCities);
    }

    _allNearestCities.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    _allNearestCities = _allNearestCities.take(12).toList();

    setState(() {
      _result = formatResults(_allNearestCities, widget.celestialBody.name, context);
      _isLoading = false;
    });
  }

  List<double> _calculatePosition(String type, double jd) {
    switch (type) {
      case 'Rising':
        return widget.celestialBody.calculateRisingPosition(jd, _selectedCity!.latitude, _selectedCity!.longitude);
      case 'Setting':
        return widget.celestialBody.calculateSettingPosition(jd, _selectedCity!.latitude, _selectedCity!.longitude);
      case 'Culminating':
        return widget.celestialBody.calculateCulminatingPosition(jd, _selectedCity!.latitude, _selectedCity!.longitude);
      case 'Nadir':
        return widget.celestialBody.calculateNadirPosition(jd, _selectedCity!.latitude, _selectedCity!.longitude);
      default:
        throw ArgumentError('Invalid position type');
    }
  }

  String _generateDebugInfo(tz.TZDateTime utcDateTime, double jd) {
    return 'Selected DateTime: $_selectedDateTime\n'
        'UTC DateTime: $utcDateTime\n'
        'Julian Day: $jd\n';
  }
}