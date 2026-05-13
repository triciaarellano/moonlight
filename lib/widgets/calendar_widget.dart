import 'package:flutter/material.dart';
import 'dart:async';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<int> daysWithSchedule;
  final List<int> daysWithNotes;
  final Map<int, List<String>> schedulesByDay;
  final Map<int, List<String>> notesByDay;
  final Color monthTextColor;
  final Color navigationIconColor;
  final Color weekdayTextColor;
  final Color weekendTextColor;
  final Color dayTextColor;
  final Color mutedDayTextColor;
  final Color selectedDayColor;
  final Color selectedDayTextColor;
  final Color? todayFillColor;
  final Color? todayBorderColor;
  final Color scheduleDotColor;
  final Color noteDotColor;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysWithSchedule = const [],
    this.daysWithNotes = const [],
    this.schedulesByDay = const {},
    this.notesByDay = const {},
    this.monthTextColor = Colors.white,
    this.navigationIconColor = Colors.white,
    this.weekdayTextColor = Colors.white,
    this.weekendTextColor = Colors.red,
    this.dayTextColor = Colors.white,
    this.mutedDayTextColor = const Color(0xFF616161),
    this.selectedDayColor = const Color(0xFF7C5FDD),
    this.selectedDayTextColor = Colors.white,
    this.todayFillColor,
    this.todayBorderColor,
    this.scheduleDotColor = const Color(0xFFB5A957),
    this.noteDotColor = const Color(0xFF7C5FDD),
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Timer _timer;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
    // Rebuild every minute to update "today" highlighting
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _todayMonth() {
    setState(() {
      final now = DateTime.now();
      _displayedMonth = DateTime(now.year, now.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = _formatMonthYear(_displayedMonth);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstDayWeekday =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    final todayFillColor = widget.todayFillColor ??
        widget.selectedDayColor.withValues(alpha: 0.25);
    final todayBorderColor = widget.todayBorderColor ??
        widget.selectedDayColor.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: widget.navigationIconColor),
              iconSize: 22,
              onPressed: _previousMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            GestureDetector(
              onTap: _todayMonth,
              child: Text(
                monthYear,
                style: TextStyle(
                  color: widget.monthTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            IconButton(
              icon:
                  Icon(Icons.chevron_right, color: widget.navigationIconColor),
              iconSize: 22,
              onPressed: _nextMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _WeekdayHeader(
              'SUN',
              isWeekend: true,
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
            _WeekdayHeader(
              'MON',
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
            _WeekdayHeader(
              'TUE',
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
            _WeekdayHeader(
              'WED',
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
            _WeekdayHeader(
              'THU',
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
            _WeekdayHeader(
              'FRI',
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
            _WeekdayHeader(
              'SAT',
              isWeekend: true,
              weekdayTextColor: widget.weekdayTextColor,
              weekendTextColor: widget.weekendTextColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.85,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayNum = index - firstDayWeekday + 2;
            final isCurrentMonth = dayNum > 0 && dayNum <= daysInMonth;
            final displayDay = isCurrentMonth
                ? dayNum
                : (dayNum > daysInMonth
                    ? dayNum - daysInMonth
                    : dayNum +
                        DateTime(
                          _displayedMonth.year,
                          _displayedMonth.month,
                          0,
                        ).day);

            final isToday = isCurrentMonth &&
                dayNum == now.day &&
                _displayedMonth.month == now.month &&
                _displayedMonth.year == now.year;

            final isSelected = isCurrentMonth &&
                dayNum == widget.selectedDate.day &&
                _displayedMonth.month == widget.selectedDate.month &&
                _displayedMonth.year == widget.selectedDate.year;

            final scheduleTitles = isCurrentMonth
                ? (widget.schedulesByDay[dayNum] ?? const <String>[])
                : const <String>[];
            final noteTitles = isCurrentMonth
                ? (widget.notesByDay[dayNum] ?? const <String>[])
                : const <String>[];
            final hasSchedule = isCurrentMonth &&
                (scheduleTitles.isNotEmpty ||
                    widget.daysWithSchedule.contains(dayNum));
            final hasNotes = isCurrentMonth &&
                (noteTitles.isNotEmpty ||
                    widget.daysWithNotes.contains(dayNum));

            return GestureDetector(
              onTap: isCurrentMonth
                  ? () => widget.onDateSelected(
                        DateTime(
                          _displayedMonth.year,
                          _displayedMonth.month,
                          dayNum,
                        ),
                      )
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? widget.selectedDayColor
                      : (isToday ? todayFillColor : Colors.transparent),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: todayBorderColor,
                          width: 1.5,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      displayDay.toString(),
                      style: TextStyle(
                        color: !isCurrentMonth
                            ? widget.mutedDayTextColor
                            : (isSelected
                                ? widget.selectedDayTextColor
                                : (index % 7 == 0
                                    ? widget.weekendTextColor
                                    : widget.dayTextColor)),
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (hasSchedule || hasNotes)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasSchedule)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ).copyWith(color: widget.scheduleDotColor),
                              ),
                            if (hasSchedule && hasNotes)
                              const SizedBox(width: 2),
                            if (hasNotes)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ).copyWith(color: widget.noteDotColor),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String label;
  final bool isWeekend;
  final Color weekdayTextColor;
  final Color weekendTextColor;

  const _WeekdayHeader(
    this.label, {
    this.isWeekend = false,
    required this.weekdayTextColor,
    required this.weekendTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isWeekend ? weekendTextColor : weekdayTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
