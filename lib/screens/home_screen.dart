import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/tab_navigation_widget.dart';
import '../widgets/schedule_item_widget.dart';
import '../widgets/note_view_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1C0A4A),
                Color(0xFF0A0118),
                Color(0xFF2D1265),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB5A957),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(Icons.nights_stay,
                                  color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'moonlight.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white, size: 20),
                          onPressed: () => _showMenu(context),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Tab Navigation
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: TabNavigationWidget(
                      selectedIndex: _selectedTabIndex,
                      onTabSelected: (index) =>
                          setState(() => _selectedTabIndex = index),
                    ),
                  ),
                  // Calendar View
                  if (_selectedTabIndex == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CalendarWidget(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) =>
                            setState(() => _selectedDate = date),
                      ),
                    ),
                  // Note View
                  if (_selectedTabIndex == 1)
                    NoteViewWidget(
                      onAddNotePressed: () {},
                    ),
                  // Schedule Items (only show 2 max)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Schedule',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ScheduleItemWidget(
                          day: 20,
                          title: 'Meeting with Data Team',
                          time: '07:00 am - 10:00 am',
                          place: 'Bedfordshire, England - WFH',
                          notes: 'prep for the draft website proposal',
                          isCompleted: true,
                        ),
                        const SizedBox(height: 8),
                        ScheduleItemWidget(
                          day: 20,
                          title: 'Upload Assignment File for FJ',
                          time: '01:00 pm',
                          place: 'Bedfordshire, England - WFH',
                          notes: 'Nothing',
                          isCompleted: false,
                          hasAddButton: true,
                          onAddPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D1265),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
