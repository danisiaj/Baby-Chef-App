import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'formula_info_sheet.dart';

class FormulaCard extends StatelessWidget {
  final String formulaName;
  final String imagePath;
  final String? textSize;
  final String note;

  const FormulaCard({
    super.key,
    required this.formulaName,
    required this.imagePath,
    this.textSize = 'Medium',
    required this.note,
  });

  double getFontSize() {
    switch (textSize) {
      case 'Small':
        return 18;
      case 'Large':
        return 22;
      default:
        return 20;
    }
  }

  void _openInfo(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FormulaInfoSheet(
        formulaName: formulaName,
        note: note.trim().isEmpty ? null : note.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = getFontSize();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      elevation: 3,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------- IMAGE ----------
            Image.asset(
              imagePath,
              height: 150,
              width: 120,
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formulaName,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.info),
                        color: theme.colorScheme.secondary,
                        tooltip: 'More info',
                        onPressed: () => _openInfo(context),
                      ),
                      const Text('More info'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
