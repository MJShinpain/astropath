import 'dart:math';
import 'package:flutter/material.dart';
import 'celestial_body.dart';
import '../../utils/calculations/venus_calculations.dart';

class Venus extends CelestialBody {
  @override
  String get name => 'Venus';

  @override
  Color get color => Colors.orange[300]!;  // Venus의 특징적인 오렌지-황금빛 색상

  @override
  double calculateLongitude(double jde) {
    VenusPosition position = calculateVenusPosition(jde);
    return position.rightAscension;
  }

  @override
  double calculateLatitude(double jde) {
    VenusPosition position = calculateVenusPosition(jde);
    return position.declination;
  }

  @override
  double calculateDistance(double jde) {
    VenusPosition position = calculateVenusPosition(jde);
    return position.distance;
  }

  @override
  List<double> calculateRisingPosition(double jde, double observerLat, double observerLon) {
    return calculateVenusRisingPosition(jde, observerLat, observerLon);
  }

  @override
  List<double> calculateSettingPosition(double jde, double observerLat, double observerLon) {
    return calculateVenusSettingPosition(jde, observerLat, observerLon);
  }

  @override
  List<double> calculateCulminatingPosition(double jde, double observerLat, double observerLon) {
    return calculateVenusCulminatingPosition(jde, observerLat, observerLon);
  }

  @override
  List<double> calculateNadirPosition(double jde, double observerLat, double observerLon) {
    List<double> culminatingPos = calculateVenusCulminatingPosition(jde, observerLat, observerLon);
    double nadirLon = (culminatingPos[0] + 180) % 360;
    double nadirLat = -culminatingPos[1];

    return [nadirLon, nadirLat];
  }
}