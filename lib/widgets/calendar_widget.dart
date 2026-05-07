import 'package:flutter/material.dart';
import 'dart:async';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = _formatMonthYear(widget.selectedDate);
    final daysInMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0)
            .day;
    final firstDayWeekday =
        DateTime(widget.selectedDate.year, widget.selectedDate.month, 1)
            .weekday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month/Year header
          Text(
            monthYear,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
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
          const SizedBox(height: 6),
          // Calendar grid
          SizedBox(
            height: 200,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
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
                            DateTime(widget.selectedDate.year,
                                    widget.selectedDate.month, 0)
                                .day);

                final isToday = isCurrentMonth &&
                    dayNum == now.day &&
                    widget.selectedDate.month == now.month &&
                    widget.selectedDate.year == now.year;

                final isSelected =
                    isCurrentMonth && dayNum == widget.selectedDate.day;

                return GestureDetector(
                  onTap: isCurrentMonth
                      ? () => widget.onDateSelected(DateTime(
                          widget.selectedDate.year,
                          widget.selectedDate.month,
                          dayNum))
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF7C5FDD)
                          : (isToday
                              ? const Color(0xFF7C5FDD).withOpacity(0.3)
                              : Colors.transparent),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayDay.toString(),
                      style: TextStyle(
                        color: !isCurrentMonth
                            ? Colors.grey.shade800
                            : (index % 7 == 0 ? Colors.red : Colors.white),
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
