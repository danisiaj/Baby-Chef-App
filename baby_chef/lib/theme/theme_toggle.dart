import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const ThemeToggle({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return IconButton(
      iconSize: 28,
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: onToggleTheme,
      icon: Icon(
        isDarkMode ? CupertinoIcons.moon : CupertinoIcons.sun_max,
        color: isDarkMode ? Color.fromRGBO(96, 141, 209, 1): Colors.white,
      ),
    );
  }
}
