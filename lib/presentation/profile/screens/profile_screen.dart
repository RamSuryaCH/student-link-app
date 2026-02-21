import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:get_it/get_it.dart';
import '../../../data/datasources/firebase_auth_service.dart';
import '../../../data/datasources/user_profile_service.dart';
import '../../../domain/entities/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../anonyspace/screens/anonyspace_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = GetIt.I<FirebaseAuthService>();
  final userProfileService = GetIt.I<UserProfileService>();

  void _showEditProfileDialog(UserEntity user) {
    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio ?? '');
    final departmentController = TextEditingController(text: user.department);
    final yearController = TextEditingController(text: user.yearOfStudy ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassContainer(
          margin: const EdgeInsets.all(16),
          height: null,
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark_circle, color: AppColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: departmentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Department',
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Year of Study',
                  filled: true,
                  fillColor: AppColors.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await userProfileService.updateUserProfile(
                        userId: user.id,
                        name: nameController.text.trim(),
                        bio: bioController.text.trim(),
                        department: departmentController.text.trim(),
                        yearOfStudy: yearController.text.trim(),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.userChanges.value;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      body: StreamBuilder<UserEntity?>(
        stream: userProfileService.getUserStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found'));
          }

          final user = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // App Bar with Cover Photo
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover photo
                      user.coverPhotoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: user.coverPhotoUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                            ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                      // Profile photo
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary,
                            backgroundImage: user.profilePhotoUrl != null
                                ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                                : null,
                            child: user.profilePhotoUrl == null
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.settings),
                    onPressed: () {
                      _showSettingsMenu(context);
                    },
                  ),
                ],
              ),

              // Profile content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and role
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 28,
                                  ),
                                ).animate().fadeIn(),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (user.isAlumni)
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Alumni',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (user.role == 'Admin')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Admin',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _showEditProfileDialog(user),
                              icon: const Icon(CupertinoIcons.pencil, size: 16),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stats
                      GlassContainer(
                        height: null,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              'Connections',
                              user.connectionIds.length.toString(),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.secondaryText.withOpacity(0.3),
                            ),
                            _buildStatItem(
                              context,
                              'Posts',
                              '0', // Would need to query posts
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.secondaryText.withOpacity(0.3),
                            ),
                            _buildStatItem(
                              context,
                              'Clubs',
                              '0', // Would need to query clubs
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),

                      // Bio section
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GlassContainer(
                          height: null,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            user.bio!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 24),
                      ],

                      // Info section
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        height: null,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              CupertinoIcons.building_2_fill,
                              'Department',
                              user.department,
                            ),
                            if (user.yearOfStudy != null) ...[
                              const Divider(color: AppColors.secondaryText, height: 24),
                              _buildInfoRow(
                                CupertinoIcons.calendar,
                                'Year of Study',
                                user.yearOfStudy!,
                              ),
                            ],
                            const Divider(color: AppColors.secondaryText, height: 24),
                            _buildInfoRow(
                              CupertinoIcons.mail,
                              'Email',
                              user.email,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Interests
                      if (user.interests.isNotEmpty) ...[
                        Text(
                          'Interests',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamBuilder<UserEntity?>(
        stream: userProfileService.getUserStream(authService.currentUser!.uid),
        builder: (context, snapshot) {
          final isAdmin = snapshot.data?.role == 'admin';

          return GlassContainer(
            margin: const EdgeInsets.all(16),
            height: null,
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin) ...[
                  ListTile(
                    leading: const Icon(CupertinoIcons.shield_lefthalf_fill, color: AppColors.warning),
                    title: const Text('Admin Dashboard'),
                    trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                      );
                    },
                  ),
                  const Divider(color: AppColors.secondaryText, height: 1),
                ],
                ListTile(
                  leading: const Icon(CupertinoIcons.eye_slash, color: AppColors.accent),
                  title: const Text('Anonymous Space'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnonySpaceScreen()),
                    );
                  },
                ),
                const Divider(color: AppColors.secondaryText, height: 1),
                ListTile(
                  leading: const Icon(CupertinoIcons.settings, color: AppColors.primary),
                  title: const Text('Settings'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: AppColors.secondaryText, height: 1),
                ListTile(
                  leading: const Icon(CupertinoIcons.info_circle, color: AppColors.info),
                  title: const Text('About'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: AppColors.secondaryText, height: 1),
                ListTile(
                  leading: const Icon(CupertinoIcons.power, color: AppColors.error),
                  title: const Text('Logout'),
                  onTap: () async {
                    await authService.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
