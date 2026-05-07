import 'package:flutter/material.dart';
import './calendar_widget.dart';
import '../services/firestore_service.dart';

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
        child: StreamBuilder<List<Note>>(
          stream: FirestoreService().getNotes(),
          builder: (context, snapshot) {
            // Extract days that have notes with their titles
            final daysWithNotes = <int>{};
            final notesByDay = <int, List<String>>{};
            if (snapshot.hasData) {
              for (var note in snapshot.data!) {
                if (note.noteDate != null) {
                  daysWithNotes.add(note.noteDate!.day);
                  notesByDay
                      .putIfAbsent(note.noteDate!.day, () => [])
                      .add(note.title);
                }
              }
            }

            return CalendarWidget(
              selectedDate: widget.selectedDate,
              onDateSelected: widget.onDateSelected,
              daysWithNotes: daysWithNotes.toList(),
              notesByDay: notesByDay,
            );
          },
        ),
      ),
    );
  }
}
