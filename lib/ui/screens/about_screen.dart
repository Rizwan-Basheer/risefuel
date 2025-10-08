import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.appVersion = '1.0.0'});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.format_quote,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daily Quotes',
                  style: AppTextStyles.sectionTitle(context),
                ),
                Text(
                  'Version $appVersion',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'RiseFuel inspires you with a fresh quote whenever you need a lift. Save favourites, share with friends, and keep the positivity flowing whether you are online or offline.',
          style: AppTextStyles.body(context),
        ),
        const SizedBox(height: 32),
        Text(
          'Developed by RiseFuel',
          style: AppTextStyles.sectionTitle(context),
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ❤️ using Flutter',
          style: AppTextStyles.body(context),
        ),
        const SizedBox(height: 24),
        Text(
          'Contact',
          style: AppTextStyles.sectionTitle(context),
        ),
        const SizedBox(height: 12),
        _AboutLinkTile(
          label: 'GitHub',
          value: 'github.com/Rizwan-Basheer/risefuel',
          icon: Icons.code,
        ),
        _AboutLinkTile(
          label: 'Email',
          value: 'hello@risefuel.app',
          icon: Icons.email_outlined,
        ),
      ],
    );
  }
}

class _AboutLinkTile extends StatelessWidget {
  const _AboutLinkTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(
        label,
        style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // Placeholder for future deep links or actions.
      },
    );
  }
}

