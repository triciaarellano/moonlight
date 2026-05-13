import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_style_tokens.dart';
import '../section_card.dart';
import 'job_time_slot_card.dart';

class JobTimeSlotsSection extends StatelessWidget {
  final AsyncSnapshot<List<JobTimeSlot>> snapshot;
  final VoidCallback onAddPressed;
  final ValueChanged<JobTimeSlot> onEdit;
  final ValueChanged<JobTimeSlot> onDelete;
  final AppScreenPalette? palette;

  const JobTimeSlotsSection({
    super.key,
    required this.snapshot,
    required this.onAddPressed,
    required this.onEdit,
    required this.onDelete,
    this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final colors = palette ?? AppScreenPalette.night();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Time Slots',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildContent(colors),
        ],
      ),
    );
  }

  Widget _buildContent(AppScreenPalette colors) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(colors.accent),
        ),
      );
    }

    if (snapshot.hasError) {
      return Text(
        'Error: ${snapshot.error}',
        style: TextStyle(color: colors.destructive),
      );
    }

    final slots = snapshot.data ?? [];

    if (slots.isEmpty) {
      return SectionCard(
        borderRadius: 10,
        backgroundColor: colors.cardSurface,
        borderColor: colors.cardBorder,
        child: Center(
          child: Text(
            'No job time slots configured yet',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Column(
      children: slots.map((slot) {
        return JobTimeSlotCard(
          slot: slot,
          palette: colors,
          onEdit: () => onEdit(slot),
          onDelete: () => onDelete(slot),
        );
      }).toList(),
    );
  }
}
