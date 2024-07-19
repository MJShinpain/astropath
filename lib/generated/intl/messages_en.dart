// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(celestialBody) =>
      "Cities within 2000 km based on ${celestialBody} positions:";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("Your Romantic City"),
        "citiesWithin2000km": m0,
        "culminating": MessageLookupByLibrary.simpleMessage("Culminating:"),
        "enterBirthPlace":
            MessageLookupByLibrary.simpleMessage("Enter birth place"),
        "findRomanticCities":
            MessageLookupByLibrary.simpleMessage("Find Romantic Cities"),
        "moonCityFinder":
            MessageLookupByLibrary.simpleMessage("Moon City Finder"),
        "noCitiesWithin2000km":
            MessageLookupByLibrary.simpleMessage("No cities within 2000 km"),
        "quickAccessCities":
            MessageLookupByLibrary.simpleMessage("Quick Access Cities:"),
        "rising": MessageLookupByLibrary.simpleMessage("Rising:"),
        "selectBirthDateTime":
            MessageLookupByLibrary.simpleMessage("Select Birth Date and Time"),
        "selectedDateTime":
            MessageLookupByLibrary.simpleMessage("Selected Date and Time:"),
        "selectedLocation":
            MessageLookupByLibrary.simpleMessage("Selected Location:"),
        "setting": MessageLookupByLibrary.simpleMessage("Setting:"),
        "venusCityFinder":
            MessageLookupByLibrary.simpleMessage("Venus City Finder")
      };
}
