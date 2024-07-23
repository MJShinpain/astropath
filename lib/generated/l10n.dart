// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Your Romantic City`
  String get appTitle {
    return Intl.message(
      'Your Romantic City',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Venus City Finder`
  String get venusCityFinder {
    return Intl.message(
      'Venus City Finder',
      name: 'venusCityFinder',
      desc: '',
      args: [],
    );
  }

  /// `Moon City Finder`
  String get moonCityFinder {
    return Intl.message(
      'Moon City Finder',
      name: 'moonCityFinder',
      desc: '',
      args: [],
    );
  }

  /// `Enter birth place`
  String get enterBirthPlace {
    return Intl.message(
      'Enter birth place',
      name: 'enterBirthPlace',
      desc: '',
      args: [],
    );
  }

  /// `Quick Access Cities:`
  String get quickAccessCities {
    return Intl.message(
      'Quick Access Cities:',
      name: 'quickAccessCities',
      desc: '',
      args: [],
    );
  }

  /// `Selected Location:`
  String get selectedLocation {
    return Intl.message(
      'Selected Location:',
      name: 'selectedLocation',
      desc: '',
      args: [],
    );
  }

  /// `Not selected`
  String get notSelected {
    return Intl.message(
      'Not selected',
      name: 'notSelected',
      desc: '',
      args: [],
    );
  }

  /// `Select Birth Date and Time`
  String get selectBirthDateTime {
    return Intl.message(
      'Select Birth Date and Time',
      name: 'selectBirthDateTime',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message(
      'Select Date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Time`
  String get selectTime {
    return Intl.message(
      'Select Time',
      name: 'selectTime',
      desc: '',
      args: [],
    );
  }

  /// `enter date and time`
  String get enterDateTime {
    return Intl.message(
      'enter date and time',
      name: 'enterDateTime',
      desc: '',
      args: [],
    );
  }

  /// `select date and time`
  String get selectDateTime {
    return Intl.message(
      'select date and time',
      name: 'selectDateTime',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `year`
  String get year {
    return Intl.message(
      'year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `month`
  String get month {
    return Intl.message(
      'month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get day {
    return Intl.message(
      'day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get hour {
    return Intl.message(
      'hour',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `minute`
  String get minute {
    return Intl.message(
      'minute',
      name: 'minute',
      desc: '',
      args: [],
    );
  }

  /// `Selected Date and Time:`
  String get selectedDateTime {
    return Intl.message(
      'Selected Date and Time:',
      name: 'selectedDateTime',
      desc: '',
      args: [],
    );
  }

  /// `Find Romantic Cities`
  String get findRomanticCities {
    return Intl.message(
      'Find Romantic Cities',
      name: 'findRomanticCities',
      desc: '',
      args: [],
    );
  }

  /// `Find Moon Cities`
  String get findMoonCities {
    return Intl.message(
      'Find Moon Cities',
      name: 'findMoonCities',
      desc: '',
      args: [],
    );
  }

  /// `Cities within 2000 km based on {celestialBody} positions:`
  String citiesWithin2000km(String celestialBody) {
    return Intl.message(
      'Cities within 2000 km based on $celestialBody positions:',
      name: 'citiesWithin2000km',
      desc: '',
      args: [celestialBody],
    );
  }

  /// `Rising`
  String get rising {
    return Intl.message(
      'Rising',
      name: 'rising',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Culminating`
  String get culminating {
    return Intl.message(
      'Culminating',
      name: 'culminating',
      desc: '',
      args: [],
    );
  }

  /// `No cities within 2000 km`
  String get noCitiesWithin2000km {
    return Intl.message(
      'No cities within 2000 km',
      name: 'noCitiesWithin2000km',
      desc: '',
      args: [],
    );
  }

  /// `City Finder`
  String get cityFinder {
    return Intl.message(
      'City Finder',
      name: 'cityFinder',
      desc: '',
      args: [],
    );
  }

  /// `Venus`
  String get venusDescription {
    return Intl.message(
      'Venus',
      name: 'venusDescription',
      desc: '',
      args: [],
    );
  }

  /// `Moon`
  String get moonDescription {
    return Intl.message(
      'Moon',
      name: 'moonDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ko'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
