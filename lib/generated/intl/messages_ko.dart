// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  static String m0(celestialBody) => "${celestialBody} 위치 기준 2000km 이내 도시:";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("당신의 로맨틱한 도시"),
        "citiesWithin2000km": m0,
        "cityFinder": MessageLookupByLibrary.simpleMessage("도시 찾기"),
        "culminating": MessageLookupByLibrary.simpleMessage("남중:"),
        "enterBirthPlace": MessageLookupByLibrary.simpleMessage("출생지 입력"),
        "findMoonCities": MessageLookupByLibrary.simpleMessage("달의 도시 찾기"),
        "findRomanticCities":
            MessageLookupByLibrary.simpleMessage("로맨틱한 도시 찾기"),
        "moonCityFinder": MessageLookupByLibrary.simpleMessage("달 도시 찾기"),
        "moonDescription": MessageLookupByLibrary.simpleMessage("달"),
        "noCitiesWithin2000km":
            MessageLookupByLibrary.simpleMessage("2000km 이내에 도시가 없습니다"),
        "notSelected": MessageLookupByLibrary.simpleMessage("선택되지 않음"),
        "quickAccessCities": MessageLookupByLibrary.simpleMessage("빠른 접근 도시:"),
        "rising": MessageLookupByLibrary.simpleMessage("뜨는 곳:"),
        "selectBirthDateTime":
            MessageLookupByLibrary.simpleMessage("생년월일 및 시간 선택"),
        "selectedDateTime":
            MessageLookupByLibrary.simpleMessage("선택된 날짜 및 시간:"),
        "selectedLocation": MessageLookupByLibrary.simpleMessage("선택된 위치:"),
        "setting": MessageLookupByLibrary.simpleMessage("지는 곳:"),
        "venusCityFinder": MessageLookupByLibrary.simpleMessage("금성 도시 찾기"),
        "venusDescription": MessageLookupByLibrary.simpleMessage("금성")
      };
}
