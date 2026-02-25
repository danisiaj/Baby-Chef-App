import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 20),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: onTap,
              selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor?.withValues(alpha: 0.6),
              selectedFontSize: 12,
              unselectedFontSize: 10,
              selectedIconTheme: const IconThemeData(size: 30),
              unselectedIconTheme: const IconThemeData(size: 25),
              items: [
                BottomNavigationBarItem(
                  icon: Transform.rotate(
                    angle: math.pi / 4,
                    child: const ImageIcon(
                      AssetImage('assets/icons/ic_launcher.png'),
                    ),
                  ),
                  activeIcon: Transform.rotate(
                    angle: math.pi / 4,
                    child: const ImageIcon(
                      AssetImage('assets/icons/ic_launcher.png'),
                    ),
                  ),
                  label: 'Formulas',
                ),
                BottomNavigationBarItem(
                  icon: Transform.scale(
                    scale: 1.25,
                    child: const ImageIcon(
                      AssetImage('assets/icons/icon_scoop.png'),
                    ),
                  ),
                  activeIcon: Transform.scale(
                    scale: 1.25,
                    child: const ImageIcon(
                      AssetImage('assets/icons/icon_scoop.png'),
                    ),
                  ),
                  label: 'Additives',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
