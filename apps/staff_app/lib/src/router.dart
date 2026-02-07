import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/chat/chat_room_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/tasks/task_detail_screen.dart';
import 'features/team/team_screen.dart';
import 'shell/staff_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':roomId',
                redirect: (context, state) {
                  final roomId = state.pathParameters['roomId'] ?? '';
                  return roomId.trim().isEmpty ? '/chat' : null;
                },
                builder: (context, state) {
                  final roomId = state.pathParameters['roomId']!;
                  return ChatRoomScreen(roomId: roomId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
            routes: [
              GoRoute(
                path: ':taskId',
                redirect: (context, state) {
                  final taskId = state.pathParameters['taskId'] ?? '';
                  return taskId.trim().isEmpty ? '/tasks' : null;
                },
                builder: (context, state) {
                  final taskId = state.pathParameters['taskId']!;
                  return TaskDetailScreen(taskId: taskId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/team',
            builder: (context, state) => const TeamScreen(),
          ),
        ],
      ),
    ],
  );
});
