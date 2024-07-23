import 'dart:math';
import 'package:flutter/material.dart';
import 'celestial_body.dart';
import '../../utils/calculations/moon_calculations.dart';

class Moon extends CelestialBody {
  @override
  String get name => 'Moon';

  @override
  Color get color => Colors.grey;

  @override
  double calculateLongitude(double jde) {
    MoonPosition position = calculateMoonPosition(jde);
    return position.rightAscension;
  }

  @override
  double calculateLatitude(double jde) {
    MoonPosition position = calculateMoonPosition(jde);
    return position.declination;
  }

  @override
  double calculateDistance(double jde) {
    MoonPosition position = calculateMoonPosition(jde);
    return position.distance;
  }

  @override
  List<double> calculateRisingPosition(double jde, double observerLat, double observerLon) {
    return calculateMoonRisingPosition(jde, observerLat, observerLon);
  }

  @override
  List<double> calculateSettingPosition(double jde, double observerLat, double observerLon) {
    return calculateMoonSettingPosition(jde, observerLat, observerLon);
  }

  @override
  List<double> calculateCulminatingPosition(double jde, double observerLat, double observerLon) {
    return calculateMoonCulminatingPosition(jde, observerLat, observerLon);
  }

  @override
  List<double> calculateNadirPosition(double jde, double observerLat, double observerLon) {
    List<double> culminatingPos = calculateMoonCulminatingPosition(jde, observerLat, observerLon);
    double nadirLon = (culminatingPos[0] + 180) % 360; // 경도에 180도 추가
    double nadirLat = -culminatingPos[1]; // 위도의 부호를 바꿈

    return [nadirLon, nadirLat];
  }
}