import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/formula_images.dart';
import '../utils/calculations.dart';

import '../widgets/formula_card.dart';
import '../widgets/formula_result_card.dart';
import '../widgets/formula_input_sheet.dart';
import '../widgets/special_recipe_card.dart';

import '../navigation/recipe_drawer.dart';

class FormulaCalculatorScreen extends StatefulWidget {
  final String formulaName;
  final Map<String, dynamic> formulaData;
  final VoidCallback onToggleTheme;
  final String? initialKcal;
  final double? initialVolume;

  const FormulaCalculatorScreen({
    super.key,
    required this.formulaName,
    required this.formulaData,
    required this.onToggleTheme,
    this.initialKcal,
    this.initialVolume,
  });

  @override
  State<FormulaCalculatorScreen> createState() => _FormulaCalculatorScreenState();
}

class _FormulaCalculatorScreenState extends State<FormulaCalculatorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _screenSessionId = DateTime.now().microsecondsSinceEpoch
      .toString();

  Map<String, dynamic>? _result;
  String _textSize = 'Medium';

  bool get _hasSpecialRecipes =>
      widget.formulaData['special_recipe'] is Map &&
      (widget.formulaData['special_recipe'] as Map).isNotEmpty;

  List<String> _sortedKcalKeys(Map<dynamic, dynamic> m) {
    final keys = m.keys.map((k) => k.toString()).toList();
    keys.sort((a, b) {
      final da = double.tryParse(a);
      final db = double.tryParse(b);
      if (da != null && db != null) return da.compareTo(db);
      return a.compareTo(b);
    });
    return keys;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialKcal != null && widget.initialVolume != null) {
      _calculateAndSet(
        kcal: widget.initialKcal!,
        volumeMl: widget.initialVolume!,
      );
    }
  }

  Future<void> _logHistory({
    required String kcal,
    required String calculationType,
    required double volumeDesired,
    required double finalVolume,
    required double powder,
    required double rtf,
    required double diluentMl,
    required String diluentLabel,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String username = user.displayName ?? '';
      if (username.isEmpty) {
        try {
          final snap = await FirebaseDatabase.instance
              .ref('users/${user.uid}/username')
              .get();
          username = snap.value?.toString() ?? '';
        } catch (e) {
          debugPrint('Could not read /users/${user.uid}/username: $e');
        }
      }

      if (username.isEmpty) {
        username = user.email ?? 'Unknown';
      }

      final rootRef = FirebaseDatabase.instance.ref();
      final key = rootRef.child('historyAll').push().key;
      if (key == null) return;
      final nowLocal = DateTime.now();
      final nowUtc = nowLocal.toUtc();
      final dateLocal =
          '${nowLocal.year.toString().padLeft(4, '0')}-${nowLocal.month.toString().padLeft(2, '0')}-${nowLocal.day.toString().padLeft(2, '0')}';
      final timeLocal =
          '${nowLocal.hour.toString().padLeft(2, '0')}:${nowLocal.minute.toString().padLeft(2, '0')}:${nowLocal.second.toString().padLeft(2, '0')}';
      final payload = {
        'schemaVersion': 1,
        'logId': key,
        'formulaName': widget.formulaName,
        'calculationType': calculationType,
        'kcal': kcal,
        'volumeDesired': volumeDesired,
        'requestedVolumeMl': volumeDesired,
        'finalVolume': finalVolume,
        'powder': powder,
        'rtf': rtf,
        'diluentMl': diluentMl,
        'diluentLabel': diluentLabel,
        'savedToFavorites': false,
        'username': username,
        'email': user.email ?? '',
        'uid': user.uid,
        'timestamp': ServerValue.timestamp,
        'timestampIso': nowUtc.toIso8601String(),
        'timestampUtcIso': nowUtc.toIso8601String(),
        'dateLocal': dateLocal,
        'timeLocal': timeLocal,
        'timezoneOffsetMinutes': nowLocal.timeZoneOffset.inMinutes,
        'screen': 'formula_calculator',
        'sessionId': _screenSessionId,
      };

      final targets = [
        'historyAll/$key',
      ];

      var successCount = 0;
      for (final path in targets) {
        try {
          await rootRef.child(path).set(payload);
          successCount++;
        } catch (e) {
          debugPrint('History log write failed at "$path": $e');
        }
      }

      if (successCount == 0) {
        throw FirebaseException(
          plugin: 'firebase_database',
          message: 'All history log writes failed.',
        );
      }
    } catch (e) {
      debugPrint('History logging failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save history log. Check database rules.'),
        ),
      );
    }
  }

  void _calculateAndSet({
    required String kcal,
    required double volumeMl,
    String type = 'formula_only',
  }) {
    final calc = calculateFormula(
      formulaName: widget.formulaName,
      type: type,
      kcalPerOz: kcal,
      volumeMl: volumeMl,
      formulasData: {widget.formulaName: widget.formulaData},
    );

    if (calc.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(calc['error'].toString())),
      );
      return;
    }

    final finalVolume =
        double.tryParse(calc['final_volume_ml']?.toString() ?? '') ?? 0.0;
    final powder =
        double.tryParse(calc['powder_g']?.toString() ?? '') ?? 0.0;
    final rtf = double.tryParse(calc['rtf_ml']?.toString() ?? '') ?? 0.0;
    final diluentMl =
        double.tryParse(calc['diluent_ml']?.toString() ?? '') ?? 0.0;
    final diluentLabel =
        calc['diluent_label']?.toString() ??
        (type == 'human_milk' ? 'Human milk' : 'Water');

    setState(() {
      _result = {
        'kcal': kcal,
        'volume': finalVolume,
        'powder': powder,
        'rtf': rtf,
        'diluentMl': diluentMl,
        'diluentLabel': diluentLabel,
      };
    });

    _logHistory(
      kcal: kcal,
      calculationType: type,
      volumeDesired: volumeMl,
      finalVolume: finalVolume,
      powder: powder,
      rtf: rtf,
      diluentMl: diluentMl,
      diluentLabel: diluentLabel,
    );
  }

  Future<void> _openInput() async {

    final data = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FormulaInputSheet(
        formulaName: widget.formulaName,
        formulaData: widget.formulaData,
      ),
    );

    if (data == null || !mounted) return;

    _calculateAndSet(
      kcal: data['kcal'] ?? '',
      volumeMl: (data['volume'] ?? 0).toDouble(),
      type: data['type'] ?? 'formula_only',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath =
        formulaImages[widget.formulaName] ?? 'assets/can_images/default.png';

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.gear),
            tooltip: 'Settings',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),

      // âœ… Correct drawer wiring
      endDrawer: RecipeDrawer(
        formulaName: widget.formulaName,
        textSize: _textSize,
        onTextSizeChanged: (newSize) => setState(() => _textSize = newSize),
        onToggleTheme: widget.onToggleTheme,

        
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          FormulaCard(
            formulaName: widget.formulaName,
            imagePath: imagePath,
            note: (widget.formulaData['note'] ?? '').toString(),
            textSize: _textSize,
          ),

          if (_hasSpecialRecipes) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Special Recipes",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._sortedKcalKeys(widget.formulaData['special_recipe'] as Map).map(
              (k) {
                final details =
                    (widget.formulaData['special_recipe'] as Map)[k]
                        as Map<dynamic, dynamic>;

                return SpecialRecipeCard(
                  kcal: k,
                  details: details.map(
                    (key, value) => MapEntry(key.toString(), value),
                  ),
                  textSize: _textSize,
                );
              },
            ),
          ],

          if (!_hasSpecialRecipes && _result != null)
            FormulaResultCard(
              kcalPerOz: _result!['kcal'].toString(),
              volume: _result!['volume'] ?? 0,
              powder: _result!['powder'] ?? 0,
              rtf: _result!['rtf'] ?? 0,
              diluentMl: _result!['diluentMl'] ?? 0,
              diluentLabel: _result!['diluentLabel'] ?? 'Water',
              note: widget.formulaData['note'] ?? '',
              textSize: _textSize,
              formulaName: widget.formulaName,
            ),

          if (!_hasSpecialRecipes && _result == null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Tap the Calculator button below to generate a recipe.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: _hasSpecialRecipes
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 24.0, bottom: 8.0),
              child: FloatingActionButton.extended(
                onPressed: _openInput,
                icon: const Icon(Icons.calculate),
                label: const Text("Calculator"),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
