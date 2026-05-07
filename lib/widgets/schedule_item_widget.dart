import 'package:flutter/material.dart';

class ScheduleItemWidget extends StatelessWidget {
  final int day;
  final String title;
  final String time;
  final String place;
  final String notes;
  final bool isCompleted;
  final bool hasAddButton;
  final VoidCallback? onAddPressed;

  const ScheduleItemWidget({
    super.key,
    required this.day,
    required this.title,
    required this.time,
    required this.place,
    required this.notes,
    required this.isCompleted,
    this.hasAddButton = false,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF3D1E6F),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day circle and timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5FDD),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!hasAddButton)
                Container(
                  width: 2,
                  height: 12,
                  color: const Color(0xFF7C5FDD),
                  margin: const EdgeInsets.only(top: 4),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted && !hasAddButton)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF7C5FDD), width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Icon(Icons.check,
                            color: Color(0xFF7C5FDD), size: 12),
                      )
                    else if (hasAddButton)
                      GestureDetector(
                        onTap: onAddPressed,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7C5FDD),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      )
                    else
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _InfoRow('Time', time),
                const SizedBox(height: 2),
                _InfoRow('Place', place),
                const SizedBox(height: 2),
                _InfoRow('Notes', notes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label  ',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
