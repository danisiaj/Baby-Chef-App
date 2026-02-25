import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ref = FirebaseDatabase.instance.ref('users');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: ref.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.snapshot.value;
            if (data is! Map) {
              return Center(
                child: Text(
                  'No users found.',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            final entries = data.entries.toList()
              ..sort((a, b) {
                final aMap = a.value as Map?;
                final bMap = b.value as Map?;
                final aName = aMap?['username']?.toString().trim() ?? '';
                final bName = bMap?['username']?.toString().trim() ?? '';
                final aKey = aName.isNotEmpty
                    ? aName.toLowerCase()
                    : (aMap?['email']?.toString().toLowerCase() ?? '');
                final bKey = bName.isNotEmpty
                    ? bName.toLowerCase()
                    : (bMap?['email']?.toString().toLowerCase() ?? '');
                return aKey.compareTo(bKey);
              });

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final uid = entry.key.toString();
                final value = entry.value;
                if (value is! Map) return const SizedBox.shrink();

                final username = value['username']?.toString() ?? '';
                final email = value['email']?.toString() ?? '';
                final role = value['role']?.toString() ?? 'Clinician';

                return Card(
                  margin: EdgeInsets.zero,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username.isEmpty ? email : username,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'UID: $uid',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Role: $role',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
