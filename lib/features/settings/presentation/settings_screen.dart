import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'English';
  bool _pushNotifications = true;
  bool _alertNotifications = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.brand50, Colors.white]),
              borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.brand600,
                child: Text(auth.displayName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Text(auth.displayName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
              const SizedBox(height: 2),
              Text(auth.phone, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
            ]),
          ),
          const SizedBox(height: 24),

          // Account
          _sectionTitle('Account'),
          const SizedBox(height: 8),
          _settingsTile(
            icon: Icons.person_outline_rounded, title: 'Farm Profile',
            subtitle: 'Manage farm details & crops',
            onTap: () => context.push('/farm-profile'),
          ),
          _settingsTile(
            icon: Icons.history_rounded, title: 'Diagnosis History',
            subtitle: 'View all past diagnoses',
            onTap: () => context.go('/history'),
          ),
          _settingsTile(
            icon: Icons.science_outlined, title: 'Soil Tests',
            subtitle: 'View soil test reports',
            onTap: () => context.push('/soil-tests'),
          ),
          const SizedBox(height: 20),

          // Preferences
          _sectionTitle('Preferences'),
          const SizedBox(height: 8),
          _settingsTileWithDropdown(
            icon: Icons.language_rounded, title: 'Language',
            value: _language,
            items: ['English', 'Hindi', 'Telugu', 'Kannada', 'Tamil', 'Marathi'],
            onChanged: (v) => setState(() => _language = v),
          ),
          _settingsTileWithSwitch(
            icon: Icons.notifications_outlined, title: 'Push Notifications',
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          _settingsTileWithSwitch(
            icon: Icons.warning_amber_rounded, title: 'Alert Notifications',
            value: _alertNotifications,
            onChanged: (v) => setState(() => _alertNotifications = v),
          ),
          const SizedBox(height: 20),

          // Support
          _sectionTitle('Support'),
          const SizedBox(height: 8),
          _settingsTile(icon: Icons.help_outline_rounded, title: 'Help & FAQ', subtitle: null, onTap: () {}),
          _settingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', subtitle: null, onTap: () {}),
          _settingsTile(icon: Icons.description_outlined, title: 'Terms of Service', subtitle: null, onTap: () {}),
          _settingsTile(icon: Icons.info_outline_rounded, title: 'About AgriExpert', subtitle: 'Version 1.0.0', onTap: () {}),
          const SizedBox(height: 24),

          // Logout
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 14)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout', style: TextStyle(color: AppColors.red500)),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                ref.read(authProvider.notifier).logout();
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.red500, size: 20),
            label: const Text('Logout', style: TextStyle(color: AppColors.red500, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red200),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray500));

  Widget _settingsTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppColors.gray600),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray800)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.gray500))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.gray400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  Widget _settingsTileWithSwitch({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppColors.gray600),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray800)),
        trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.brand600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _settingsTileWithDropdown({required IconData icon, required String title, required String value,
      required List<String> items, required ValueChanged<String> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppColors.gray600),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray800)),
        trailing: DropdownButton<String>(
          value: value, underline: const SizedBox(), isDense: true,
          style: const TextStyle(fontSize: 13, color: AppColors.brand600, fontWeight: FontWeight.w500),
          items: items.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
