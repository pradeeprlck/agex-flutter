import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CropCalendarScreen extends StatefulWidget {
  final String calendarId;
  const CropCalendarScreen({super.key, required this.calendarId});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  final Map<String, List<Map<String, dynamic>>> _tasksByMonth = {
    'June 2024': [
      {'id': '1', 'title': 'Land Preparation', 'description': 'Plough and level the field', 'done': true},
      {'id': '2', 'title': 'Seed Treatment', 'description': 'Treat seeds with Carbendazim', 'done': true},
      {'id': '3', 'title': 'Nursery Sowing', 'description': 'Sow pre-germinated seeds in nursery', 'done': true},
    ],
    'July 2024': [
      {'id': '4', 'title': 'Transplanting', 'description': 'Transplant 25-day old seedlings', 'done': true},
      {'id': '5', 'title': 'Basal Fertilizer', 'description': 'Apply DAP + MOP as basal dose', 'done': true},
      {'id': '6', 'title': 'Weed Management', 'description': 'Apply pre-emergence herbicide', 'done': false},
    ],
    'August 2024': [
      {'id': '7', 'title': 'Top Dressing - 1', 'description': 'Apply Urea at tillering stage', 'done': false},
      {'id': '8', 'title': 'Pest Monitoring', 'description': 'Check for stem borer & BPH', 'done': false},
      {'id': '9', 'title': 'Water Management', 'description': 'Maintain 5cm standing water', 'done': false},
    ],
    'September 2024': [
      {'id': '10', 'title': 'Top Dressing - 2', 'description': 'Apply Urea at panicle initiation', 'done': false},
      {'id': '11', 'title': 'Disease Monitoring', 'description': 'Check for blast & BLB', 'done': false},
    ],
    'October 2024': [
      {'id': '12', 'title': 'Drain Water', 'description': 'Drain field 15 days before harvest', 'done': false},
      {'id': '13', 'title': 'Harvest', 'description': 'Harvest at 85% grain maturity', 'done': false},
    ],
  };

  int get _totalTasks => _tasksByMonth.values.fold(0, (sum, m) => sum + m.length);
  int get _completedTasks => _tasksByMonth.values.fold(0, (sum, m) => sum + m.where((t) => t['done'] == true).length);
  double get _progress => _totalTasks > 0 ? _completedTasks / _totalTasks : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rice (Kharif)')),
      body: Column(children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF15803D), AppColors.brand600]),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('BPT-5204 · Kharif 2024', style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 4),
                Text('$_completedTasks of $_totalTasks tasks done',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Center(child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                )),
              ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress, minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Colors.white,
              ),
            ),
          ]),
        ),

        // Tasks
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _tasksByMonth.entries.map((entry) {
              final month = entry.key;
              final tasks = entry.value;
              final monthCompleted = tasks.where((t) => t['done'] == true).length;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(month, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                  Text('$monthCompleted/${tasks.length}', style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                ]),
                const SizedBox(height: 8),
                ...tasks.map((task) => _TaskTile(
                  task: task,
                  onToggle: () => setState(() => task['done'] = !(task['done'] as bool)),
                )),
                const SizedBox(height: 16),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggle;
  const _TaskTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = task['done'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? AppColors.green50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? AppColors.green200 : AppColors.gray100),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.green500 : Colors.transparent,
              border: Border.all(color: done ? AppColors.green500 : AppColors.gray300, width: 2),
            ),
            child: done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task['title'] as String,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: done ? AppColors.gray400 : AppColors.gray800,
                  decoration: done ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 2),
          Text(task['description'] as String,
              style: TextStyle(fontSize: 11, color: done ? AppColors.gray400 : AppColors.gray500)),
        ])),
      ]),
    );
  }
}
