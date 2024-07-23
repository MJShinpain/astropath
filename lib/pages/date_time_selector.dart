import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatefulWidget {
  final DateTime initialDateTime;
  final Function(DateTime) onDateTimeSelected;

  const DateTimeSelector({
    Key? key,
    required this.initialDateTime,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  _DateTimeSelectorState createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final DateFormat formatter = DateFormat.yMd(locale).add_Hm();
    return formatter.format(dateTime);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final List<DateTime?>? results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        selectedDayHighlightColor: Theme.of(context).primaryColor,
        weekdayLabels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        weekdayLabelTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        firstDayOfWeek: 1,
        controlsHeight: 50,
        controlsTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        dayTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        yearTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        okButton: Text(AppLocalizations.of(context)!.ok),
        cancelButton: Text(AppLocalizations.of(context)!.cancel),
      ),
      dialogSize: const Size(325, 400),
      value: [_selectedDateTime],
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null && results.isNotEmpty && results[0] != null) {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (timeOfDay != null) {
        setState(() {
          _selectedDateTime = DateTime(
            results[0]!.year,
            results[0]!.month,
            results[0]!.day,
            timeOfDay.hour,
            timeOfDay.minute,
          );
        });
        widget.onDateTimeSelected(_selectedDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.selectedDateTime,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          _formatDateTime(_selectedDateTime, context),
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.selectDateTime),
          onPressed: () => _selectDateTime(context),
        ),
      ],
    );
  }
}