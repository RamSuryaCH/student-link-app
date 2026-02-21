import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:student_link_app/data/datasources/admin_service.dart';
import 'package:student_link_app/core/di/injection.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adminService = getIt<AdminService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Content'),
            Tab(text: 'Clubs'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UserManagementTab(),
          _ContentModerationTab(),
          _ClubApprovalTab(),
          _StatisticsTab(),
        ],
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  const _UserManagementTab();

  @override
  Widget build(BuildContext context) {
    final adminService = getIt<AdminService>();

    return StreamBuilder(
      stream: adminService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  backgroundImage: user.profilePhotoUrl != null
                      ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                      : null,
                  child: user.profilePhotoUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Ban User'),
                      onTap: () async {
                        await adminService.banUser(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${user.name} has been banned'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        }
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Make Admin'),
                      onTap: () async {
                        await adminService.updateUserRole(user.id, 'admin');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${user.name} is now an admin'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('Delete User'),
                      onTap: () async {
                        await adminService.deleteUser(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User deleted'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }
}

class _ContentModerationTab extends StatelessWidget {
  const _ContentModerationTab();

  @override
  Widget build(BuildContext context) {
    final adminService = getIt<AdminService>();

    return StreamBuilder(
      stream: adminService.getReportedContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No reported content'));
        }

        final reports = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(
                  CupertinoIcons.exclamationmark_shield,
                  color: AppColors.warning,
                ),
                title: Text('Reported ${report['type']}'),
                subtitle: Text('${report['reportCount']} reports'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Content: ${report['content']}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await adminService.deleteContent(
                                  report['id'],
                                  report['type'],
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Content deleted'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                await adminService.dismissReport(report['id']);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Report dismissed'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Dismiss'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }
}

class _ClubApprovalTab extends StatelessWidget {
  const _ClubApprovalTab();

  @override
  Widget build(BuildContext context) {
    final adminService = getIt<AdminService>();

    return StreamBuilder(
      stream: adminService.getPendingClubApprovals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pending club approvals'));
        }

        final clubs = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (club.coverImageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: club.coverImageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          club.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Category: ${club.category}',
                          style: const TextStyle(color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await adminService.approveClub(club.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${club.name} approved'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await adminService.rejectClub(club.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${club.name} rejected'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    final adminService = getIt<AdminService>();

    return FutureBuilder(
      future: adminService.getAppStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No statistics available'));
        }

        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatCard(
                context,
                'Total Users',
                stats['totalUsers'].toString(),
                CupertinoIcons.person_2,
                AppColors.primary,
              ),
              _buildStatCard(
                context,
                'Active Users (24h)',
                stats['activeUsers'].toString(),
                CupertinoIcons.person_crop_circle_fill,
                AppColors.success,
              ),
              _buildStatCard(
                context,
                'Total Posts',
                stats['totalPosts'].toString(),
                CupertinoIcons.doc_text,
                AppColors.accent,
              ),
              _buildStatCard(
                context,
                'Total Clubs',
                stats['totalClubs'].toString(),
                CupertinoIcons.group,
                AppColors.warning,
              ),
              _buildStatCard(
                context,
                'Messages Sent',
                stats['totalMessages'].toString(),
                CupertinoIcons.chat_bubble_2,
                AppColors.info,
              ),
              _buildStatCard(
                context,
                'Connections Made',
                stats['totalConnections'].toString(),
                CupertinoIcons.link,
                AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
  }
}
