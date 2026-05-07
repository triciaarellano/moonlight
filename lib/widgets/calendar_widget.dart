import 'package:flutter/material.dart';
import 'dart:async';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<int> daysWithSchedule;
  final List<int> daysWithNotes;
  final Map<int, List<String>> schedulesByDay;
  final Map<int, List<String>> notesByDay;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysWithSchedule = const [],
    this.daysWithNotes = const [],
    this.schedulesByDay = const {},
    this.notesByDay = const {},
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month/Year header with navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              iconSize: 22,
              onPressed: _previousMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            GestureDetector(
              onTap: _todayMonth,
              child: Text(
                monthYear,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              iconSize: 22,
              onPressed: _nextMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _WeekdayHeader('SUN', isWeekend: true),
            _WeekdayHeader('MON'),
            _WeekdayHeader('TUE'),
            _WeekdayHeader('WED'),
            _WeekdayHeader('THU'),
            _WeekdayHeader('FRI'),
            _WeekdayHeader('SAT', isWeekend: true),
          ],
        ),
        const SizedBox(height: 10),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.3,
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
                        DateTime(_displayedMonth.year, _displayedMonth.month, 0)
                            .day);

            final isToday = isCurrentMonth &&
                dayNum == now.day &&
                _displayedMonth.month == now.month &&
                _displayedMonth.year == now.year;

            final isSelected = isCurrentMonth &&
                dayNum == widget.selectedDate.day &&
                _displayedMonth.month == widget.selectedDate.month &&
                _displayedMonth.year == widget.selectedDate.year;

            return GestureDetector(
                onTap: isCurrentMonth
                    ? () => widget.onDateSelected(DateTime(
                        _displayedMonth.year, _displayedMonth.month, dayNum))
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF7C5FDD)
                        : (isToday
                            ? const Color(0xFF7C5FDD).withValues(alpha: 0.25)
                            : Colors.transparent),
                    border: isToday && !isSelected
                        ? Border.all(
                            color:
                                const Color(0xFF7C5FDD).withValues(alpha: 0.5),
                            width: 1.5,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        displayDay.toString(),
                        style: TextStyle(
                          color: !isCurrentMonth
                              ? Colors.grey.shade700
                              : (index % 7 == 0
                                  ? Colors.red[300]
                                  : Colors.white),
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Display schedule titles for this day
                      if (isCurrentMonth &&
                          widget.schedulesByDay.containsKey(dayNum))
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: (widget.schedulesByDay[dayNum] ?? [])
                                  .take(2)
                                  .map((title) => Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFB5A957),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      // Display note titles for this day
                      if (isCurrentMonth &&
                          widget.notesByDay.containsKey(dayNum))
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: (widget.notesByDay[dayNum] ?? [])
                                  .take(2)
                                  .map((title) => Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF7C5FDD),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ));
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

  const _WeekdayHeader(this.label, {this.isWeekend = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: isWeekend ? Colors.red : Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
