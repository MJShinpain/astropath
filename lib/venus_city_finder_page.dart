import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'city_data.dart';
import 'venus_calculations.dart';
import 'utils.dart';

class VenusCityFinderPage extends StatefulWidget {
  @override
  _VenusCityFinderPageState createState() => _VenusCityFinderPageState();
}

class _VenusCityFinderPageState extends State<VenusCityFinderPage> {
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
    cities.firstWhere((city) => city.name == 'Paris, France'),
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
        title: Text('Your Romantic City'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter birth place',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Quick Access Cities:'),
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
            Text('Selected Location: ${_selectedCity?.name ?? 'Not selected'}'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Select Birth Date and Time'),
              onPressed: _selectDateTime,
            ),
            SizedBox(height: 20),
            Text('Selected Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)} ${_selectedTimeZone.name}'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Find Romantic Cities'),
              onPressed: _isLoading || _selectedCity == null ? null : _findRomanticCities,
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

  void _findRomanticCities() {
    if (_selectedCity == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    tz.TZDateTime selectedTZDateTime = tz.TZDateTime.from(_selectedDateTime, _selectedTimeZone);
    tz.TZDateTime utcDateTime = selectedTZDateTime.toUtc();

    double jd = julianDay(utcDateTime);
    VenusPosition venusPos = calculateVenusPosition(jd);

    List<double> risingPos = calculateRisingPosition(
        venusPos.longitude, venusPos.latitude, jd,
        _selectedCity!.latitude, _selectedCity!.longitude
    );
    List<double> settingPos = calculateSettingPosition(
        venusPos.longitude, venusPos.latitude, jd,
        _selectedCity!.latitude, _selectedCity!.longitude
    );
    List<double> culminatingPos = calculateCulminatingPosition(
        venusPos.longitude, venusPos.latitude, jd,
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
      return {
        'city': city,
        'distance': haversineDistance(lat, lon, city.latitude, city.longitude)
      };
    }).toList();

    distances.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    return distances.take(3).toList();
  }

  String _formatResults(List<Map<String, dynamic>> rising, List<Map<String, dynamic>> setting, List<Map<String, dynamic>> culminating) {
    String result = 'Romantic Cities based on Venus positions:\n\n';

    result += 'Venus Rising:\n';
    for (var cityInfo in rising) {
      result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
    }

    result += '\nVenus Setting:\n';
    for (var cityInfo in setting) {
      result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
    }

    result += '\nVenus Culminating:\n';
    for (var cityInfo in culminating) {
      result += '${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
    }

    return result;
  }
}