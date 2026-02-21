import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:get_it/get_it.dart';
import '../../../data/datasources/connection_service.dart';
import '../../../data/datasources/user_profile_service.dart';
import '../../../data/datasources/firebase_auth_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/connection_request.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final connectionService = GetIt.I<ConnectionService>();
  final userProfileService = GetIt.I<UserProfileService>();
  final authService = GetIt.I<FirebaseAuthService>();
  final TextEditingController _searchController = TextEditingController();

  List<UserEntity> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    try {
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        final results =
            await connectionService.searchUsers(query, currentUser.uid);
        setState(() {
          searchResults = results;
          isSearching = false;
        });
      }
    } catch (e) {
      setState(() => isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Requests'),
            Tab(text: 'Connections'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon:
                    const Icon(CupertinoIcons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDiscoverTab(),
                      _buildRequestsTab(),
                      _buildConnectionsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserCard(searchResults[index])
            .animate()
            .fadeIn(delay: (index * 50).ms);
      },
    );
  }

  Future<List<UserEntity>> _getSuggestedConnections() async {
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      return await connectionService.getSuggestedConnections(currentUser.uid);
    }
    return <UserEntity>[];
  }

  Widget _buildDiscoverTab() {
    return FutureBuilder<List<UserEntity>>(
      future: _getSuggestedConnections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.person_2,
                    size: 64, color: AppColors.secondaryText),
                const SizedBox(height: 16),
                Text(
                  'No suggestions at the moment',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildUserCard(snapshot.data![index])
                .animate()
                .fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please login'));
    }

    return StreamBuilder<List<ConnectionRequest>>(
      stream: connectionService.getReceivedRequests(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.bell,
                    size: 64, color: AppColors.secondaryText),
                const SizedBox(height: 16),
                Text(
                  'No connection requests',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildRequestCard(snapshot.data![index])
                .animate()
                .fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }

  Widget _buildConnectionsTab() {
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please login'));
    }

    return FutureBuilder<List<UserEntity>>(
      future: connectionService.getUserConnections(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.person_2_fill,
                    size: 64, color: AppColors.secondaryText),
                const SizedBox(height: 16),
                Text(
                  'No connections yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildConnectionCard(snapshot.data![index])
                .animate()
                .fadeIn(delay: (index * 50).ms);
          },
        );
      },
    );
  }

  Widget _buildUserCard(UserEntity user) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      height: null,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage: user.profilePhotoUrl != null
                ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                : null,
            child: user.profilePhotoUrl == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user.department,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (user.isAlumni)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: const Text(
                      'Alumni',
                      style: TextStyle(fontSize: 10, color: AppColors.accent),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final currentUser = authService.currentUser;
                if (currentUser != null) {
                  try {
                    await connectionService.sendConnectionRequest(
                      senderId: currentUser.uid,
                      receiverId: user.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connection request sent!'),
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
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Connect'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ConnectionRequest request) {
    return FutureBuilder<UserEntity?>(
      future: userProfileService.getUserById(request.senderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final user = snapshot.data!;
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 16),
          height: null,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                backgroundImage: user.profilePhotoUrl != null
                    ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                    : null,
                child: user.profilePhotoUrl == null
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      user.department,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final currentUser = authService.currentUser;
                      if (currentUser != null) {
                        await connectionService.acceptConnectionRequest(
                          request.id,
                          request.senderId,
                          currentUser.uid,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connection accepted!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(CupertinoIcons.checkmark_circle_fill,
                        color: AppColors.success),
                  ),
                  IconButton(
                    onPressed: () async {
                      await connectionService
                          .rejectConnectionRequest(request.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connection request rejected'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.xmark_circle_fill,
                        color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionCard(UserEntity user) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      height: null,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            backgroundImage: user.profilePhotoUrl != null
                ? CachedNetworkImageProvider(user.profilePhotoUrl!)
                : null,
            child: user.profilePhotoUrl == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user.department,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to chat
              // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(colleagueName: user.name)));
            },
            icon: const Icon(CupertinoIcons.chat_bubble_fill,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
