import 'dart:math';

class MoonPosition {
  final double rightAscension;
  final double declination;
  final double distance;

  MoonPosition(this.rightAscension, this.declination, this.distance);
}

MoonPosition calculateMoonPosition(double jde) {
  double T = (jde - 2451545.0) / 36525.0;
  double L1 = _moonMeanLongitude(T);
  double D = _moonMeanElongation(T);
  double M = _sunMeanAnomaly(T);
  double M1 = _moonMeanAnomaly(T);
  double F = _moonArgumentOfLatitude(T);

  double A1 = 119.75 + 131.849 * T;
  double A2 = 53.09 + 479264.290 * T;
  double A3 = 313.45 + 481266.484 * T;

  double E = 1 - 0.002516 * T - 0.0000074 * T * T;

  double lambda = L1 + _calculatePeriodicTerms(D, M, M1, F, E);
  double beta = _calculateLatitudeTerms(L1, D, M, M1, F, E);
  double distance = _calculateDistanceTerms(D, M, M1, F, E);

  // Convert ecliptic coordinates to equatorial coordinates
  double epsilon = _obliquity(T);
  double alpha = atan2(sin(lambda * pi / 180) * cos(epsilon) - tan(beta * pi / 180) * sin(epsilon), cos(lambda * pi / 180));
  double delta = asin(sin(beta * pi / 180) * cos(epsilon) + cos(beta * pi / 180) * sin(epsilon) * sin(lambda * pi / 180));

  return MoonPosition(alpha, delta, distance);
}

double _moonMeanLongitude(double T) {
  return 218.3164477 + 481267.88123421 * T - 0.0015786 * T * T + T * T * T / 538841.0 - T * T * T * T / 65194000.0;
}

double _moonMeanElongation(double T) {
  return 297.8501921 + 445267.1114034 * T - 0.0018819 * T * T + T * T * T / 545868.0 - T * T * T * T / 113065000.0;
}

double _sunMeanAnomaly(double T) {
  return 357.5291092 + 35999.0502909 * T - 0.0001536 * T * T + T * T * T / 24490000.0;
}

double _moonMeanAnomaly(double T) {
  return 134.9633964 + 477198.8675055 * T + 0.0087414 * T * T + T * T * T / 69699.0 - T * T * T * T / 14712000.0;
}

double _moonArgumentOfLatitude(double T) {
  return 93.2720950 + 483202.0175233 * T - 0.0036539 * T * T - T * T * T / 3526000.0 + T * T * T * T / 863310000.0;
}

double _obliquity(double T) {
  return (23.43929111 - 0.01300416667 * T - 0.00000016389 * T * T + 0.00000050361 * T * T * T) * pi / 180;
}

