import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/formula_images.dart';
import '../widgets/formula_card.dart';
import '../widgets/formula_info_sheet.dart';

class AdditiveRecipeScreen extends StatelessWidget {
  final String additiveName;
  final Map<String, dynamic> additiveData;

  const AdditiveRecipeScreen({
    super.key,
    required this.additiveName,
    required this.additiveData,
  });

  void _openInfo(
    BuildContext context, {
    required String additiveName,
    Map<String, dynamic>? additiveData,
  }) {
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
        formulaName: additiveName,
        formulaType: additiveData?['type'] as String?, // optional
        note: additiveData?['note']?.toString(), // optional
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath =
        additiveImages[additiveName] ?? 'assets/can_images/default.png';

    // âœ… Filter out non-map entries (like "note")
    final recipeEntries = additiveData.entries
        .where((e) => e.value is Map<String, dynamic>)
        .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info),
            tooltip: 'More info',
            onPressed: () => _openInfo(
              context,
              additiveName: additiveName,
              additiveData: additiveData,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormulaCard(
            formulaName: additiveName,
            imagePath: imagePath,
            note: (additiveData['note'] ?? '').toString(),
          ),
          const SizedBox(height: 16),
          Text(
            "Thickening Recipes",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recipeEntries.map((entry) {
            final type = entry.key;
            final details = entry.value as Map<String, dynamic>;

            // âœ… Extract dynamic tsp key depending on additive type
            final tspKey = details.keys.firstWhere(
              (k) => k.contains('_tsp'),
              orElse: () => '',
            );

            final volume = (details['volume_mL']);
            final tsp = (details[tspKey]);

            // Skip invalid entries
            if (volume == 0 && tsp == 0) return const SizedBox.shrink();

            // âœ… Clean label (e.g. "gel_mix_tsp" â†’ "Gel Mix")
            final ingredientLabel = tspKey.isEmpty
                ? "Additive"
                : tspKey.replaceAll('_tsp', '').replaceAll('_', ' ').trim();

            return Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "â€¢ Volume: ${volume.toStringAsFixed(0)} mL",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "â€¢ $ingredientLabel: ${tsp.toStringAsFixed(0)} tsp",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (additiveData.containsKey('note') &&
              additiveData['note'] is String)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              // child: Text(
              //   "   Note: ${additiveData['note']}",
              //   style: theme.textTheme.bodyLarge?.copyWith(
              //     fontStyle: FontStyle.italic,
              //   ),
              // ),
            ),
        ],
      ),
    );
  }
}
