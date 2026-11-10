
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({
    super.key,
    required this.child,
    required this.location,
  });

  static const Color _blue = Color(0xFF65A7C1);
  static const Color _inactive = Color(0xFF8A99A6);

  static const List<String> _paths = [
    '/home',
    '/statistics',
    '/history',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentIndex = _paths.indexOf(location);
    final selectedIndex = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? theme.colorScheme.outlineVariant
                  : const Color(0xFFE7EDF2),
              width: 1,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: isDark
                ? theme.colorScheme.surface
                : Colors.white,
            indicatorColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 74,
            labelTextStyle:
                WidgetStateProperty.resolveWith((states) {
              final selected =
                  states.contains(WidgetState.selected);

              return TextStyle(
                color: selected ? _blue : _inactive,
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              );
            }),
            iconTheme:
                WidgetStateProperty.resolveWith((states) {
              final selected =
                  states.contains(WidgetState.selected);

              return IconThemeData(
                color: selected ? _blue : _inactive,
                size: 25,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              if (index != selectedIndex) {
                context.go(_paths[index]);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: 'İstatistik',
              ),
              NavigationDestination(
                icon: Icon(Icons.access_time_outlined),
                selectedIcon: Icon(Icons.access_time_filled),
                label: 'Geçmiş',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
