import 'package:flutter/material.dart';
import '../utils/formula_images.dart';
import 'additive_recipe.dart';

class AdditivesPage extends StatelessWidget {
  final Map<String, dynamic> preloadedAdditives;
  final VoidCallback onToggleTheme;
  final int crossAxisCount;

  const AdditivesPage({
    super.key,
    required this.preloadedAdditives,
    required this.onToggleTheme,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final additives = preloadedAdditives.keys.toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),

      itemCount: additives.length,
      itemBuilder: (context, index) {
        final name = additives[index];
        final imgPath = additiveImages[name] ?? 'assets/can_images/default.png';
        final additiveData = preloadedAdditives[name] as Map<String, dynamic>;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.cardColor,
            foregroundColor: theme.textTheme.bodyMedium?.color,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdditiveRecipeScreen(
                  additiveName: name,
                  additiveData: additiveData,
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
    );
  }
}
