import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GVDrawer extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  // âœ… from your new drawer usage
  final String userName;
  final VoidCallback onLogout;
  final String initialRole;

  const GVDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.userName,
    required this.onLogout,
    required this.initialRole,
  });

  @override
  State<GVDrawer> createState() => _GVDrawerState();
}

class _GVDrawerState extends State<GVDrawer> {
  late String _userRole;

  @override
  void initState() {
    super.initState();
    _userRole = widget.initialRole;
  }

  Widget _navTile(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedIndex == index;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 34,
      leading: index == 0
          ? Transform.rotate(
              angle: math.pi / 4,
              child: ImageIcon(
                const AssetImage('assets/icons/ic_launcher.png'),
                size: isSelected ? 40 : 30,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onPrimary.withValues(alpha: 0.75),
              ),
            )
          : index == 1
          ? ImageIcon(
              const AssetImage('assets/icons/icon_scoop.png'),
              size: isSelected ? 46 : 34,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onPrimary.withValues(alpha: 0.75),
            )
          : Icon(
              icon,
              size: isSelected ? 40 : 30,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onPrimary.withValues(alpha: 0.75),
            ),
      title: Text(
        title,
        style: isSelected
            ? theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimary,
              )
            : theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              ),
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onItemTapped(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = _userRole == 'Admin';

    return Drawer(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        CupertinoIcons.person,
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.only(right: 100),
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.95,
                        ),
                        onSelected: (value) {
                          if (value == 'switch_role') {
                            setState(() {
                              if (_userRole == 'Admin') {
                                _userRole =
                                    'Clinician'; // or 'Dietitian' if you prefer
                              } else {
                                _userRole = 'Admin';
                              }
                            });
                          } else if (value == 'logout') {
                            Navigator.pop(context);
                            widget.onLogout();
                          }
                        },

                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'switch_role',
                            child: Text(
                              _userRole == 'Admin'
                                  ? 'Switch to clinician'
                                  : 'Switch to admin',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),

                          PopupMenuItem(
                            value: 'logout',
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                  ),
                                  Text(
                                    _userRole,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_down,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 64),

              Divider(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.25),
                thickness: 1,
                height: 1,
              ),

              const SizedBox(height: 24),

              isAdmin
                  ? Column(
                      children: [
                        _navTile(
                          context,
                          index: 4,
                          title: 'Admin Portal',
                          icon: CupertinoIcons.checkmark_shield,
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.25,
                          ),
                          thickness: 1,
                          height: 1,
                        ),
                      ],
                    )
                  : const SizedBox(height: 0),

              const SizedBox(height: 24),

              // ---------- NAV ----------
              _navTile(
                context,
                index: 0,
                title: 'Formulas',
                icon: Icons.science_outlined,
              ),
              _navTile(
                context,
                index: 1,
                title: 'Additives',
                icon: Icons.bubble_chart_outlined,
              ),
              _navTile(
                context,
                index: 5,
                title: 'Favorites',
                icon: CupertinoIcons.heart,
              ),

              // ---------- SETTINGS SECTION ----------
              const SizedBox(height: 24),

              Divider(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.25),
                thickness: 1,
                height: 1,
              ),

              const SizedBox(height: 24),
              const SizedBox(height: 24),

              _navTile(
                context,
                index: 2,
                title: 'Settings',
                icon: CupertinoIcons.gear,
              ),

              _navTile(
                context,
                index: 3,
                title: 'About',
                icon: CupertinoIcons.info,
              ),

              const Spacer(),

              // ---------- LOGOUT ----------
              Divider(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.25),
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 10),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: 34,
                leading: Icon(
                  CupertinoIcons.square_arrow_right,
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                title: Text(
                  'Log out',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.95),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
