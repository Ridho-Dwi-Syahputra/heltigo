/// S-35: Main Scaffold — shell dengan Bottom Navigation Bar (4 tab)
/// Sumber: docs/frontend/04_NAVIGATION.md & 05_SCREENS_SPEC.md §S-35
/// Tabs: Home, Workout, Meal, Progress
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

// Screens
import '../home/home_screen.dart';
import '../workout/workout_list_screen.dart';
import '../meal/meal_list_screen.dart';
import '../progress/progress_screen.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  static const List<Widget> _screens = [
    HomeScreen(),
    WorkoutListScreen(),
    MealListScreen(),
    ProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync tab saat route berpindah via context.go('/meal'), '/workout', dst.
    // GoRouter reuse State instance, jadi initState tidak dipanggil ulang —
    // kita harus manual sync _currentIndex ke widget.initialIndex.
    if (oldWidget.initialIndex != widget.initialIndex &&
        _currentIndex != widget.initialIndex) {
      setState(() => _currentIndex = widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Latihan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Makan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }
}
