import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:geocoding/geocoding.dart';
import 'package:astronomy/astronomy.dart';

void main() {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venus Position Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VenusCalculator(),
    );
  }
}

class VenusCalculator extends StatefulWidget {
  @override
  _VenusCalculatorState createState() => _VenusCalculatorState();
}

class _VenusCalculatorState extends State<VenusCalculator> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _location = '';
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Venus Position Calculator')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Time'),
                readOnly: true,
                onTap: () => _selectTime(context),
                controller: TextEditingController(
                  text: _selectedTime.format(context),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location (e.g., Seoul, South Korea)'),
                onChanged: (value) => _location = value,
              ),
              ElevatedButton(
                onPressed: _calculateVenusPosition,
                child: Text('Calculate'),
              ),
              SizedBox(height: 20),
              Text(_result),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  void _calculateVenusPosition() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Convert local time to UTC
        final localTime = tz.TZDateTime(
          tz.getLocation('Asia/Seoul'), // Default to Seoul timezone
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        final utcTime = localTime.toUtc();

        // Get latitude and longitude from location
        List<Location> locations = await locationFromAddress(_location);
        if (locations.isEmpty) {
          setState(() {
            _result = 'Error: Location not found';
          });
          return;
        }
        final latitude = locations.first.latitude;
        final longitude = locations.first.longitude;

        // Calculate Venus positions
        final observer = Observer(
          latitude: latitude,
          longitude: longitude,
          elevation: 0,
          temperature: 10,
          pressure: 1010,
        );

        final venus = Venus();
        final riseTime = venus.riseTime(utcTime, observer);
        final setTime = venus.setTime(utcTime, observer);

        setState(() {
          _result = 'UTC Time: ${utcTime.toIso8601String()}\n'
              'Venus Rising at: ${riseTime?.toIso8601String() ?? 'Not visible'}\n'
              'Venus Setting at: ${setTime?.toIso8601String() ?? 'Not visible'}';
        });
      } catch (e) {
        setState(() {
          _result = 'Error: ${e.toString()}';
        });
      }
    }
  }
}