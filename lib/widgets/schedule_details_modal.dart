import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../theme/app_style_tokens.dart';
import 'modal_header_row.dart';
import 'section_card.dart';

class ScheduleDetailsModal extends StatelessWidget {
  const ScheduleDetailsModal({
    super.key,
    required this.selectedDate,
    required this.schedules,
    this.timeRangesByJobName = const {},
    this.onCreateSchedulePressed,
  });

  final DateTime selectedDate;
  final List<ScheduleItem> schedules;
  final Map<String, String> timeRangesByJobName;
  final VoidCallback? onCreateSchedulePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.modalSurface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 480,
          minWidth: 320,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModalHeaderRow(
                title: 'Schedule Details',
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              Text(
                _formatSelectedDate(selectedDate),
                style: const TextStyle(
                  color: AppColors.label,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (schedules.isEmpty)
                SectionCard(
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.accent.withValues(alpha: 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No schedules for this date yet.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      if (onCreateSchedulePressed != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: onCreateSchedulePressed,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Create schedule'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = schedules[index];
                      return _ScheduleDetailCard(
                        item: item,
                        resolvedTimeRange:
                            timeRangesByJobName[item.jobName.trim()] ??
                                'No time set',
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleDetailCard extends StatelessWidget {
  const _ScheduleDetailCard({
    required this.item,
    required this.resolvedTimeRange,
  });

  final ScheduleItem item;
  final String resolvedTimeRange;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      backgroundColor: AppColors.cardSurface.withValues(alpha: 0.7),
      borderColor: AppColors.accent.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title.isEmpty ? 'Untitled schedule' : item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusBadge(isCompleted: item.isCompleted),
            ],
          ),
          if (item.jobName.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.jobName.trim(),
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          _DetailRow(icon: Icons.access_time, text: resolvedTimeRange),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.location_on,
            text: item.place.isEmpty ? 'No place set' : item.place,
          ),
          if (item.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _DetailRow(icon: Icons.notes, text: item.notes.trim()),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade200,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.accent.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.accent.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        isCompleted ? 'COMPLETED' : 'PENDING',
        style: TextStyle(
          color: isCompleted ? AppColors.accent : Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatSelectedDate(DateTime date) {
  const weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
}
