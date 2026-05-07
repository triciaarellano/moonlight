import 'package:flutter/material.dart';
import './calendar_widget.dart';

class NoteViewWidget extends StatefulWidget {
  final VoidCallback onAddNotePressed;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const NoteViewWidget({
    super.key,
    required this.onAddNotePressed,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<NoteViewWidget> createState() => _NoteViewWidgetState();
}

class _NoteViewWidgetState extends State<NoteViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C0A4A).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7C5FDD).withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: CalendarWidget(
          selectedDate: widget.selectedDate,
          onDateSelected: widget.onDateSelected,
        ),
      ),
    );
  }
}
