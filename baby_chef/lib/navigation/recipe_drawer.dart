import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RecipeDrawer extends StatelessWidget {
  final String formulaName;

  final String textSize; // "Small" | "Medium" | "Large"
  final ValueChanged<String> onTextSizeChanged;

  final VoidCallback onToggleTheme;

  const RecipeDrawer({
    super.key,
    required this.formulaName,
    required this.textSize,
    required this.onTextSizeChanged,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final onPrimary = theme.colorScheme.onPrimary.withValues(alpha: 0.92);
    final onPrimaryMuted = theme.colorScheme.onPrimary.withValues(alpha: 0.75);

    final headerStyle = theme.textTheme.titleLarge?.copyWith(
      color: onPrimary,
      fontWeight: FontWeight.bold,
    );

    final itemStyle = theme.textTheme.bodyLarge?.copyWith(
      color: onPrimary,
      fontWeight: FontWeight.w600,
    );

    return Drawer(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
      elevation: 10,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 28, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Calculator Settings',
                      textAlign: TextAlign.right,
                      style: headerStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formulaName,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onPrimaryMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.25),
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 40),

                    // --- Display ---
                    Text('Display', textAlign: TextAlign.right, style: itemStyle),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Text size',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 38,
                          width: 130,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: textSize,
                              isExpanded: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: onPrimary,
                                fontSize: 14,
                              ),
                              icon: Icon(
                                CupertinoIcons.chevron_down,
                                color: onPrimaryMuted,
                              ),
                              dropdownColor: theme.colorScheme.primary.withValues(
                                alpha: 0.96,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Small',
                                  child: Text('Small'),
                                ),
                                DropdownMenuItem(
                                  value: 'Medium',
                                  child: Text('Medium'),
                                ),
                                DropdownMenuItem(
                                  value: 'Large',
                                  child: Text('Large'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) onTextSizeChanged(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(CupertinoIcons.sun_max, color: Colors.white),
                        const SizedBox(width: 12),
                        CupertinoSwitch(
                          activeTrackColor: theme.colorScheme.tertiary,
                          inactiveTrackColor: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.5,
                          ),
                          thumbColor: theme.colorScheme.onPrimary,
                          onLabelColor: theme.colorScheme.tertiary,
                          value: theme.brightness == Brightness.dark,
                          onChanged: (_) => onToggleTheme(),
                        ),
                        Icon(CupertinoIcons.moon, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Divider(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.25),
                      thickness: 1,
                      height: 1,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 18, 30),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: null,
                  icon: Icon(CupertinoIcons.flag, color: onPrimaryMuted),
                  label: Text(
                    'Report a problem',
                    style: theme.textTheme.bodyLarge?.copyWith(color: onPrimary, fontWeight:FontWeight.bold)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
