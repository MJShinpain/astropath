import 'dart:math';

class VenusPosition {
  final double rightAscension;
  final double declination;
  final double distance;

  VenusPosition(this.rightAscension, this.declination, this.distance);
}

// VSOP87 coefficients for Venus (truncated for brevity)
final List<List<List<double>>> venusL = [
  [
    [3.17614666774, 0.00000000000, 0.00000000000],
    [0.01353968419, 5.59313319619, 10213.28554621100],
    [0.00089891645, 5.30650047764, 20426.57109242200],
    [0.00005477194, 4.41630661466, 7860.41939243920],
    [0.00003455741, 2.69964447820, 11790.62908865880],
    [0.00002372061, 2.99377542079, 3930.20969621960],
    [0.00001317168, 5.18668228402, 26.29831979980],
    [0.00001664146, 4.25018630147, 1577.34354244780],
    [0.00001438387, 4.15745084182, 9683.59458111640],
    [0.00001200521, 6.15357116043, 30639.85663863300],
  ],
  [
    [6283.07584999140, 0.00000000000, 0.00000000000],
    [0.00095706, 5.77481, 10213.28555],
    [0.00054164, 5.97324, 20426.57109],
    [0.00003151, 5.57263, 30639.85663],
  ],
];

final List<List<List<double>>> venusB = [
  [
    [0.05923638472, 0.26702775812, 10213.28554621100],
    [0.00040107978, 1.14737178112, 20426.57109242200],
    [0.00032814918, 3.14159265359, 0.00000000000],
    [0.00001011392, 1.08933256909, 30639.85663863300],
  ],
  [
    [0.00287821, 1.88508, 10213.28555],
    [0.00004775, 3.67757, 20426.57109],
  ],
];

final List<List<List<double>>> venusR = [
  [
    [0.72334820891, 0.00000000000, 0.00000000000],
    [0.00489824182, 4.02151831717, 10213.28554621100],
    [0.00001658058, 4.90206728031, 20426.57109242200],
    [0.00001378043, 1.12846591367, 11790.62908865880],
    [0.00001632096, 2.84548795207, 7860.41939243920],
    [0.00000498395, 2.58682193892, 9683.59458111640],
    [0.00000221985, 2.01346696541, 19367.18916223280],
    [0.00000237454, 2.55136053886, 15720.83878487840],
  ],
  [
    [0.00034551, 0.89199, 10213.28555],
    [0.00000234, 1.77238, 20426.57109],
  ],
];

double _calculateVSOP87Term(List<List<double>> terms, double t) {
  double result = 0.0;
  for (var term in terms) {
    result += term[0] * cos(term[1] + term[2] * t);
  }
  return result;
}

VenusPosition calculateVenusPosition(double jde) {
  double t = (jde - 2451545.0) / 365250.0;

  double L = 0.0;
  double B = 0.0;
  double R = 0.0;

  for (int i = 0; i < venusL.length; i++) {
    L += _calculateVSOP87Term(venusL[i], t) * pow(t, i);
  }

  for (int i = 0; i < venusB.length; i++) {
    B += _calculateVSOP87Term(venusB[i], t) * pow(t, i);
  }

  for (int i = 0; i < venusR.length; i++) {
    R += _calculateVSOP87Term(venusR[i], t) * pow(t, i);
  }

  L = (L % (2 * pi) + 2 * pi) % (2 * pi);

  // Convert heliocentric ecliptic coordinates to equatorial coordinates
  double epsilon = 23.4392911 * pi / 180; // obliquity of the ecliptic
  double X = R * cos(B) * cos(L);
  double Y = R * (cos(B) * sin(L) * cos(epsilon) - sin(B) * sin(epsilon));
  double Z = R * (cos(B) * sin(L) * sin(epsilon) + sin(B) * cos(epsilon));

  double alpha = atan2(Y, X);
  double delta = atan2(Z, sqrt(X * X + Y * Y));

  // Convert to degrees
  alpha = alpha * 180 / pi;
  if (alpha < 0) alpha += 360;
  delta = delta * 180 / pi;

  return VenusPosition(alpha, delta, R);
}

List<double> calculateVenusRisingPosition(double jd, double observerLat, double observerLon) {
  double h0 = -0.5667; // Standard altitude for rising/setting of a planet
  VenusPosition venusPos = calculateVenusPosition(jd);

  return _calculateRisingPosition(venusPos.rightAscension, venusPos.declination, jd, observerLat, observerLon, h0);
}

List<double> calculateVenusSettingPosition(double jd, double observerLat, double observerLon) {
  double h0 = -0.5667; // Standard altitude for rising/setting of a planet
  VenusPosition venusPos = calculateVenusPosition(jd);

  return _calculateSettingPosition(venusPos.rightAscension, venusPos.declination, jd, observerLat, observerLon, h0);
}

List<double> calculateVenusCulminatingPosition(double jd, double observerLat, double observerLon) {
  VenusPosition venusPos = calculateVenusPosition(jd);

  return _calculateCulminatingPosition(venusPos.rightAscension, venusPos.declination, jd, observerLat, observerLon);
}

