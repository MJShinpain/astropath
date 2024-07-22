import 'dart:math';
import 'package:flutter/material.dart';
import 'celestial_body.dart';

class Moon extends CelestialBody {
  @override
  String get name => 'Moon';

  @override
  Color get color => Colors.grey;

  @override
  double calculateLongitude(double jde) {
    double t = (jde - 2451545.0) / 36525.0;
    return _moonLongitude(t);
  }

  @override
  double calculateLatitude(double jde) {
    double t = (jde - 2451545.0) / 36525.0;
    return _moonLatitude(t);
  }

  @override
  double calculateDistance(double jde) {
    double t = (jde - 2451545.0) / 36525.0;
    return _moonDistance(t);
  }

  double _moonLongitude(double t) {
    List<List<double>> terms = [
      [6.288774, 0.00000000, 0.00000000],
      [1.274027, 2.2977719, 477198.867398],
      [0.658314, 1.1318349, 483202.017538],
      [0.213618, 2.5455839, 960400.886014],
      [0.114706, 2.9088820, 6003.149391],
      [0.057694, 2.7823443, 407332.237409],
      [0.055177, 5.1541944, 484409.253819],
      [0.042520, 0.2703618, 10977.078804],
      [0.032202, 3.0756544, 5223.693919],
      [0.029823, 2.6280058, 5507.553239],
    ];

    double l = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t +
        t * t * t / 538841.0 - t * t * t * t / 65194000.0;

    for (var term in terms) {
      l += term[0] * sin((term[1] + term[2] * t) * pi / 180.0);
    }

    return (l % 360.0) * pi / 180.0;  // Convert to radians
  }

  double _moonLatitude(double t) {
    List<List<double>> terms = [
      [5.128122, 0.0000000, 0.0000000],
      [0.280602, 3.4735428, 477198.867398],
      [0.277693, 4.6791375, 483202.017538],
      [0.173237, 1.6839443, 960400.886014],
      [0.055413, 5.7070449, 6003.149391],
      [0.046271, 3.7132720, 407332.237409],
      [0.032573, 4.0991275, 484409.253819],
      [0.017198, 2.9984643, 10977.078804],
      [0.009266, 4.4098646, 5223.693919],
      [0.008822, 5.9177460, 5507.553239],
    ];

    double b = 0.0;

    for (var term in terms) {
      b += term[0] * sin((term[1] + term[2] * t) * pi / 180.0);
    }

    return b * pi / 180.0;  // Convert to radians
  }

  double _moonDistance(double t) {
    List<List<double>> terms = [
      [-20905.355, 0.0000000, 0.0000000],
      [-3699.111, 2.2977719, 477198.867398],
      [-2955.968, 1.1318349, 483202.017538],
      [-569.925, 2.5455839, 960400.886014],
      [-246.528, 2.9088820, 6003.149391],
      [-204.586, 2.7823443, 407332.237409],
      [-170.733, 5.1541944, 484409.253819],
      [-152.138, 0.2703618, 10977.078804],
      [-129.778, 3.0756544, 5223.693919],
      [-108.743, 2.6280058, 5507.553239],
    ];

    double r = 385000.56 + 20905.355 * cos(0.0);

    for (var term in terms) {
      r += term[0] * cos((term[1] + term[2] * t) * pi / 180.0);
    }

    return r;  // In kilometers
  }

  @override
  List<double> calculateRisingPosition(double jde, double observerLat, double observerLon) {
    return _calculatePosition(jde, observerLat, observerLon, _calculateRising);
  }

  @override
  List<double> calculateSettingPosition(double jde, double observerLat, double observerLon) {
    return _calculatePosition(jde, observerLat, observerLon, _calculateSetting);
  }

  @override
  List<double> calculateCulminatingPosition(double jde, double observerLat, double observerLon) {
    return _calculatePosition(jde, observerLat, observerLon, _calculateCulminating);
  }

  List<double> _calculatePosition(double jde, double observerLat, double observerLon,
      List<double> Function(double, double, double, double, double) calculationFunction) {
    double longitude = calculateLongitude(jde);
    double latitude = calculateLatitude(jde);
    return calculationFunction(longitude, latitude, jde, observerLat, observerLon);
  }

  List<double> _calculateRising(double longitude, double latitude, double jd, double observerLat, double observerLon) {
    double h0 = 0.125 * pi / 180.0; // Moon's angular radius + atmospheric refraction
    return _calculateEventPosition(longitude, latitude, jd, observerLat, observerLon, h0, true);
  }

  List<double> _calculateSetting(double longitude, double latitude, double jd, double observerLat, double observerLon) {
    double h0 = 0.125 * pi / 180.0; // Moon's angular radius + atmospheric refraction
    return _calculateEventPosition(longitude, latitude, jd, observerLat, observerLon, h0, false);
  }

  List<double> _calculateCulminating(double longitude, double latitude, double jd, double observerLat, double observerLon) {
    double phi = observerLat * pi / 180.0;
    double L = observerLon * pi / 180.0;

    double theta0 = _apparentSiderealTime(jd);
    double alpha = longitude;
    double delta = latitude;

    double m0 = (alpha + L - theta0) / (2 * pi);
    m0 = (m0 - m0.floor()) * 24;

    // 시간을 경도와 위도로 변환
    double t = m0 / 24;
    double culminatingLon = (t * 360 - observerLon + 360) % 360;
    double culminatingLat = asin(sin(phi) * sin(delta) + cos(phi) * cos(delta)) * 180 / pi;

    return [culminatingLon, culminatingLat];
  }

  List<double> _calculateEventPosition(double longitude, double latitude, double jd,
      double observerLat, double observerLon, double h0, bool isRising) {
    double phi = observerLat * pi / 180.0;
    double L = observerLon * pi / 180.0;

    double theta0 = _apparentSiderealTime(jd);
    double alpha = longitude;
    double delta = latitude;

    double cosH0 = (sin(h0) - sin(phi) * sin(delta)) / (cos(phi) * cos(delta));
    if (cosH0 < -1.0 || cosH0 > 1.0) {
      // Moon doesn't rise or set
      return [double.nan, double.nan];
    }

    double H0 = acos(cosH0);
    double m0 = (alpha + L - theta0) / (2 * pi);
    m0 = (m0 - m0.floor()) * 24;

    double m = isRising ? m0 - H0 * 12 / pi : m0 + H0 * 12 / pi;

    // Convert time to longitude and latitude
    double t = m / 24;
    double eventLon = (t * 360 - observerLon + 360) % 360;
    double eventLat = asin(sin(phi) * sin(delta) +
        cos(phi) * cos(delta) * cos(isRising ? H0 : -H0)) * 180 / pi;

    return [eventLon, eventLat];
  }

  double _apparentSiderealTime(double jd) {
    double T = (jd - 2451545.0) / 36525.0;
    double theta0 = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
        0.000387933 * T * T - T * T * T / 38710000.0;
    return (theta0 % 360.0) * pi / 180.0;
  }
}