import 'package:flutter/material.dart';

class TabNavigationWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color borderColor;

  const TabNavigationWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.backgroundColor = const Color(0xFF3D1E6F),
    this.selectedBackgroundColor = const Color(0xFF5A3FA3),
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.white,
    this.borderColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildTab('Schedule', 0),
          _buildTab('Note', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: index == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
            color: isSelected ? selectedBackgroundColor : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
