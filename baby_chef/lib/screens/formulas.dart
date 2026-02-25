import 'package:flutter/material.dart';
import '../utils/formula_images.dart';
import 'formula_calculator.dart';

class FormulasPage extends StatelessWidget {
  final Map<String, dynamic> preloadedFormulas;
  final VoidCallback onToggleTheme;
  final int crossAxisCount;
  final ValueNotifier<String> searchQuery;

  const FormulasPage({
    super.key,
    required this.preloadedFormulas,
    required this.onToggleTheme,
    required this.crossAxisCount,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allFormulas = preloadedFormulas.keys.toList();

    return ValueListenableBuilder<String>(
      valueListenable: searchQuery,
      builder: (context, query, _) {
        final filteredFormulas = allFormulas
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: GridView.builder(
            key: ValueKey(query),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: filteredFormulas.length,
            itemBuilder: (context, index) {
              final name = filteredFormulas[index];
              final imgPath =
                  formulaImages[name] ?? 'assets/can_images/default.png';
              final formulaData =
                  preloadedFormulas[name] as Map<String, dynamic>;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: theme.textTheme.bodyMedium?.color,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormulaCalculatorScreen(
                        formulaName: name,
                        formulaData: formulaData,
                        onToggleTheme: onToggleTheme,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Image.asset(imgPath, fit: BoxFit.contain)),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
