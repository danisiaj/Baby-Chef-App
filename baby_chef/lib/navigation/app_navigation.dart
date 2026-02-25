import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:local_auth/local_auth.dart';
import 'gv_drawer.dart';
import 'bottom_nav_bar.dart';
import '../screens/formulas.dart';
import '../screens/additives.dart';
import '../screens/login.dart';
import '../screens/settings.dart';
import '../screens/about.dart';
import '../screens/admin_portal.dart';
import '../screens/favorites.dart';
import '../services/biometric_quick_login_storage.dart';

class AppNavigation extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Map<String, dynamic> preloadedFormulas;
  final Map<String, dynamic> preloadedAdditives;

  final ValueNotifier<ThemeMode> themeNotifier;

  const AppNavigation({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.preloadedFormulas,
    required this.preloadedAdditives,
    required this.themeNotifier,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  // âœ… SETTINGS STATE (stored here)
  String _iconSize = 'Medium';
  int _crossAxisCount = 2;

  double _textScale = 1.0; 
  bool _biometricQuickLoginEnabled = false;

  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _lockOnResumeArmed = false;
  DateTime? _backgroundedAt;
  static const Duration _lockAfterBackground = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBiometricQuickLoginState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockOnResumeArmed = true;
      _backgroundedAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _lockOnResumeArmed &&
        _biometricQuickLoginEnabled &&
        mounted) {
      final elapsed = _backgroundedAt == null
          ? Duration.zero
          : DateTime.now().difference(_backgroundedAt!);
      _lockOnResumeArmed = false;
      _backgroundedAt = null;

      if (elapsed < _lockAfterBackground) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            themeNotifier: widget.themeNotifier,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _loadBiometricQuickLoginState() async {
    final enabled = await BiometricQuickLoginStorage.isEnabled();
    if (!mounted) return;
    setState(() {
      _biometricQuickLoginEnabled = enabled;
    });
  }

  Future<bool> _onBiometricQuickLoginChanged(bool enabled) async {
    if (!enabled) {
      await BiometricQuickLoginStorage.setEnabled(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric quick login disabled on this device.'),
          ),
        );
      }
      setState(() => _biometricQuickLoginEnabled = false);
      return false;
    }

    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();
    if (!canCheck || !isSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometrics not available.')),
        );
      }
      return false;
    }

    final available = await auth.getAvailableBiometrics();
    final reason = available.contains(BiometricType.face)
        ? 'Unlock with face'
        : available.contains(BiometricType.fingerprint)
            ? 'Unlock with fingerprint'
            : 'Unlock';

    final ok = await auth.authenticate(
      localizedReason: reason,
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric verification cancelled.')),
        );
      }
      return false;
    }

    final hasCreds = await BiometricQuickLoginStorage.hasCredentials();
    if (!hasCreds) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No saved credentials yet. Log in with email/password once, then enable.',
            ),
          ),
        );
      }
      return false;
    }

    await BiometricQuickLoginStorage.setEnabled(true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric quick login enabled on this device.'),
        ),
      );
    }
    setState(() => _biometricQuickLoginEnabled = true);
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onIconSizeChanged(String newSize) {
    setState(() {
      _iconSize = newSize;
      if (newSize == 'Small') {
        _crossAxisCount = 3;
      } else if (newSize == 'Medium') {
        _crossAxisCount = 2;
      } else {
        _crossAxisCount = 1;
      }
    });
  }

  void _onTextScaleChanged(double scale) {
    setState(() {
      _textScale = scale;
    });
  }

  Future<void> _openSettings() async {
    // close drawer if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          iconSize: _iconSize,
          onIconSizeChanged: _onIconSizeChanged,
          textScale: _textScale,
          onTextScaleChanged: _onTextScaleChanged,
          themeMode: widget.themeNotifier.value,
          onThemeModeChanged: (mode) {
            widget.themeNotifier.value = mode;
          },
          biometricQuickLoginEnabled: _biometricQuickLoginEnabled,
          onBiometricQuickLoginChanged: _onBiometricQuickLoginChanged,

          // âœ… Keep simple for now (you can wire real values later)
          appVersion: '1.0.0',
          dataSourceLabel: 'Loaded at login (GitHub / Local fallback)',
        ),
      ),
    );
  }

  Future<void> _openAbout() async {
    // close drawer if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AboutPage()),
    );
  }

  Future<void> _openAdminPortal() async {
    // close drawer if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final adminFirstName = await _resolveCurrentUserFirstName();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPortal(
          adminName: adminFirstName,
          formulasCount: widget.preloadedFormulas.length,
          additivesCount: widget.preloadedAdditives.length,
        ),
      ),
    );
  }

  Future<String> _resolveCurrentUserFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Admin';
    }

    final displayName = user.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }

    try {
      final snap = await FirebaseDatabase.instance
          .ref('users/${user.uid}/firstName')
          .get();
      final firstName = snap.value?.toString().trim() ?? '';
      if (firstName.isNotEmpty) {
        return firstName;
      }
    } catch (_) {
      // Fall through to email fallback.
    }

    final email = user.email?.trim() ?? '';
    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Admin';
  }

  Future<void> _openFavorites() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          formulasData: widget.preloadedFormulas,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    // Drawer uses this too, so handle extra pages here.
    if (index == 2) {
      _openSettings();
      return;
    }
    if (index == 3) {
      _openAbout();
      return;
    }

    if (index == 4) {
      _openAdminPortal();
      return;
    }
    if (index == 5) {
      _openFavorites();
      return;
    }

    // Bottom nav only supports 0 and 1
    setState(() {
      _selectedIndex = index.clamp(0, 1);
    });
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return FormulasPage(
          preloadedFormulas: widget.preloadedFormulas,
          onToggleTheme: widget.onToggleTheme,
          crossAxisCount: _crossAxisCount,
          searchQuery: _searchQuery,
        );
      case 1:
        return AdditivesPage(
          preloadedAdditives: widget.preloadedAdditives,
          onToggleTheme: widget.onToggleTheme,
          crossAxisCount: _crossAxisCount,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // âœ… Apply text scaling to this whole AppNavigation subtree (simple + local)
    // If you want it to affect the whole app globally later, weâ€™ll move this to main.dart.
    final scaled = MediaQuery.of(context).copyWith(textScaleFactor: _textScale);

    return MediaQuery(
      data: scaled,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        drawer: GVDrawer(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          userName: 'Daniel Siaj Romero',
          initialRole: 'Admin',
          onLogout: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginScreen(
                  themeNotifier: widget.themeNotifier,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
              (route) => false,
            );
          },
        ),

        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: (_selectedIndex == 0 && _isSearching)
                ? TextField(
                    key: const ValueKey('searchField'),
                    controller: _searchController,
                    autofocus: true,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search formulas...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _searchQuery.value = value.trim(),
                  )
                : Text(
                    _selectedIndex == 0 ? 'Formulas' : 'Additives',
                    key: const ValueKey('titleText'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  if (_selectedIndex == 0)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: IconButton(
                        key: ValueKey(
                          _isSearching ? 'closeIcon' : 'searchIcon',
                        ),
                        icon: Icon(_isSearching ? CupertinoIcons.xmark : CupertinoIcons.search),
                        tooltip: _isSearching ? 'Close search' : 'Search',
                        onPressed: () {
                          setState(() {
                            if (_isSearching) {
                              _isSearching = false;
                              _searchQuery.value = '';
                              _searchController.clear();
                            } else {
                              _isSearching = true;
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        body: _pageForIndex(_selectedIndex),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