double _calculatePeriodicTerms(double D, double M, double M1, double F, double E) {
  List<List<double>> terms = [
    [0, 0, 1, 0, 6288774, -20905355],
    [2, 0, -1, 0, 1274027, -3699111],
    [2, 0, 0, 0, 658314, -2955968],
    [0, 0, 2, 0, 213618, -569925],
    [0, 1, 0, 0, -185116, 48888],
    [0, 0, 0, 2, -114332, -3149],
    [2, 0, -2, 0, 58793, 246158],
    [2, -1, -1, 0, 57066, -152138],
    [2, 0, 1, 0, 53322, -170733],
    [2, -1, 0, 0, 45758, -204586],
    [0, 1, -1, 0, -40923, -129620],
    [1, 0, 0, 0, -34720, 108743],
    [0, 1, 1, 0, -30383, 104755],
    [2, 0, 0, -2, 15327, 10321],
    [0, 0, 1, 2, -12528, 0],
    [0, 0, 1, -2, 10980, 79661],
    [4, 0, -1, 0, 10675, -34782],
    [0, 0, 3, 0, 10034, -23210],
    [4, 0, -2, 0, 8548, -21636],
    [2, 1, -1, 0, -7888, 24208],
    [2, 1, 0, 0, -6766, 30824],
    [1, 0, -1, 0, -5163, -8379],
    [1, 1, 0, 0, 4987, -16675],
    [2, -1, 1, 0, 4036, -12831],
    [2, 0, 2, 0, 3994, -10445],
    [4, 0, 0, 0, 3861, -11650],
    [2, 0, -3, 0, 3665, 14403],
    [0, 1, -2, 0, -2689, -7003],
    [2, 0, -1, 2, -2602, 0],
    [2, -1, -2, 0, 2390, 10056],
    [1, 0, 1, 0, -2348, 6322],
    [2, -2, 0, 0, 2236, -9884],
    [0, 1, 2, 0, -2120, 5751],
    [0, 2, 0, 0, -2069, 0],
    [2, -2, -1, 0, 2048, -4950],
    [2, 0, 1, -2, -1773, 4130],
    [2, 0, 0, 2, -1595, 0],
    [4, -1, -1, 0, 1215, -3958],
    [0, 0, 2, 2, -1110, 0],
    [3, 0, -1, 0, -892, 3258],
    [2, 1, 1, 0, -810, 2616],
    [4, -1, -2, 0, 759, -1897],
    [0, 2, -1, 0, -713, -2117],
    [2, 2, -1, 0, -700, 2354],
    [2, 1, -2, 0, 691, 0],
    [2, -1, 0, -2, 596, 0],
    [4, 0, 1, 0, 549, -1423],
    [0, 0, 4, 0, 537, -1117],
    [4, -1, 0, 0, 520, -1571],
    [1, 0, -2, 0, -487, -1739],
    [2, 1, 0, -2, -399, 0],
    [0, 0, 2, -2, -381, -4421],
    [1, 1, 1, 0, 351, 0],
    [3, 0, -2, 0, -340, 0],
    [4, 0, -3, 0, 330, 0],
    [2, -1, 2, 0, 327, 0],
    [0, 2, 1, 0, -323, 1165],
    [1, 1, -1, 0, 299, 0],
    [2, 0, 3, 0, 294, 0],
    [2, 0, -1, -2, 0, 8752]
  ];

  double result = 0.0;
  for (var term in terms) {
    double argument = term[0] * D + term[1] * M + term[2] * M1 + term[3] * F;
    double sinCoeff = term[4];
    if (term[1] != 0) {
      sinCoeff *= pow(E, term[1].abs());
    }
    result += sinCoeff * sin(argument * pi / 180);
  }
  return result / 1000000.0;
}

double _calculateLatitudeTerms(double L1, double D, double M, double M1, double F, double E) {
  List<List<double>> terms = [
    [0, 0, 0, 1, 5128122],
    [0, 0, 1, 1, 280602],
    [0, 0, 1, -1, 277693],
    [2, 0, 0, -1, 173237],
    [2, 0, -1, 1, 55413],
    [2, 0, -1, -1, 46271],
    [2, 0, 0, 1, 32573],
    [0, 0, 2, 1, 17198],
    [2, 0, 1, -1, 9266],
    [0, 0, 2, -1, 8822],
    [2, -1, 0, -1, 8216],
    [2, 0, -2, -1, 4324],
    [2, 0, 1, 1, 4200],
    [2, 1, 0, -1, -3359],
    [2, -1, -1, 1, 2463],
    [2, -1, 0, 1, 2211],
    [2, -1, -1, -1, 2065],
    [0, 1, -1, -1, -1870],
    [4, 0, -1, -1, 1828],
    [0, 1, 0, 1, -1794],
    [0, 0, 0, 3, -1749],
    [0, 1, -1, 1, -1565],
    [1, 0, 0, 1, -1491],
    [0, 1, 1, 1, -1475],
    [0, 1, 1, -1, -1410],
    [0, 1, 0, -1, -1344],
    [1, 0, 0, -1, -1335],
    [0, 0, 3, 1, 1107],
    [4, 0, 0, -1, 1021],
    [4, 0, -1, 1, 833],
    [0, 0, 1, -3, 777],
    [4, 0, -2, 1, 671],
    [2, 0, 0, -3, 607],
    [2, 0, 2, -1, 596],
    [2, -1, 1, -1, 491],
    [2, 0, -2, 1, -451],
    [0, 0, 3, -1, 439],
    [2, 0, 2, 1, 422],
    [2, 0, -3, -1, 421],
    [2, 1, -1, 1, -366],
    [2, 1, 0, 1, -351],
    [4, 0, 0, 1, 331],
    [2, -1, 1, 1, 315],
    [2, -2, 0, -1, 302],
    [0, 0, 1, 3, -283],
    [2, 1, 1, -1, -229],
    [1, 1, 0, -1, 223],
    [1, 1, 0, 1, 223],
    [0, 1, -2, -1, -220],
    [2, 1, -1, -1, -220],
    [1, 0, 1, 1, -185],
    [2, -1, -2, -1, 181],
    [0, 1, 2, 1, -177],
    [4, 0, -2, -1, 176],
    [4, -1, -1, -1, 166],
    [1, 0, 1, -1, -164],
    [4, 0, 1, -1, 132],
    [1, 0, -1, -1, -119],
    [4, -1, 0, -1, 115],
    [2, -2, 0, 1, 107]
  ];

  double result = 0.0;
  for (var term in terms) {
    double argument = term[0] * D + term[1] * M + term[2] * M1 + term[3] * F;
    double sinCoeff = term[4];
    if (term[1] != 0) {
      sinCoeff *= pow(E, term[1].abs());
    }
    result += sinCoeff * sin(argument * pi / 180);
  }
  return result / 1000000.0;
}

