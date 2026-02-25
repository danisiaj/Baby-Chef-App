import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormulaInputSheet extends StatefulWidget {
  final String formulaName;
  final Map<String, dynamic> formulaData;
  final double? initialVolume; // ✅ Added to keep last inputs
  final String? initialKcal;
  final String? initialType;

  const FormulaInputSheet({
    super.key,
    required this.formulaName,
    required this.formulaData,
    this.initialVolume,
    this.initialKcal,
    this.initialType,
  });

  @override
  State<FormulaInputSheet> createState() => _FormulaInputSheetState();
}

class _FormulaInputSheetState extends State<FormulaInputSheet> {
  late String _selectedType;
  String? _selectedKcal;
  double? _enteredVolume;
  Key _volumeFieldKey = UniqueKey();


  static const _metaKeys = {'type', 'landing_note', 'basic_recipe_cal'};

  String _normalizeKcal(dynamic value) {
    if (value == null) return '';
    if (value is num) return value.toStringAsFixed(0);
    return value.toString().replaceAll('.0', '');
  }

  List<String> _availableTypes() {
    final data = widget.formulaData;
    final available = <String>[];
    if (data.containsKey('formula_only') &&
        data['formula_only'] is Map &&
        (data['formula_only'] as Map).isNotEmpty) {
      available.add('formula_only');
    }
    if (data.containsKey('human_milk') &&
        data['human_milk'] is Map &&
        (data['human_milk'] as Map).isNotEmpty) {
      available.add('human_milk');
    }
    if (available.isEmpty) {
      available.add('special_recipe');
    }
    return available;
  }

  List<String> _kcalOptionsFor(String type) {
    final t = widget.formulaData[type];
    if (t is! Map) return [];
    final keys = t.keys
        .where((k) => !_metaKeys.contains(k))
        .map((k) => _normalizeKcal(k))
        .where((k) => k.trim().isNotEmpty)
        .toList();
    keys.sort((a, b) => double.parse(a).compareTo(double.parse(b)));
    return keys;
  }

  @override
  void initState() {
    super.initState();

    final types = _availableTypes();
    _selectedType =
        widget.initialType ??
        (types.contains('formula_only')
            ? 'formula_only'
            : (types.isNotEmpty ? types.first : 'formula_only'));

    final kcals = _kcalOptionsFor(_selectedType);
    final basic = _normalizeKcal(widget.formulaData['basic_recipe_cal']);
    _selectedKcal =
        widget.initialKcal ??
        ((basic.isNotEmpty && kcals.contains(basic))
            ? basic
            : (kcals.isNotEmpty ? kcals.first : null));

    _enteredVolume = widget.initialVolume;
  }

  void _onTypeChanged(String? v) {
    if (v == null) return;
    setState(() {
      _selectedType = v;
      final kcals = _kcalOptionsFor(_selectedType);
      final basic = _normalizeKcal(widget.formulaData['basic_recipe_cal']);
      _selectedKcal = (basic.isNotEmpty && kcals.contains(basic))
          ? basic
          : (kcals.isNotEmpty ? kcals.first : null);
    });
  }

  void _onReset() {
    setState(() {
      final types = _availableTypes();
      _selectedType = types.contains('formula_only')
          ? 'formula_only'
          : (types.isNotEmpty ? types.first : 'formula_only');

      final kcals = _kcalOptionsFor(_selectedType);
      final basic = _normalizeKcal(widget.formulaData['basic_recipe_cal']);
      _selectedKcal = (basic.isNotEmpty && kcals.contains(basic))
          ? basic
          : (kcals.isNotEmpty ? kcals.first : null);

      _enteredVolume = null; // clear the value
      _volumeFieldKey = UniqueKey(); // force TextFormField to rebuild empty
    });
  }

  void _onApply() {
    Navigator.of(context).pop({
      'type': _selectedType,
      'kcal': _selectedKcal,
      'volume': _enteredVolume,
    });
  }

  @override
  Widget build(BuildContext context) {
    final types = _availableTypes();
    final kcalOptions = _kcalOptionsFor(_selectedType);
    final canApply =
        _selectedKcal != null && _enteredVolume != null && _enteredVolume! > 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: "Preparation Type"),
              items: types
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(
                        t == 'formula_only' ? 'Formula Only' : 'Human Milk',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedKcal,
              decoration: const InputDecoration(labelText: "kcal/oz"),
              items: kcalOptions
                  .map(
                    (k) => DropdownMenuItem<String>(value: k, child: Text(k)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedKcal = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: _volumeFieldKey,
              initialValue: _enteredVolume != null
                  ? _enteredVolume!.toStringAsFixed(0)
                  : '',
              decoration: const InputDecoration(
                labelText: "Amount (mL)",
                hintText: "Enter volume in mL",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) =>
                  setState(() => _enteredVolume = double.tryParse(v)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: _onReset, child: const Text("Reset")),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: canApply ? _onApply : null,
                  child: const Text("Apply"),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
