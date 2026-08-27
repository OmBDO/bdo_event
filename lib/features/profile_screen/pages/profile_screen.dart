import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isNotificationEnabled = true;
  bool _isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = AuthRepository.currentUser;
    const primaryColor = Color(0xFFE96B47);
    const darkText = Color(0xFF2D0C57);
    const greyText = Color(0xFF9586A8);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(30),

            // 1. Premium Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            "https://yt3.ggpht.com/yti/ANjgQV_bOKivh_MVo0VJcxLjy_iAfiAyY4wThz34mHihfEe6ow=s88-c-k-c0x00ffffff-no-rj",
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor,
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(
                    user?.displayName ?? 'BDO Events member',
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const Gap(10),

            // 2. Settings Sections Layout Groupings
            _buildSectionHeader("Account Settings"),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.person_outline_rounded,
                color: Colors.blue,
                title: "Edit Profile",
                subtitle: "Change name, email, and bio details",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.calendar_month_outlined,
                color: Colors.orange,
                title: "My Event Registrations",
                subtitle: "View tickets and saved festivals",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.payment_rounded,
                color: Colors.green,
                title: "Payment Methods",
                subtitle: "Linked cards and digital wallets",
                onTap: () {},
              ),
            ]),

            const Gap(16),

            _buildSectionHeader("Preferences"),
            _buildSettingsGroup([
              _buildSettingsToggle(
                icon: Icons.notifications_none_rounded,
                color: Colors.deepPurple,
                title: "Push Notifications",
                subtitle: "Alerts for upcoming festival updates",
                value: _isNotificationEnabled,
                onChanged: (val) =>
                    setState(() => _isNotificationEnabled = val),
              ),
              _buildSettingsToggle(
                icon: Icons.dark_mode_outlined,
                color: Colors.blueGrey,
                title: "Dark Theme Mode",
                subtitle: "Toggle dark mode interface canvas",
                value: _isDarkModeEnabled,
                onChanged: (val) => setState(() => _isDarkModeEnabled = val),
              ),
              _buildSettingsTile(
                icon: Icons.language_rounded,
                color: Colors.teal,
                title: "App Language",
                subtitle: "English (IN)",
                onTap: () {},
              ),
            ]),

            const Gap(16),

            _buildSectionHeader("Support & Legal"),
            _buildSettingsGroup([
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                color: Colors.indigo,
                title: "Help Center & FAQ",
                subtitle: "Troubleshooting and event booking help",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.shield_outlined,
                color: Colors.amber,
                title: "Privacy Policy",
                subtitle: "Terms of service and data security rules",
                onTap: () {},
              ),
            ]),

            const Gap(24),

            // 3. Destructive Logout Layout Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color(0xFFB1D4FA)
                      .withValues(alpha: 0.6),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  "Log Out Account",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            // 4. Padding Buffer for Footer Navigation Systems
            ValueListenableBuilder<double>(
              valueListenable: FooterHeightTracker.heightNotifier,
              builder: (context, dynamicHeight, child) {
                return SizedBox(height: dynamicHeight + 24);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Component Helper: Section Title Header
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // Component Helper: FIXED Grouped Card Outer Layout Wrapper
  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // 🚀 THE FIX: Enforcing Material behavior context globally across list nodes
        child: Material(
          color: Colors.transparent,
          child: Column(children: children),
        ),
      ),
    );
  }

  // Component Helper: Standard Interactive Settings Option Tile
  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2D0C57),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF9586A8),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.black26,
        size: 14,
      ),
    );
  }

  // Component Helper: Interactive Switch Toggle Settings Option Tile
  Widget _buildSettingsToggle({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),

          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2D0C57),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF9586A8),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        // ignore: deprecated_member_use
        activeColor: const Color(0xFFE96B47),
      ),
    );
  }
}
