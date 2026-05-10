import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_style_tokens.dart';
import '../section_card.dart';

class JobTimeSlotCard extends StatelessWidget {
  final JobTimeSlot slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JobTimeSlotCard({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      borderRadius: 10,
      backgroundColor: AppColors.cardSurface.withValues(alpha: 0.7),
      borderColor: AppColors.accent.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.jobName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        slot.timeOfDay == 'morning'
                            ? Icons.wb_sunny
                            : Icons.nights_stay,
                        color: slot.timeOfDay == 'morning'
                            ? Colors.amber[300]
                            : Colors.indigo[300],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        slot.timeOfDay.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: onEdit,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${slot.startTime} - ${slot.endTime}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          if (slot.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              slot.notes,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