double _calculateDistanceTerms(double D, double M, double M1, double F, double E) {
  List<List<double>> terms = [
    [0, 0, 1, 0, -20905355],
    [2, 0, -1, 0, -3699111],
    [2, 0, 0, 0, -2955968],
    [0, 0, 2, 0, -569925],
    [0, 1, 0, 0, 48888],
    [0, 0, 0, 2, -3149],
    [2, 0, -2, 0, 246158],
    [2, -1, -1, 0, -152138],
    [2, 0, 1, 0, -170733],
    [2, -1, 0, 0, -204586],
    [0, 1, -1, 0, -129620],
    [1, 0, 0, 0, 108743],
    [0, 1, 1, 0, 104755],
    [2, 0, 0, -2, 10321],
    [0, 0, 1, 2, 0],
    [0, 0, 1, -2, 79661],
    [4, 0, -1, 0, -34782],
    [0, 0, 3, 0, -23210],
    [4, 0, -2, 0, -21636],
    [2, 1, -1, 0, 24208],
    [2, 1, 0, 0, 30824],
    [1, 0, -1, 0, -8379],
    [1, 1, 0, 0, -16675],
    [2, -1, 1, 0, -12831],
    [2, 0, 2, 0, -10445],
    [4, 0, 0, 0, -11650],
    [2, 0, -3, 0, 14403],
    [0, 1, -2, 0, -7003],
    [2, 0, -1, 2, 0],
    [2, -1, -2, 0, 10056],
    [1, 0, 1, 0, 6322],
    [2, -2, 0, 0, -9884],
    [0, 1, 2, 0, 5751],
    [0, 2, 0, 0, 0],
    [2, -2, -1, 0, -4950],
    [2, 0, 1, -2, 4130],
    [2, 0, 0, 2, 0],
    [4, -1, -1, 0, -3958],
    [0, 0, 2, 2, 0],
    [3, 0, -1, 0, 3258],
    [2, 1, 1, 0, 2616],
    [4, -1, -2, 0, -1897],
    [0, 2, -1, 0, -2117],
    [2, 2, -1, 0, 2354],
    [2, 1, -2, 0, 0],
    [2, -1, 0, -2, 0],
    [4, 0, 1, 0, -1423],
    [0, 0, 4, 0, -1117],
    [4, -1, 0, 0, -1571],
    [1, 0, -2, 0, -1739],
    [2, 1, 0, -2, 0],
    [0, 0, 2, -2, -4421],
    [1, 1, 1, 0, 0],
    [3, 0, -2, 0, 0],
    [4, 0, -3, 0, 0],
    [2, -1, 2, 0, 0],
    [0, 2, 1, 0, 1165],
    [1, 1, -1, 0, 0],
    [2, 0, 3, 0, 0],
    [2, 0, -1, -2, 8752]
  ];

  double result = 385000.56; // Moon's mean distance in km
  for (var term in terms) {
    double argument = term[0] * D + term[1] * M + term[2] * M1 + term[3] * F;
    double cosCoeff = term[4];
    if (term[1] != 0) {
      cosCoeff *= pow(E, term[1].abs());
    }
    result += cosCoeff * cos(argument * pi / 180) / 1000;
  }
  return result;
}

