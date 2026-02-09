import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/routine_screen.dart';
import '../screens/period_screen.dart';
import '../screens/settings_screen.dart';

class AppNavigator extends StatefulWidget {
  final String userGender;

  const AppNavigator({Key? key, required this.userGender}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const JournalScreen(),
      if (widget.userGender == 'female') const PeriodScreen(),
      const RoutineScreen(),
      const SettingsScreen(),
    ];

    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined),
        activeIcon: Icon(Icons.book),
        label: 'Journal',
      ),
      if (widget.userGender == 'female')
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Period',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.list_outlined),
        activeIcon: Icon(Icons.list),
        label: 'Routines',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}