import 'package:flutter/material.dart';

class SpecialRecipeCard extends StatelessWidget {
  final String kcal;
  final Map<String, dynamic> details; 
  final String textSize; 

  const SpecialRecipeCard({
    super.key,
    required this.kcal,
    required this.details,
    required this.textSize,
  });

  double get _scale {
    switch (textSize) {
      case 'Small':
        return 0.9;
      case 'Large':
        return 1.25;
      default:
        return 1.0;
    }
  }

  TextStyle _scaled(TextStyle? base, {FontWeight? weight, FontStyle? style}) {
    final b = (base ?? const TextStyle());
    final size = (b.fontSize ?? 14) * _scale;
    return b.copyWith(
      fontSize: size,
      fontWeight: weight ?? b.fontWeight,
      fontStyle: style ?? b.fontStyle,
    );
  }

  String _n(dynamic v) {
    if (v is num) return v % 1 == 0 ? v.toInt().toString() : v.toString();
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build bullet lines for ALL available info
    final bullets = <String>[];

    // 1) If explicit recipe text exists, include it first.
    final recipeText = (details['recipe'] as String?)?.trim();
    if (recipeText != null && recipeText.isNotEmpty) {
      bullets.add(recipeText);
    }

    if (details.containsKey('hmf_packets')) {
      final p = _n(details['hmf_packets']);
      bullets.add('$p packet${p == '1' ? '' : 's'} HMF');
    }
    if (details.containsKey('powder_g')) {
      bullets.add('${_n(details['powder_g'])} g powder');
    }
    if (details.containsKey('rtf_ml')) {
      bullets.add('${_n(details['rtf_ml'])} mL SSC');
    }
    if (details.containsKey('water_ml')) {
      bullets.add('${_n(details['water_ml'])} mL water');
    }
    if (details.containsKey('milk_ml')) {
      bullets.add('${_n(details['milk_ml'])} mL human milk');
    }

    // If nothing was found (unlikely), show a generic line
    if (bullets.isEmpty) {
      bullets.add('No details provided');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title: "<kcal> kcal/oz"
            Text(
              '$kcal kcal/oz',
              style: _scaled(
                theme.textTheme.titleLarge,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Bullets
            ...bullets.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $line',
                  style: _scaled(
                    theme.textTheme.titleMedium,
                    weight: FontWeight.w600,
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
