import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/celestial_bodies/celestial_body.dart';
import '../utils/city_data.dart';
import '../utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final List<City> _quickAccessCities = [
    cities.firstWhere((city) => city.name == 'New York City, USA', orElse: () => cities.first),
    cities.firstWhere((city) => city.name == 'London, United Kingdom', orElse: () => cities.first),
    cities.firstWhere((city) => city.name == 'Tokyo, Japan', orElse: () => cities.first),
    cities.firstWhere((city) => city.name == 'Seoul, Korea', orElse: () => cities.first),
  ].where((city) => city != null).toList();

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
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.enterBirthPlace,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.quickAccessCities),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: _quickAccessCities.map((city) =>
                  ElevatedButton(
                    child: Text(city.name.split(',')[0]),
                    onPressed: () => _selectCity(city),
                  )
              ).toList(),
            ),
            SizedBox(height: 20),
            Text("${AppLocalizations.of(context)!.selectedLocation} ${_selectedCity?.name ?? AppLocalizations.of(context)!.notSelected}"),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.selectBirthDateTime),
              onPressed: _selectDateTime,
            ),
            SizedBox(height: 20),
            Text("${AppLocalizations.of(context)!.selectedDateTime} ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)} ${_selectedTimeZone.name}"),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.findRomanticCities),
              onPressed: _isLoading || _selectedCity == null ? null : _findCities,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Text(_result),
          ],
        ),
      ),
    );
  }

  void _searchLocation() {
    String searchTerm = _locationController.text;
    List<City> matchingCities = searchCities(searchTerm);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Select Location'),
            children: matchingCities.map((City city) {
              return SimpleDialogOption(
                onPressed: () {
                  _selectCity(city);
                  Navigator.pop(context);
                },
                child: Text(city.name),
              );
            }).toList(),
          );
        }
    );
  }

  void _selectCity(City city) {
    setState(() {
      _selectedCity = city;
      _selectedTimeZone = tz.getLocation(city.timeZone);
      _locationController.text = city.name;
    });
  }

  void _selectDateTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _findCities() {
    if (_selectedCity == null) {
      print('No city selected'); // Debug log
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    print('Selected city: ${_selectedCity!.name}'); // Debug log
    print('Selected date time: $_selectedDateTime'); // Debug log

    tz.TZDateTime selectedTZDateTime = tz.TZDateTime.from(_selectedDateTime, _selectedTimeZone);
    tz.TZDateTime utcDateTime = selectedTZDateTime.toUtc();

    double jd = julianDay(utcDateTime);

    List<double> risingPos = widget.celestialBody.calculateRisingPosition(
        jd, _selectedCity!.latitude, _selectedCity!.longitude);
    List<double> settingPos = widget.celestialBody.calculateSettingPosition(
        jd, _selectedCity!.latitude, _selectedCity!.longitude);
    List<double> culminatingPos = widget.celestialBody.calculateCulminatingPosition(
        jd, _selectedCity!.latitude, _selectedCity!.longitude);

    List<Map<String, dynamic>> nearestRising = _findNearestCities(risingPos[0], risingPos[1]);
    List<Map<String, dynamic>> nearestSetting = _findNearestCities(settingPos[0], settingPos[1]);
    List<Map<String, dynamic>> nearestCulminating = _findNearestCities(culminatingPos[0], culminatingPos[1]);

    setState(() {
      _result = _formatResults(nearestRising, nearestSetting, nearestCulminating);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _findNearestCities(double lat, double lon) {
    if (lat.isNaN || lon.isNaN) {
      print('Invalid latitude or longitude'); // Debug log
      return [];
    }

    var distances = cities.map((city) {
      return <String, dynamic>{
        'city': city,
        'distance': haversineDistance(lat, lon, city.latitude, city.longitude)
      };
    }).where((cityInfo) => cityInfo['distance'] <= 2000).toList();

    distances.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    return distances.take(3).toList();
  }

  String _formatResults(List<Map<String, dynamic>> rising, List<Map<String, dynamic>> setting, List<Map<String, dynamic>> culminating) {
    String result = AppLocalizations.of(context)!.citiesWithin2000km(widget.celestialBody.name);

    result += _formatCityList(AppLocalizations.of(context)!.rising, rising);
    result += _formatCityList(AppLocalizations.of(context)!.setting, setting);
    result += _formatCityList(AppLocalizations.of(context)!.culminating, culminating);

    return result;
  }

  String _formatCityList(String title, List<Map<String, dynamic>> cities) {
    String result = '$title\n';
    if (cities.isEmpty) {
      return result + AppLocalizations.of(context)!.noCitiesWithin2000km + '\n';
    }
    for (var cityInfo in cities) {
      result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
    }
    return result;
  }
}