import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatResults(List<Map<String, dynamic>> allCities, String celestialBodyName, BuildContext context) {
  String result = AppLocalizations.of(context)!.citiesWithin2000km(celestialBodyName);
  result += '\n\n';

  if (allCities.isEmpty) {
    return result + AppLocalizations.of(context)!.noCitiesWithin2000km + '\n';
  }

  for (var i = 0; i < allCities.length; i++) {
    var cityInfo = allCities[i];
    result += '${i + 1}. ${cityInfo['city'].name}: ${cityInfo['distance'].toStringAsFixed(2)} km\n';
  }

  return result;
}