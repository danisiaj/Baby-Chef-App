double asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

Map<String, dynamic> calculateFormula({
  required String formulaName,
  required String type, // "formula_only" | "human_milk"
  required String kcalPerOz,
  required double volumeMl,
  required Map<String, dynamic> formulasData,
}) {
  try {
    final formula = formulasData[formulaName];
    if (formula == null) return {'error': 'Formula not found'};

    final formulaType = (formula['type']?.toString().toLowerCase() ?? 'powder');
    final typeGroup = formula[type];
    if (typeGroup == null || typeGroup is! Map) {
      return {'error': 'Invalid formula type'};
    }

    final recipe = typeGroup[kcalPerOz];
    if (recipe == null || recipe is! Map) {
      return {'error': 'Invalid kcal/oz value'};
    }

    // ---------- LIQUID (RTF) ----------
    if (formulaType == 'liquid') {
      final baseRtf = asDouble(recipe['rtf_ml']);
      final baseWater = asDouble(recipe['water_ml']);
      final baseMilk = asDouble(recipe['milk_ml']);
      final baseDiluent = baseMilk > 0 ? baseMilk : baseWater;
      final diluentLabel = baseMilk > 0 ? 'Human milk' : 'Water';

      if ((baseRtf + baseDiluent) <= 0) {
        return {'error': 'Invalid liquid recipe (0 total base volume)'};
      }

      final scale = volumeMl / (baseRtf + baseDiluent);
      final rtfMl = baseRtf * scale;
      final diluentMl = baseDiluent * scale;

      return {
        'powder_g': '0.0',
        'rtf_ml': rtfMl.toStringAsFixed(1),
        'diluent_ml': diluentMl.toStringAsFixed(1),
        'diluent_label': diluentLabel,
        'final_volume_ml': volumeMl.toStringAsFixed(0),
      };
    }

    // ---------- POWDER (formula_only or human_milk) ----------
    final isHumanMilk = type == 'human_milk';
    final baseLiquid = asDouble(
      isHumanMilk ? recipe['milk_ml'] : recipe['water_ml'],
    );
    final basePowder = asDouble(recipe['powder_g']);
    if (baseLiquid <= 0) return {'error': 'Invalid base liquid value'};

    final scale = volumeMl / baseLiquid;
    final powderG = basePowder * scale;

    return {
      'powder_g': powderG.toStringAsFixed(1),
      'rtf_ml': '0.0',
      'diluent_ml': volumeMl.toStringAsFixed(
        0,
      ), // user’s target volume is the liquid measure
      'diluent_label': isHumanMilk ? 'Human milk' : 'Water',
      'final_volume_ml': volumeMl.toStringAsFixed(0),
    };
  } catch (e) {
    return {'error': 'Calculation failed: $e'};
  }
}
