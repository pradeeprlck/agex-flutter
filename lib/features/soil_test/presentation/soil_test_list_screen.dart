import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SoilTestListScreen extends StatefulWidget {
  const SoilTestListScreen({super.key});

  @override
  State<SoilTestListScreen> createState() => _SoilTestListScreenState();
}

class _SoilTestListScreenState extends State<SoilTestListScreen> {
  final List<Map<String, dynamic>> _tests = [
    {'id': '1', 'soilType': 'Clay Loam', 'crop': 'Rice', 'healthRating': 'good', 'ph': 6.5, 'date': '28 Feb 2024',
     'nitrogen': 280, 'phosphorus': 22, 'potassium': 195},
    {'id': '2', 'soilType': 'Red Soil', 'crop': 'Cotton', 'healthRating': 'moderate', 'ph': 7.2, 'date': '20 Feb 2024',
     'nitrogen': 180, 'phosphorus': 12, 'potassium': 140},
    {'id': '3', 'soilType': 'Sandy Loam', 'crop': 'Maize', 'healthRating': 'poor', 'ph': 5.2, 'date': '15 Feb 2024',
     'nitrogen': 120, 'phosphorus': 8, 'potassium': 90},
    {'id': '4', 'soilType': 'Black Soil', 'crop': 'Wheat', 'healthRating': 'good', 'ph': 6.8, 'date': '10 Feb 2024',
     'nitrogen': 310, 'phosphorus': 25, 'potassium': 220},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soil Tests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/new-soil-test'),
        backgroundColor: AppColors.brand600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _tests.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🧪', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              const Text('No soil tests yet', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/new-soil-test'),
                child: const Text('Add Soil Test'),
              ),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _tests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = _tests[i];
                return _SoilTestCard(
                  data: t,
                  onTap: () => context.push('/soil-test-result/${t['id']}'),
                );
              },
            ),
    );
  }
}

class _SoilTestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _SoilTestCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = data['healthRating'] as String;
    final (bg, fg, label) = switch (rating) {
      'good' => (AppColors.green100, AppColors.green700, 'Good'),
      'moderate' => (AppColors.yellow100, AppColors.yellow700, 'Moderate'),
      _ => (AppColors.red100, AppColors.red700, 'Poor'),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.brand50, borderRadius: BorderRadius.circular(10)),
                child: const Center(child: Text('🧪', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(data['soilType'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                Text(data['crop'], style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ]),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
              child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
            ),
          ]),
          const SizedBox(height: 12),

          // Quick stats
          Row(children: [
            _statChip('pH', '${data['ph']}'),
            const SizedBox(width: 8),
            _statChip('N', '${data['nitrogen']}'),
            const SizedBox(width: 8),
            _statChip('P', '${data['phosphorus']}'),
            const SizedBox(width: 8),
            _statChip('K', '${data['potassium']}'),
          ]),
          const SizedBox(height: 8),
          Text(data['date'], style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.gray500)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700)),
      ]),
    );
  }
}
