import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _scrollController = ScrollController();

  final List<Map<String, dynamic>> _diagnoses = [
    {'id': '1', 'cropName': 'Rice', 'diseaseName': 'Bacterial Leaf Blight', 'severity': 'moderate', 'status': 'completed', 'createdAt': '2024-02-28', 'image': 'https://images.unsplash.com/photo-1536304993881-460e47950734?w=200&q=80'},
    {'id': '2', 'cropName': 'Tomato', 'diseaseName': 'Early Blight', 'severity': 'severe', 'status': 'completed', 'createdAt': '2024-02-25', 'image': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=200&q=80'},
    {'id': '3', 'cropName': 'Cotton', 'diseaseName': 'Healthy', 'severity': 'low', 'status': 'completed', 'createdAt': '2024-02-22', 'image': 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=200&q=80'},
    {'id': '4', 'cropName': 'Maize', 'diseaseName': 'Fall Armyworm', 'severity': 'critical', 'status': 'completed', 'createdAt': '2024-02-20', 'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=200&q=80'},
    {'id': '5', 'cropName': 'Wheat', 'diseaseName': 'Rust', 'severity': 'moderate', 'status': 'completed', 'createdAt': '2024-02-18', 'image': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=200&q=80'},
    {'id': '6', 'cropName': 'Rice', 'diseaseName': 'Brown Spot', 'severity': 'low', 'status': 'completed', 'createdAt': '2024-02-15', 'image': 'https://images.unsplash.com/photo-1536304993881-460e47950734?w=200&q=80'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _diagnoses;
    final q = _searchQuery.toLowerCase();
    return _diagnoses.where((d) =>
        (d['cropName'] as String).toLowerCase().contains(q) ||
        (d['diseaseName'] as String).toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis History')),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by crop or disease...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18),
                      onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                  : null,
            ),
          ),
        ),

        // Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${items.length} results', style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
          ),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: items.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🔍', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('No diagnoses found', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
                ]))
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _HistoryCard(data: items[i]),
                ),
        ),
      ]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final severity = data['severity'] as String;
    final (bg, fg) = switch (severity) {
      'severe' => (AppColors.orange100, AppColors.orange700),
      'moderate' => (AppColors.yellow100, AppColors.yellow700),
      'critical' => (AppColors.red100, AppColors.red700),
      _ => (AppColors.green100, AppColors.green700),
    };

    return GestureDetector(
      onTap: () {
        // Navigate to result
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: data['image'] ?? '',
              width: 56, height: 56, fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 56, height: 56, color: AppColors.gray100),
              errorWidget: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.gray100,
                  child: const Center(child: Text('🌾'))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['cropName'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
            const SizedBox(height: 2),
            Text(data['diseaseName'], style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            const SizedBox(height: 4),
            Text(data['createdAt'], style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(severity, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
          ),
        ]),
      ),
    );
  }
}