List<double> calculateMoonRisingPosition(double jd, double observerLat, double observerLon) {
  double h0 = 0.125; // Moon's angular radius + atmospheric refraction
  MoonPosition moonPos = calculateMoonPosition(jd);

  return _calculateRisingPosition(moonPos.rightAscension, moonPos.declination, jd, observerLat, observerLon, h0);
}

List<double> calculateMoonSettingPosition(double jd, double observerLat, double observerLon) {
  double h0 = 0.125; // Moon's angular radius + atmospheric refraction
  MoonPosition moonPos = calculateMoonPosition(jd);

  return _calculateSettingPosition(moonPos.rightAscension, moonPos.declination, jd, observerLat, observerLon, h0);
}

List<double> calculateMoonCulminatingPosition(double jd, double observerLat, double observerLon) {
  MoonPosition moonPos = calculateMoonPosition(jd);

  return _calculateCulminatingPosition(moonPos.rightAscension, moonPos.declination, jd, observerLat, observerLon);
}

List<double> _calculateRisingPosition(double alpha, double delta, double jd, double observerLat, double observerLon, double h0) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  double cosH0 = (sin(h0 * pi / 180) - sin(phi) * sin(delta)) / (cos(phi) * cos(delta));
  if (cosH0 < -1.0 || cosH0 > 1.0) {
    return [double.nan, double.nan];
  }

  double H0 = acos(cosH0);
  double m0 = (alpha + L - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  double m1 = m0 - H0 * 12 / pi;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdRise = jd + m1 / 24.0;
    MoonPosition moonPos = calculateMoonPosition(jdRise);
    double correction = (moonPos.rightAscension - alpha) / (2 * pi);
    m1 += correction * 24;
  }

  // Convert time to longitude and latitude
  double t = m1 / 24;
  double risingLon = (t * 360 - observerLon + 360) % 360;
  double risingLat = asin(sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(H0)) * 180 / pi;

  return [risingLon, risingLat];
}

List<double> _calculateSettingPosition(double alpha, double delta, double jd, double observerLat, double observerLon, double h0) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  double cosH0 = (sin(h0 * pi / 180) - sin(phi) * sin(delta)) / (cos(phi) * cos(delta));
  if (cosH0 < -1.0 || cosH0 > 1.0) {
    return [double.nan, double.nan];
  }

  double H0 = acos(cosH0);
  double m0 = (alpha + L - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  // The main difference from rising calculation is here:
  double m2 = m0 + H0 * 12 / pi;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdSet = jd + m2 / 24.0;
    MoonPosition moonPos = calculateMoonPosition(jdSet);
    double correction = (moonPos.rightAscension - alpha) / (2 * pi);
    m2 += correction * 24;
  }

  // Convert time to longitude and latitude
  double t = m2 / 24;
  double settingLon = (t * 360 - observerLon + 360) % 360;
  // Note the negative H0 here, which is different from the rising calculation
  double settingLat = asin(sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(-H0)) * 180 / pi;

  return [settingLon, settingLat];
}

List<double> _calculateCulminatingPosition(double alpha, double delta, double jd, double observerLat, double observerLon) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  double m0 = (alpha + L - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdCulm = jd + m0 / 24.0;
    MoonPosition moonPos = calculateMoonPosition(jdCulm);
    double correction = (moonPos.rightAscension - alpha) / (2 * pi);
    m0 += correction * 24;
  }

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