import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'city_data.dart';
import 'moon_calculations.dart';
import 'utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MoonCityFinderPage extends StatefulWidget {
  @override
  _MoonCityFinderPageState createState() => _MoonCityFinderPageState();
}

class _MoonCityFinderPageState extends State<MoonCityFinderPage> {
  DateTime _selectedDateTime = DateTime.now();
  String _result = '';
  bool _isLoading = false;
  late tz.Location _selectedTimeZone;
  City? _selectedCity;
  final TextEditingController _locationController = TextEditingController();

  final List<City> _quickAccessCities = [
    cities.firstWhere((city) => city.name == 'New York City, USA'),
    cities.firstWhere((city) => city.name == 'London, United Kingdom'),
    cities.firstWhere((city) => city.name == 'Tokyo, Japan'),
    cities.firstWhere((city) => city.name == 'Seoul, Korea'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTimeZone = tz.getLocation('UTC');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.moonCityFinder),
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
              child: Text(AppLocalizations.of(context)!.findMoonCities),
              onPressed: _isLoading || _selectedCity == null ? null : _findMoonCities,
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

  void _findMoonCities() {
    if (_selectedCity == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    tz.TZDateTime selectedTZDateTime = tz.TZDateTime.from(_selectedDateTime, _selectedTimeZone);
    tz.TZDateTime utcDateTime = selectedTZDateTime.toUtc();

    double jd = julianDay(utcDateTime);
    MoonPosition moonPos = calculateMoonPosition(jd);

    List<double> risingPos = calculateMoonRisingPosition(
        moonPos.longitude, moonPos.latitude, jd,
        _selectedCity!.latitude, _selectedCity!.longitude
    );
    List<double> settingPos = calculateMoonSettingPosition(
        moonPos.longitude, moonPos.latitude, jd,
        _selectedCity!.latitude, _selectedCity!.longitude
    );
    List<double> culminatingPos = calculateMoonCulminatingPosition(
        moonPos.longitude, moonPos.latitude, jd,
        _selectedCity!.latitude, _selectedCity!.longitude
    );

    List<Map<String, dynamic>> nearestRising = _findNearestCities(risingPos[0], risingPos[1]);
    List<Map<String, dynamic>> nearestSetting = _findNearestCities(settingPos[0], settingPos[1]);
    List<Map<String, dynamic>> nearestCulminating = _findNearestCities(culminatingPos[0], culminatingPos[1]);

    setState(() {
      _result = _formatResults(nearestRising, nearestSetting, nearestCulminating);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _findNearestCities(double lat, double lon) {
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
    String result = AppLocalizations.of(context)!.citiesWithin2000km(celestialBody);

    result += AppLocalizations.of(context)!.rising + '\n';
    if (rising.isEmpty) {
      result += AppLocalizations.of(context)!.noCitiesWithin2000km + '\n';
    } else {
      for (var cityInfo in rising) {
        result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
      }
    }

    result += AppLocalizations.of(context)!.setting + '\n';
    if (setting.isEmpty) {
      result += AppLocalizations.of(context)!.noCitiesWithin2000km + '\n';
    } else {
      for (var cityInfo in setting) {
        result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
      }
    }

    result += AppLocalizations.of(context)!.culminating + '\n';
    if (culminating.isEmpty) {
      result += AppLocalizations.of(context)!.noCitiesWithin2000km + '\n';
    } else {
      for (var cityInfo in culminating) {
        result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
      }
    }

    return result;
  }
}