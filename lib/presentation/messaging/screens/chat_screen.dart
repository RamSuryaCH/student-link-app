import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/common/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatScreen extends StatelessWidget {
  final String colleagueName;
  
  const ChatScreen({Key? key, required this.colleagueName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(colleagueName),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.video_camera), onPressed: () {}),
          IconButton(icon: const Icon(CupertinoIcons.phone), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // typical chat layout
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) {
                bool isMe = index % 2 == 0;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: GlassContainer(
                    width: MediaQuery.of(context).size.width * 0.7,
                    margin: const EdgeInsets.only(bottom: 12),
                    borderRadius: 16,
                    child: Text(
                      isMe ? "Hey, are you joining the ACM club meeting later?" : "Yes! I just finished my Pomodoro session.",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ).animate().slideX(
                    begin: isMe ? 0.2 : -0.2, 
                    duration: 300.ms, 
                    curve: Curves.easeOutCubic
                  ).fade(),
                );
              },
            ),
          ),
          
          // Chat Input Footer
          Container(
            padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))
              ]
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppColors.secondaryText),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.location_fill, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
