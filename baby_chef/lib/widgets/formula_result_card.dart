import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FormulaResultCard extends StatelessWidget {
  final String formulaName;
  final String kcalPerOz;
  final double volume; // final volume mL
  final double powder; // g
  final double rtf; // mL (for liquid formulas)
  final double diluentMl; // mL (Water or Human milk)
  final String diluentLabel; // "Water" or "Human milk"
  final String note; // new: formula note from JSON
  final String textSize; // âœ… added for dynamic font scaling
  final bool showImportantNote; // show/hide the formula note section
  final bool showPrepNotes; // show/hide the generic prep notes

  const FormulaResultCard({
    super.key,
    required this.formulaName, // âœ… add here
    required this.kcalPerOz,
    required this.volume,
    required this.powder,
    required this.rtf,
    required this.diluentMl,
    required this.diluentLabel,
    required this.note,
    this.showImportantNote = true,
    this.showPrepNotes = true,

    this.textSize = 'Medium', // âœ… default
  });

  bool get isLiquid => rtf > 0;

  double _fontScale() {
    switch (textSize) {
      case 'Small':
        return 0.9;
      case 'Large':
        return 1.3;
      default:
        return 1.1;
    }
  }

  Widget _bullet(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scale = _fontScale();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
                fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14) * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = _fontScale();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium!.copyWith(fontSize: 16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Recipe for $kcalPerOz kcal/oz",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                        fontSize:
                            (theme.textTheme.titleLarge?.fontSize ?? 20) * scale,
                      ),
                    ),
                  ),
                  _FavoriteButton(
                    formulaName: formulaName,
                    kcalPerOz: kcalPerOz,
                    volumeDesired: volume,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (isLiquid) ...[
                Text(
                  "- Ready-to-feed formula: ${rtf.toStringAsFixed(0)} mL",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                    fontSize:
                        (theme.textTheme.titleLarge?.fontSize ?? 20) * scale,
                  ),
                ),
                Text(
                  "- $diluentLabel: ${diluentMl.toStringAsFixed(0)} mL",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                    fontSize:
                        (theme.textTheme.titleLarge?.fontSize ?? 20) * scale,
                  ),
                ),
                Text(
                  "- Final volume: ${volume.toStringAsFixed(0)} mL",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                    fontSize:
                        (theme.textTheme.titleLarge?.fontSize ?? 20) * scale,
                  ),
                ),
              ] else ...[
                Text(
                  "- $diluentLabel: ${diluentMl.toStringAsFixed(0)} mL",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                    fontSize:
                        (theme.textTheme.titleLarge?.fontSize ?? 20) * scale,
                  ),
                ),
                Text(
                  "- Powder: ${powder.toStringAsFixed(1)} g",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                    fontSize:
                        (theme.textTheme.titleLarge?.fontSize ?? 20) * scale,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Notes:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                  fontSize:
                      (theme.textTheme.titleSmall?.fontSize ?? 14) * scale,
                ),
              ),
              const SizedBox(height: 6),
              // Standard feeding notes (kept from your version)
              _bullet(context, 'Mixed formula expires 24h after preparation.'),
              _bullet(
                context,
                'Teaspoons and scoops should be leveled and unpacked.',
              ),
              _bullet(
                context,
                'Wear gloves when handling formula or human milk.',
              ),
              _bullet(context, 'Discard any leftover formula from a feeding.'),
              _bullet(
                context,
                'Clean and sanitize bottles, nipples, and equipment after use.',
              ),
              _bullet(
                context,
                'Always verify caloric density and instructions with your clinical protocol.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final String formulaName;
  final String kcalPerOz;
  final double volumeDesired;

  const _FavoriteButton({
    required this.formulaName,
    required this.kcalPerOz,
    required this.volumeDesired,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;
  bool _loading = true;

  DatabaseReference? _ref;

  String _favoriteKey() {
    final raw =
        '${widget.formulaName}__${widget.kcalPerOz}__${widget.volumeDesired.toStringAsFixed(0)}';
    return raw.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
  }

  Future<void> _loadFavoriteState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isFavorite = false;
        _loading = false;
      });
      return;
    }

    final key = _favoriteKey();
    _ref = FirebaseDatabase.instance.ref(
      'users/${user.uid}/favorites/$key',
    );
    final snap = await _ref!.get();
    if (!mounted) return;
    setState(() {
      _isFavorite = snap.exists;
      _loading = false;
    });
  }

  Future<String?> _promptNickname() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a nickname?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Patient John',
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save favorites.')),
      );
      return;
    }

    final key = _favoriteKey();
    final ref =
        FirebaseDatabase.instance.ref('users/${user.uid}/favorites/$key');

    if (_isFavorite) {
      await ref.remove();
      if (!mounted) return;
      setState(() => _isFavorite = false);
    } else {
      final nickname = await _promptNickname();
      if (!mounted || nickname == null) return;
      await ref.set({
        'formulaName': widget.formulaName,
        'kcal': widget.kcalPerOz,
        'volumeDesired': widget.volumeDesired,
        if (nickname.isNotEmpty) 'nickname': nickname,
      });
      if (!mounted) return;
      setState(() => _isFavorite = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  @override
  void didUpdateWidget(covariant _FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formulaName != widget.formulaName ||
        oldWidget.kcalPerOz != widget.kcalPerOz ||
        oldWidget.volumeDesired != widget.volumeDesired) {
      _loading = true;
      _loadFavoriteState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isFavorite ? Colors.red : Theme.of(context).hintColor;
    return IconButton(
      tooltip: _isFavorite ? 'Remove favorite' : 'Add to favorites',
      onPressed: _loading ? null : _toggleFavorite,
      icon: Icon(
        _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: color,
      ),
    );
  }
}
