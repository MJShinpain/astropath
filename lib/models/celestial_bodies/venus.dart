import 'dart:math';
import 'package:flutter/material.dart';
import 'celestial_body.dart';

class Venus extends CelestialBody {
  @override
  String get name => 'Venus';

  @override
  Color get color => Colors.yellow;

  @override
  double calculateLongitude(double jde) {
    double t = (jde - 2451545.0) / 365250.0;
    return _venusLongitude(t);
  }

  @override
  double calculateLatitude(double jde) {
    double t = (jde - 2451545.0) / 365250.0;
    return _venusLatitude(t);
  }

  @override
  double calculateDistance(double jde) {
    double t = (jde - 2451545.0) / 365250.0;
    return _venusRadius(t);
  }

  double _venusLongitude(double t) {
    List<List<double>> terms = [
      [3.17614667, 0.00000000, 0.00000000],
      [0.01353968, 5.59313319, 10213.28554621],
      [0.00089892, 5.30650048, 20426.57109242],
      [0.00005477, 4.41630653, 7860.41939244],
      [0.00003455, 2.69964448, 11790.62908865],
      [0.00002372, 2.99377542, 3930.20969621],
      [0.00001664, 4.25018630, 1577.34354245],
      [0.00001438, 4.15745044, 9683.59458112],
      [0.00001317, 5.18668219, 26.29831979],
      [0.00001201, 6.15357115, 30639.85663863],
    ];

    double l = 0.0;
    for (var term in terms) {
      l += term[0] * cos(term[1] + term[2] * t);
    }
    return l % (2 * pi);  // Convert to radians and normalize
  }

  double _venusLatitude(double t) {
    List<List<double>> terms = [
      [0.05923638, 0.26702477, 10213.28554621],
      [0.00040107, 1.14737178, 20426.57109242],
      [0.00032814, 3.14159265, 0.00000000],
      [0.00001011, 1.58532984, 30639.85663863],
      [0.00000985, 1.53534724, 7860.41939244],
      [0.00000502, 2.13341695, 11790.62908865],
      [0.00000490, 2.82003869, 9683.59458112],
      [0.00000456, 2.17294392, 3930.20969621],
      [0.00000274, 0.71406732, 19367.18916223],
      [0.00000103, 0.96368349, 1577.34354245],
    ];

    double b = 0.0;
    for (var term in terms) {
      b += term[0] * sin(term[1] + term[2] * t);
    }
    return b;  // Already in radians
  }

  double _venusRadius(double t) {
    List<List<double>> terms = [
      [0.72334820, 0.00000000, 0.00000000],
      [0.00489824, 4.02151832, 10213.28554621],
      [0.00001658, 4.90206728, 20426.57109242],
      [0.00001632, 2.84548652, 7860.41939244],
      [0.00001378, 1.12846591, 11790.62908865],
      [0.00000498, 2.58682188, 9683.59458112],
      [0.00000374, 1.42314832, 3930.20969621],
      [0.00000264, 5.52938186, 9437.76293488],
      [0.00000204, 4.56813164, 15720.83878487],
      [0.00000168, 2.91761810, 19367.18916223],
    ];

    double r = 0.0;
    for (var term in terms) {
      r += term[0] * cos(term[1] + term[2] * t);
    }
    return r;  // In astronomical units
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
    double h0 = -0.8333 * pi / 180.0; // 대기 굴절을 고려한 지평선 아래 각도 (라디안)
    return _calculateEventPosition(longitude, latitude, jd, observerLat, observerLon, h0, true);
  }

  List<double> _calculateSetting(double longitude, double latitude, double jd, double observerLat, double observerLon) {
    double h0 = -0.8333 * pi / 180.0; // 대기 굴절을 고려한 지평선 아래 각도 (라디안)
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
      // 떠오르지 않거나 지지 않음
      return [double.nan, double.nan];
    }

    double H0 = acos(cosH0);
    double m0 = (alpha + L - theta0) / (2 * pi);
    m0 = (m0 - m0.floor()) * 24;

    double m = isRising ? m0 - H0 * 12 / pi : m0 + H0 * 12 / pi;

    // 시간을 경도와 위도로 변환
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