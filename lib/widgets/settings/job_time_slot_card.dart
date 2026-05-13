import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_style_tokens.dart';
import '../section_card.dart';

class JobTimeSlotCard extends StatelessWidget {
  final JobTimeSlot slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final AppScreenPalette? palette;

  const JobTimeSlotCard({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
    this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final colors = palette ?? AppScreenPalette.night();
    final isMorningSlot = slot.timeOfDay == 'morning';
    final slotAccent = isMorningSlot ? colors.accentAlt : colors.accent;

    return SectionCard(
      borderRadius: 10,
      backgroundColor: colors.cardSurface,
      borderColor: colors.cardBorder,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.jobName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isMorningSlot ? Icons.wb_sunny : Icons.nights_stay,
                          color: slotAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          slot.timeOfDay.toUpperCase(),
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: colors.secondaryText),
                    onPressed: onEdit,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: colors.destructive),
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
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
            ),
          ),
          if (slot.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              slot.notes,
              style: TextStyle(
                color: colors.mutedText,
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
