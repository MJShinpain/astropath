import 'dart:math';

class MoonPosition {
  final double longitude;
  final double latitude;
  final double distance;

  MoonPosition(this.longitude, this.latitude, this.distance);
}

MoonPosition calculateMoonPosition(double jde) {
  double t = (jde - 2451545.0) / 36525.0;

  double l = _moonLongitude(t);
  double b = _moonLatitude(t);
  double r = _moonDistance(t);

  return MoonPosition(l, b, r);
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
    // Add more terms for higher accuracy
  ];

  double l = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t + t * t * t / 538841.0 - t * t * t * t / 65194000.0;

  for (var term in terms) {
    l += term[0] * sin((term[1] + term[2] * t) * pi / 180.0);
  }

  return l % 360.0;
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
    // Add more terms for higher accuracy
  ];

  double b = 0.0;

  for (var term in terms) {
    b += term[0] * sin((term[1] + term[2] * t) * pi / 180.0);
  }

  return b;
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
    // Add more terms for higher accuracy
  ];

  double r = 385000.56 + 20905.355 * cos(0.0);

  for (var term in terms) {
    r += term[0] * cos((term[1] + term[2] * t) * pi / 180.0);
  }

  return r;
}

List<double> calculateMoonRisingPosition(double longitude, double latitude, double jd, double observerLat, double observerLon) {
  double h0 = 0.125; // Moon's angular radius + atmospheric refraction
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);
  double alpha = longitude * pi / 180.0;
  double delta = latitude * pi / 180.0;

  double cosH0 = (sin(h0) - sin(phi) * sin(delta)) / (cos(phi) * cos(delta));
  if (cosH0 < -1.0 || cosH0 > 1.0) {
    // Moon doesn't rise or set
    return [double.nan, double.nan];
  }

  double H0 = acos(cosH0);
  double m0 = (alpha + L - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  double m1 = m0 - H0 * 12 / pi;

  // Convert time to longitude and latitude
  double t = m1 / 24;
  double risingLon = (t * 360 - observerLon + 360) % 360;
  double risingLat = asin(sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(H0)) * 180 / pi;

  return [risingLon, risingLat];
}

List<double> calculateMoonSettingPosition(double longitude, double latitude, double jd, double observerLat, double observerLon) {
  double h0 = 0.125; // Moon's angular radius + atmospheric refraction
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);
  double alpha = longitude * pi / 180.0;
  double delta = latitude * pi / 180.0;

  double cosH0 = (sin(h0) - sin(phi) * sin(delta)) / (cos(phi) * cos(delta));
  if (cosH0 < -1.0 || cosH0 > 1.0) {
    // Moon doesn't rise or set
    return [double.nan, double.nan];
  }

  double H0 = acos(cosH0);
  double m0 = (alpha + L - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  double m2 = m0 + H0 * 12 / pi;

  // Convert time to longitude and latitude
  double t = m2 / 24;
  double settingLon = (t * 360 - observerLon + 360) % 360;
  double settingLat = asin(sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(-H0)) * 180 / pi;

  return [settingLon, settingLat];
}

List<double> calculateMoonCulminatingPosition(double longitude, double latitude, double jd, double observerLat, double observerLon) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);
  double alpha = longitude * pi / 180.0;
  double delta = latitude * pi / 180.0;

  double m0 = (alpha + L - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  // Convert time to longitude and latitude
  double t = m0 / 24;
  double culminatingLon = (t * 360 - observerLon + 360) % 360;
  double culminatingLat = asin(sin(phi) * sin(delta) + cos(phi) * cos(delta)) * 180 / pi;

  return [culminatingLon, culminatingLat];
}

double _apparentSiderealTime(double jd) {
  double T = (jd - 2451545.0) / 36525.0;
  double theta0 = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
      0.000387933 * T * T - T * T * T / 38710000.0;
  return (theta0 % 360.0) * pi / 180.0;
}