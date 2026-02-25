import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/formula_images.dart';
import 'formula_calculator.dart';

class FavoritesScreen extends StatelessWidget {
  final Map<String, dynamic> formulasData;
  final VoidCallback onToggleTheme;

  const FavoritesScreen({
    super.key,
    required this.formulasData,
    required this.onToggleTheme,
  });

  DatabaseReference? _favoritesRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseDatabase.instance.ref('users/${user.uid}/favorites');
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DatabaseReference ref,
    String itemKey,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete favorite?'),
        content: const Text('Remove this item from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.child(itemKey).remove();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ref = _favoritesRef();

    if (ref != null) {
      ref.keepSynced(true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ref == null
            ? Center(
                child: Text(
                  'Please log in to view favorites.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            : StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.snapshot.value;
                  if (data is! Map) {
                    return Center(
                      child: Text(
                        'No favorites yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  final entries = data.entries.toList();

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final value = entries[index].value;
                      if (value is! Map) return const SizedBox.shrink();

                      final formulaName =
                          value['formulaName']?.toString() ?? 'Unknown formula';
                      final kcal = value['kcal']?.toString() ??
                          value['calories']?.toString() ??
                          '';
                      final volumeRaw = value['volumeDesired'];
                      final volume = volumeRaw is num
                          ? volumeRaw.toDouble()
                          : double.tryParse(volumeRaw?.toString() ?? '') ?? 0.0;
                      final imagePath =
                          formulaImages[formulaName] ??
                          'assets/can_images/default.png';
                      final itemKey = entries[index].key.toString();

                      final nickname = value['nickname']?.toString() ?? '';
                      final kcalLine = kcal.isEmpty
                          ? '${volume.toStringAsFixed(0)} mL'
                          : '$kcal kcal/oz  |  ${volume.toStringAsFixed(0)} mL';

                      return _FavoriteActionCard(
                        nickname: nickname,
                        formulaName: formulaName,
                        subtitle: kcalLine,
                        imagePath: imagePath,
                        onDelete: () => _confirmDelete(
                          context,
                          ref,
                          itemKey,
                        ),
                        onTap: () {
                          final formulaData = formulasData[formulaName];
                          if (formulaData is! Map) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Formula not found.'),
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FormulaCalculatorScreen(
                                formulaName: formulaName,
                                formulaData: formulaData
                                    .map((k, v) => MapEntry(k.toString(), v)),
                                onToggleTheme: onToggleTheme,
                                initialKcal: kcal,
                                initialVolume: volume,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _FavoriteActionCard extends StatelessWidget {
  final String nickname;
  final String formulaName;
  final String subtitle;
  final String imagePath;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _FavoriteActionCard({
    required this.nickname,
    required this.formulaName,
    required this.subtitle,
    required this.imagePath,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.fromLTRB(14, 18, 8, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 50,
                  height: 50,
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.local_drink_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nickname.isNotEmpty) ...[
                    Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    formulaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: Icon(
                CupertinoIcons.ellipsis_vertical,
                size: 32,
                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text(
                    'Remove favorite',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

