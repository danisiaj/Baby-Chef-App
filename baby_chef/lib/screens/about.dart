// lib/screens/about_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Baby Formula',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,),
            subtitle: const Text(
              'An easy way to calculate baby formula recipes',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListTile(
            leading: const Icon(CupertinoIcons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'), 
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Disclaimer'),
            subtitle: const Text(
              'This app is to be used by Atrium Health personel only. '
              'Calcuations are based on the Atrium Health recipe files.',
            ),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.mail),
            title: const Text('Contact & Support'),
            subtitle: const Text('Give us feedback!'),
            onTap: () {
              // You can integrate url_launcher to open mailto:
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              // launch a URL with url_launcher
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Use'),
            onTap: () {
              // launch a URL with url_launcher
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Licenses'),
            onTap: () {
              // add license page
            }
          ),
        ],
      ),
    );
  }
}
