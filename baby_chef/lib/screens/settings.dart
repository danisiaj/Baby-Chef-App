import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  // DISPLAY SETTINGS (incoming current values)
  final String iconSize; // Small | Medium | Large
  final ValueChanged<String> onIconSizeChanged;

  final double textScale; // 0.9 | 1.0 | 1.1
  final ValueChanged<double> onTextScaleChanged;

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool biometricQuickLoginEnabled;
  final Future<bool> Function(bool enabled) onBiometricQuickLoginChanged;

  // INFO
  final String appVersion;
  final String dataSourceLabel;

  const SettingsScreen({
    super.key,
    required this.iconSize,
    required this.onIconSizeChanged,
    required this.textScale,
    required this.onTextScaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.biometricQuickLoginEnabled,
    required this.onBiometricQuickLoginChanged,
    required this.appVersion,
    required this.dataSourceLabel,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _iconSize;
  late double _textScale;
  late ThemeMode _themeMode;
  late bool _biometricQuickLoginEnabled;
  bool _updatingBiometric = false;

  @override
  void initState() {
    super.initState();
    _iconSize = widget.iconSize;
    _textScale = widget.textScale;
    _themeMode = widget.themeMode;
    _biometricQuickLoginEnabled = widget.biometricQuickLoginEnabled;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If parent changes values while this page is open, sync local state.
    if (oldWidget.iconSize != widget.iconSize) {
      _iconSize = widget.iconSize;
    }
    if (oldWidget.textScale != widget.textScale) {
      _textScale = widget.textScale;
    }
    if (oldWidget.themeMode != widget.themeMode) {
      _themeMode = widget.themeMode;
    }
    if (oldWidget.biometricQuickLoginEnabled !=
        widget.biometricQuickLoginEnabled) {
      _biometricQuickLoginEnabled = widget.biometricQuickLoginEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segmentedStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color.fromRGBO(96, 141, 209, 1);
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return theme.colorScheme.onSurface;
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _sectionTitle(context, 'Display'),

          _segmentedSetting(
            context,
            icon: Icons.brightness_6_rounded,
            title: 'Theme',
            subtitle: 'Choose light, dark, or device setting',
            control: SegmentedButton<ThemeMode>(
              style: segmentedStyle,
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('Device'),
                ),
              ],
              selected: {_themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                final selected = selection.first;
                setState(() => _themeMode = selected);
                widget.onThemeModeChanged(selected);
              },
            ),
          ),
          _segmentedSetting(
            context,
            icon: CupertinoIcons.square_grid_2x2,
            title: 'Icon size',
            subtitle: 'Affects formula and additive grid layout',
            control: SegmentedButton<String>(
              style: segmentedStyle,
              segments: const [
                ButtonSegment<String>(value: 'Small', label: Text('Small')),
                ButtonSegment<String>(value: 'Medium', label: Text('Medium')),
                ButtonSegment<String>(value: 'Large', label: Text('Large')),
              ],
              selected: {_iconSize},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                final selected = selection.first;
                setState(() => _iconSize = selected);
                widget.onIconSizeChanged(selected);
              },
            ),
          ),
          _segmentedSetting(
            context,
            icon: CupertinoIcons.textformat,
            title: 'Text size',
            subtitle: 'Adjusts readability across the app',
            control: SegmentedButton<double>(
              style: segmentedStyle,
              segments: const [
                ButtonSegment<double>(value: 0.8, label: Text('Small')),
                ButtonSegment<double>(value: 1.0, label: Text('Medium')),
                ButtonSegment<double>(value: 1.2, label: Text('Large')),
              ],
              selected: {_textScale},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                final selected = selection.first;
                setState(() => _textScale = selected);
                widget.onTextScaleChanged(selected);
              },
            ),
          ),
          _switchRow(
            context,
            title: 'Biometric quick login',
            subtitle: _updatingBiometric
                ? 'Updating...'
                : (_biometricQuickLoginEnabled
                    ? 'Enabled on this device'
                    : 'Use Face ID / fingerprint at login'),
            icon: CupertinoIcons.lock,
            value: _biometricQuickLoginEnabled,
            onChanged: _updatingBiometric ? null : _onBiometricToggle,
          ),

          const SizedBox(height: 24),
          const Divider(),

          _sectionTitle(context, 'App'),

          _infoTile(
            context,
            title: 'Version',
            value: widget.appVersion,
          ),

          const SizedBox(height: 24),
          const Divider(),

          _sectionTitle(context, 'Legal'),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Disclaimer'),
            subtitle: const Text(
              'This application is intended as a clinical support tool. '
              'Always follow institutional policies and manufacturer guidelines.',
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _segmentedSetting(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget control,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: control,
          ),
        ],
      ),
    );
  }

  Widget _switchRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Transform.scale(
        scale: 1.15,
        child: CupertinoSwitch(
          activeTrackColor: const Color(0xFF1E88E5),
          inactiveTrackColor: const Color(0xFFD9D9D9),
          thumbColor: Colors.white,
          onLabelColor: const Color(0xFF1E88E5),
          value: value,
          onChanged: onChanged,
        ),
      ),
      onTap: onChanged == null ? null : () => onChanged(!value),
    );
  }

  Future<void> _onBiometricToggle(bool value) async {
    setState(() => _updatingBiometric = true);
    final applied = await widget.onBiometricQuickLoginChanged(value);
    if (!mounted) return;
    setState(() {
      _biometricQuickLoginEnabled = applied;
      _updatingBiometric = false;
    });
  }

  Widget _infoTile(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
