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

  const JobTimeSlotsSection({
    super.key,
    required this.snapshot,
    required this.onAddPressed,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Time Slots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.accent),
        ),
      );
    }

    if (snapshot.hasError) {
      return Text(
        'Error: ${snapshot.error}',
        style: const TextStyle(color: Colors.red),
      );
    }

    final slots = snapshot.data ?? [];

    if (slots.isEmpty) {
      return SectionCard(
        borderRadius: 10,
        backgroundColor: AppColors.cardSurface.withValues(alpha: 0.3),
        borderColor: AppColors.accent.withValues(alpha: 0.2),
        child: const Center(
          child: Text(
            'No job time slots configured yet',
            style: TextStyle(
              color: Colors.white70,
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
          onEdit: () => onEdit(slot),
          onDelete: () => onDelete(slot),
        );
      }).toList(),
    );
  }
}
