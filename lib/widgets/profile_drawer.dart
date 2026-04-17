import 'package:dt_mobile/login_screen.dart';
import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:dt_mobile/widgets/edit_profile.dart';
import 'package:flutter/material.dart';


class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {

  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await ProfileApiService.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const SizedBox(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                )
              else
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: (_profile?.image?.url != null &&
                          _profile!.image!.url!.isNotEmpty)
                          ? NetworkImage(_profile!.image!.url!)
                          : null,
                      child: (_profile?.image?.url == null ||
                          _profile!.image!.url!.isEmpty)
                          ? Text(
                        _profile?.name.isNotEmpty == true
                            ? _profile!.name[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile?.name ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _profile?.email ?? '-',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),

              _item(
                context,
                Icons.person_outline,
                "Profile Settings",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileCardScreen(),
                    ),
                  ).then((_) {
                    _fetchProfile();
                  });
                },
              ),
              _item(context, Icons.help_outline, "Help Center", () {
              }),
              _item(context, Icons.description_outlined, "Terms & Conditions", () {
              }),
              _item(context, Icons.report_problem_outlined, "Report a problem", () {
              }),
              _item(context, Icons.info_outline, "About Digital Twin", () {
              }),

              const Spacer(),

              /// LOGOUT
              GestureDetector(
                onTap: () {
                  _handleLogout(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated _item with onTap
  Widget _item(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  // Handle Logout Logic
  void _handleLogout(BuildContext context) {
    // TODO: Yaha aap SharedPreferences se data clear kar sakte ho
    // TODO: API call karke logout kar sakte ho
    // TODO: Local storage se token delete kar sakte ho

    // Example: SharedPreferences clear
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // Navigate to Login Screen - Replace all routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}
