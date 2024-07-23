import 'package:flutter/material.dart';

abstract class CelestialBody {
  String get name;
  Color get color;

  double calculateLongitude(double jde);
  double calculateLatitude(double jde);
  double calculateDistance(double jde);

  List<double> calculateRisingPosition(double jde, double observerLat, double observerLon);
  List<double> calculateSettingPosition(double jde, double observerLat, double observerLon);
  List<double> calculateCulminatingPosition(double jde, double observerLat, double observerLon);
  List<double> calculateNadirPosition(double jde, double observerLat, double observerLon);  // 새로 추가된 메서드
}