import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

enum HistorySort { date, username }
enum HistoryTimeFilter { all, today, last7Days }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _historyIconBlue = Color.fromRGBO(96, 141, 209, 1);
  HistorySort _sort = HistorySort.date;
  HistoryTimeFilter _timeFilter = HistoryTimeFilter.all;
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<HistorySort>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _sort == HistorySort.date
                    ? CupertinoIcons.check_mark
                    : CupertinoIcons.calendar,
              ),
              title: const Text('Sort by date'),
              onTap: () => Navigator.pop(context, HistorySort.date),
            ),
            ListTile(
              leading: Icon(
                _sort == HistorySort.username
                    ? CupertinoIcons.check_mark
                    : CupertinoIcons.person,
              ),
              title: const Text('Sort by username'),
              onTap: () => Navigator.pop(context, HistorySort.username),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _sort = selected);
    }
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<HistoryTimeFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _timeFilter == HistoryTimeFilter.all
                    ? CupertinoIcons.check_mark
                    : CupertinoIcons.time,
              ),
              title: const Text('All logs'),
              onTap: () => Navigator.pop(context, HistoryTimeFilter.all),
            ),
            ListTile(
              leading: Icon(
                _timeFilter == HistoryTimeFilter.today
                    ? CupertinoIcons.check_mark
                    : CupertinoIcons.calendar_today,
              ),
              title: const Text('Today'),
              onTap: () => Navigator.pop(context, HistoryTimeFilter.today),
            ),
            ListTile(
              leading: Icon(
                _timeFilter == HistoryTimeFilter.last7Days
                    ? CupertinoIcons.check_mark
                    : CupertinoIcons.calendar,
              ),
              title: const Text('Last 7 days'),
              onTap: () => Navigator.pop(context, HistoryTimeFilter.last7Days),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _timeFilter = selected);
    }
  }

  bool _matchesSearch(Map value) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    final haystack = [
      value['formulaName']?.toString() ?? '',
      value['username']?.toString() ?? '',
      value['email']?.toString() ?? '',
      value['kcal']?.toString() ?? '',
      value['dateLocal']?.toString() ?? '',
    ].join(' ').toLowerCase();
    return haystack.contains(q);
  }

  bool _matchesTimeFilter(Map value) {
    if (_timeFilter == HistoryTimeFilter.all) return true;
    final ts = value['timestamp'];
    if (ts is! int) return false;
    final logTime = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    switch (_timeFilter) {
      case HistoryTimeFilter.all:
        return true;
      case HistoryTimeFilter.today:
        return DateUtils.isSameDay(logTime, now);
      case HistoryTimeFilter.last7Days:
        return logTime.isAfter(now.subtract(const Duration(days: 7)));
    }
  }

  DateTime? _logDateTime(Map value) {
    final ts = value['timestamp'];
    if (ts is int) {
      return DateTime.fromMillisecondsSinceEpoch(ts);
    }
    final iso = value['timestampIso']?.toString();
    if (iso != null && iso.isNotEmpty) {
      return DateTime.tryParse(iso)?.toLocal();
    }
    return null;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '--/--/----';
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$mm/$dd/$yyyy';
  }

  String _formatTime24(DateTime? dt) {
    if (dt == null) return '--:--';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _fieldRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
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
    final cs = theme.colorScheme;
    final ref = FirebaseDatabase.instance
        .ref('historyAll')
        .orderByChild('timestamp')
        .limitToLast(200);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () {
                        setState(() => _showSearch = !_showSearch);
                      },
                      icon: Icon(
                        CupertinoIcons.search,
                        color: _historyIconBlue,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sort',
                      onPressed: _openSortSheet,
                      icon: Icon(
                        CupertinoIcons.arrow_up_arrow_down,
                        color: _historyIconBlue,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Filter',
                      onPressed: _openFilterSheet,
                      icon: Icon(
                        CupertinoIcons.slider_horizontal_3,
                        color: _historyIconBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search formula, user, email, kcal...',
                    prefixIcon: const Icon(CupertinoIcons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                        IconButton(
                          tooltip: 'Close search',
                          icon: const Icon(CupertinoIcons.xmark),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                              _showSearch = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            Expanded(
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
                        'No history yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  final entries = data.entries.where((e) => e.value is Map).toList()
                    ..retainWhere((e) {
                      final v = e.value as Map;
                      return _matchesSearch(v) && _matchesTimeFilter(v);
                    })
                    ..sort((a, b) {
                      if (_sort == HistorySort.username) {
                        final amap = a.value as Map?;
                        final bmap = b.value as Map?;
                        final aUsername = amap?['username']?.toString().trim() ?? '';
                        final bUsername = bmap?['username']?.toString().trim() ?? '';
                        final an = aUsername.isNotEmpty
                            ? aUsername
                            : (amap?['email']?.toString() ?? '');
                        final bn = bUsername.isNotEmpty
                            ? bUsername
                            : (bmap?['email']?.toString() ?? '');
                        final aKey = an.toLowerCase();
                        final bKey = bn.toLowerCase();
                        return aKey.compareTo(bKey);
                      }
                      final at = (a.value as Map?)?['timestamp'] as int? ?? 0;
                      final bt = (b.value as Map?)?['timestamp'] as int? ?? 0;
                      return bt.compareTo(at);
                    });

                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'No logs match current search/filter.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final value = entries[index].value;
                      if (value is! Map) return const SizedBox.shrink();

                      final formulaName =
                          value['formulaName']?.toString() ?? 'Unknown';
                      final kcal = value['kcal']?.toString() ?? '';
                      final volumeDesired = value['volumeDesired'];
                      final finalVolume = value['finalVolume'];
                      final powder = value['powder'];
                      final rtf = value['rtf'];
                      final email = value['email']?.toString() ?? '';
                      final uid = value['uid']?.toString() ?? '';
                      final logId = value['logId']?.toString().isNotEmpty == true
                          ? value['logId'].toString()
                          : entries[index].key.toString();
                      final savedToFavorites = value['savedToFavorites'] == true;

                      final volumeDesiredText = (volumeDesired is num)
                          ? volumeDesired.toStringAsFixed(0)
                          : volumeDesired?.toString() ?? '';
                      final powderText = (powder is num)
                          ? powder.toStringAsFixed(1)
                          : powder?.toString() ?? '';
                      final rtfText = (rtf is num)
                          ? rtf.toStringAsFixed(1)
                          : rtf?.toString() ?? '';
                      final finalVolumeText = (finalVolume is num)
                          ? finalVolume.toStringAsFixed(0)
                          : finalVolume?.toString() ?? '';
                      final dt = _logDateTime(value);
                      final dateText = _formatDate(dt);
                      final timeText = _formatTime24(dt);

                      return Card(
                        margin: EdgeInsets.zero,
                        color: cs.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              14,
                              2,
                              14,
                              14,
                            ),
                            title: Text(
                              logId,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              '$dateText  $timeText',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            children: [
                            _fieldRow(
                              context,
                              label: 'Date',
                              value: dateText,
                            ),
                            _fieldRow(
                              context,
                              label: 'Time',
                              value: timeText,
                            ),
                            _fieldRow(
                              context,
                              label: 'Formula',
                              value: formulaName,
                            ),
                            _fieldRow(
                              context,
                              label: 'Calories',
                              value: '$kcal kcal/oz',
                            ),
                            _fieldRow(
                              context,
                              label: 'Volume Desired',
                              value: '$volumeDesiredText mL',
                            ),
                            _fieldRow(
                              context,
                              label: 'Powder | RTF',
                              value: '$powderText g | $rtfText mL',
                            ),
                            _fieldRow(
                              context,
                              label: 'Final Volume',
                              value: '$finalVolumeText mL',
                            ),
                            _fieldRow(
                              context,
                              label: 'User Email',
                              value: email.isEmpty ? '-' : email,
                            ),
                            _fieldRow(
                              context,
                              label: 'User ID',
                              value: uid.isEmpty ? '-' : uid,
                            ),
                            _fieldRow(
                              context,
                              label: 'Log ID',
                              value: logId,
                            ),
                            _fieldRow(
                              context,
                              label: 'Saved to Favorites',
                              value: savedToFavorites ? 'true' : 'false',
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
          ],
        ),
      ),
    );
  }
}
