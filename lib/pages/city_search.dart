import 'package:flutter/material.dart';
import '../utils/city_data.dart';
import '../utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CitySearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(City) onCitySelected;

  const CitySearchWidget({
    Key? key,
    required this.controller,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.enterBirthPlace,
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _searchLocation(context),
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
                onPressed: () => onCitySelected(city),
              )
          ).toList(),
        ),
      ],
    );
  }

  void _searchLocation(BuildContext context) {
    String searchTerm = controller.text;
    List<City> matchingCities = searchCities(searchTerm);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Select Location'),
            children: matchingCities.map((City city) {
              return SimpleDialogOption(
                onPressed: () {
                  onCitySelected(city);
                  Navigator.pop(context);
                },
                child: Text(city.name),
              );
            }).toList(),
          );
        }
    );
  }

  static final List<City> _quickAccessCities = [
    cities.firstWhere((city) => city.name == 'New York City, USA', orElse: () => cities.first),
    cities.firstWhere((city) => city.name == 'London, United Kingdom', orElse: () => cities.first),
    cities.firstWhere((city) => city.name == 'Tokyo, Japan', orElse: () => cities.first),
    cities.firstWhere((city) => city.name == 'Seoul, South Korea', orElse: () => cities.first),
  ].where((city) => city != null).toList();
}

List<City> searchCities(String searchTerm) {
  return cities.where((city) =>
      city.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
}

List<Map<String, dynamic>> findNearestCities(double lat, double lon) {
  if (lat.isNaN || lon.isNaN) {
    print('Invalid latitude or longitude');
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