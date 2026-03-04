import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CropCalendarListScreen extends StatelessWidget {
  const CropCalendarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendars = [
      {'id': '1', 'crop': 'Rice (Kharif)', 'variety': 'BPT-5204', 'startDate': 'Jun 2024', 'progress': 0.65, 'totalTasks': 24, 'completedTasks': 16},
      {'id': '2', 'crop': 'Cotton', 'variety': 'Bt Cotton', 'startDate': 'Jul 2024', 'progress': 0.40, 'totalTasks': 20, 'completedTasks': 8},
      {'id': '3', 'crop': 'Maize (Rabi)', 'variety': 'DHM-117', 'startDate': 'Oct 2024', 'progress': 0.15, 'totalTasks': 18, 'completedTasks': 3},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Calendars')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-calendar'),
        backgroundColor: AppColors.brand600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Calendar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: calendars.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📅', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              const Text('No crop calendars', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/create-calendar'),
                child: const Text('Create Calendar'),
              ),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: calendars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CalendarCard(
                data: calendars[i],
                onTap: () => context.push('/crop-calendar/${calendars[i]['id']}'),
              ),
            ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _CalendarCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = data['progress'] as double;
    final percent = (progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.brand500, AppColors.brand700]),
                borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('📅', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['crop'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray800)),
              const SizedBox(height: 2),
              Text('${data['variety']} · Started ${data['startDate']}',
                  style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
            ])),
            Text('$percent%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.brand600)),
          ]),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress, minHeight: 8,
              backgroundColor: AppColors.gray100,
              color: progress >= 0.7 ? AppColors.green500 : progress >= 0.4 ? AppColors.brand500 : AppColors.yellow500,
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${data['completedTasks']}/${data['totalTasks']} tasks completed',
                style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.gray400),
          ]),
        ]),
      ),
    );
  }
}