List<double> calculateVenusNadirPosition(double jd, double observerLat, double observerLon) {
  VenusPosition venusPos = calculateVenusPosition(jd);

  return _calculateNadirPosition(venusPos.rightAscension, venusPos.declination, jd, observerLat, observerLon);
}

List<double> _calculateRisingPosition(double alpha, double delta, double jd, double observerLat, double observerLon, double h0) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  double cosH0 = (sin(h0 * pi / 180) - sin(phi) * sin(delta * pi / 180)) / (cos(phi) * cos(delta * pi / 180));
  if (cosH0 < -1.0 || cosH0 > 1.0) {
    return [double.nan, double.nan];
  }

  double H0 = acos(cosH0);
  double m0 = (alpha * 15 + L * 180 / pi - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  double m1 = m0 - H0 * 12 / pi;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdRise = jd + m1 / 24.0;
    VenusPosition venusPos = calculateVenusPosition(jdRise);
    double correction = (venusPos.rightAscension - alpha) / (2 * pi);
    m1 += correction * 24;
  }

  // Convert time to longitude and latitude
  double t = m1 / 24;
  double risingLon = (t * 360 - observerLon + 360) % 360;
  double risingLat = asin(sin(phi) * sin(delta * pi / 180) + cos(phi) * cos(delta * pi / 180) * cos(H0)) * 180 / pi;

  return [risingLon, risingLat];
}

List<double> _calculateSettingPosition(double alpha, double delta, double jd, double observerLat, double observerLon, double h0) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  double cosH0 = (sin(h0 * pi / 180) - sin(phi) * sin(delta * pi / 180)) / (cos(phi) * cos(delta * pi / 180));
  if (cosH0 < -1.0 || cosH0 > 1.0) {
    return [double.nan, double.nan];
  }

  double H0 = acos(cosH0);
  double m0 = (alpha * 15 + L * 180 / pi - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  double m2 = m0 + H0 * 12 / pi;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdSet = jd + m2 / 24.0;
    VenusPosition venusPos = calculateVenusPosition(jdSet);
    double correction = (venusPos.rightAscension - alpha) / (2 * pi);
    m2 += correction * 24;
  }

  // Convert time to longitude and latitude
  double t = m2 / 24;
  double settingLon = (t * 360 - observerLon + 360) % 360;
  double settingLat = asin(sin(phi) * sin(delta * pi / 180) + cos(phi) * cos(delta * pi / 180) * cos(-H0)) * 180 / pi;

  return [settingLon, settingLat];
}

List<double> _calculateCulminatingPosition(double alpha, double delta, double jd, double observerLat, double observerLon) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  double m0 = (alpha * 15 + L * 180 / pi - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdCulm = jd + m0 / 24.0;
    VenusPosition venusPos = calculateVenusPosition(jdCulm);
    double correction = (venusPos.rightAscension - alpha) / (2 * pi);
    m0 += correction * 24;
  }

  // Convert time to longitude and latitude
  double t = m0 / 24;
  double culminatingLon = (t * 360 - observerLon + 360) % 360;
  double culminatingLat = asin(sin(phi) * sin(delta * pi / 180) + cos(phi) * cos(delta * pi / 180)) * 180 / pi;

  return [culminatingLon, culminatingLat];
}

List<double> _calculateNadirPosition(double alpha, double delta, double jd, double observerLat, double observerLon) {
  double phi = observerLat * pi / 180.0;
  double L = observerLon * pi / 180.0;

  double theta0 = _apparentSiderealTime(jd);

  // Nadir occurs 12 hours after culmination
  double m0 = (alpha * 15 + L * 180 / pi - theta0) / (2 * pi);
  m0 = (m0 - m0.floor()) * 24;
  double m_nadir = m0 + 12;  // 12 hours after culmination
  if (m_nadir >= 24) m_nadir -= 24;

  // Iterate to improve accuracy
  for (int i = 0; i < 5; i++) {
    double jdNadir = jd + m_nadir / 24.0;
    VenusPosition venusPos = calculateVenusPosition(jdNadir);
    double correction = (venusPos.rightAscension - alpha) / (2 * pi);
    m_nadir += correction * 24;
    if (m_nadir >= 24) m_nadir -= 24;
  }

  // Convert time to longitude and latitude
  double t = m_nadir / 24;
  double nadirLon = (t * 360 - observerLon + 360) % 360;
  // For nadir, we use the negative of the culmination latitude
  double nadirLat = -asin(sin(phi) * sin(delta * pi / 180) + cos(phi) * cos(delta * pi / 180)) * 180 / pi;

  return [nadirLon, nadirLat];
}

double _apparentSiderealTime(double jd) {
  double T = (jd - 2451545.0) / 36525.0;
  double theta0 = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
      0.000387933 * T * T - T * T * T / 38710000.0;
  return (theta0 % 360.0) * pi / 180.0;
}