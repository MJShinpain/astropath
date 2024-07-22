import 'dart:math';
import 'package:diacritic/diacritic.dart';
import 'city_data.dart';

double julianDay(DateTime utcDateTime) {
  int y = utcDateTime.year;
  int m = utcDateTime.month;
  int d = utcDateTime.day;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  int a = y ~/ 100;
  int b = 2 - a + (a ~/ 4);
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      d +
      b -
      1524.5 +
      utcDateTime.hour / 24.0 +
      utcDateTime.minute / 1440.0 +
      utcDateTime.second / 86400.0;
}

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  lat1 = _toRadians(lat1);
  lat2 = _toRadians(lat2);

  double a = sin(dLat/2) * sin(dLat/2) +
      sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1-a));
  return 6371 * c; // Earth's radius in km
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

List<City> searchCities(String query) {
  String normalizedQuery = removeDiacritics(query.toLowerCase());
  return cities.where((city) {
    String normalizedCityName = removeDiacritics(city.name.toLowerCase());
    return normalizedCityName.contains(normalizedQuery) ||
        _calculateLevenshteinDistance(normalizedQuery, normalizedCityName) <= 3;
  }).toList();
}

int _calculateLevenshteinDistance(String a, String b) {
  List<int> costs = List<int>.filled(b.length + 1, 0);

  for (int j = 0; j <= b.length; j++) {
    costs[j] = j;
  }

  for (int i = 1; i <= a.length; i++) {
    costs[0] = i;
    int nw = i - 1;
    for (int j = 1; j <= b.length; j++) {
      int cj = min(1 + min(costs[j], costs[j - 1]),
          a[i - 1] == b[j - 1] ? nw : nw + 1);
      nw = costs[j];
      costs[j] = cj;
    }
  }

  return costs[b.length];
}