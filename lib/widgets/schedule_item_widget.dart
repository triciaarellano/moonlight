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
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF3D1E6F).withValues(alpha: 0.7),
        border: Border.all(
          color: const Color(0xFF7C5FDD).withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day circle and timeline
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5FDD),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C5FDD).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!hasAddButton)
                Container(
                  width: 2.5,
                  height: 14,
                  color: const Color(0xFF7C5FDD).withValues(alpha: 0.6),
                  margin: const EdgeInsets.only(top: 6),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
          const SizedBox(width: 12),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted && !hasAddButton)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF7C5FDD), width: 2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(Icons.check,
                            color: Color(0xFF7C5FDD), size: 13),
                      )
                    else if (hasAddButton)
                      GestureDetector(
                        onTap: onAddPressed,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7C5FDD),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Time and place
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey[500], size: 12),
                    const SizedBox(width: 4),
                    Text(
                      time.isEmpty ? 'No time set' : time,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, color: Colors.grey[500], size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.isEmpty ? 'No place set' : place,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    notes,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
