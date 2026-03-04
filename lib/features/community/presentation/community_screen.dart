import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _selectedTopic = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _topics = ['All', 'Pest Control', 'Fertilizers', 'Irrigation', 'Seeds', 'Market'];

  final List<Map<String, dynamic>> _questions = [
    {
      'id': '1',
      'title': 'When is the best time to apply DAP fertilizer for rice?',
      'body': 'I am growing rice in kharif season. Need guidance on fertilizer schedule.',
      'author': 'Ramesh K',
      'tags': ['Fertilizers', 'Rice'],
      'votes': 12,
      'answers': 3,
      'createdAt': '2h ago',
    },
    {
      'id': '2',
      'title': 'How to identify fall armyworm in maize?',
      'body': 'I noticed some holes in the leaves of my maize crop. Could it be fall armyworm?',
      'author': 'Suresh M',
      'tags': ['Pest Control', 'Maize'],
      'votes': 7,
      'answers': 5,
      'createdAt': '5h ago',
    },
    {
      'id': '3',
      'title': 'Best drip irrigation system for cotton',
      'body': 'Planning to install drip irrigation for 5 acres of cotton. Recommendations?',
      'author': 'Lakshmi P',
      'tags': ['Irrigation', 'Cotton'],
      'votes': 15,
      'answers': 8,
      'createdAt': '1d ago',
    },
    {
      'id': '4',
      'title': 'Getting good prices for organic tomatoes',
      'body': 'I grow organic tomatoes. Where can I get better prices beyond mandi?',
      'author': 'Anjali D',
      'tags': ['Market', 'Tomato'],
      'votes': 9,
      'answers': 4,
      'createdAt': '2d ago',
    },
    {
      'id': '5',
      'title': 'Which BT cotton seed variety for Telangana region?',
      'body': 'Need suggestions for high-yield BT cotton varieties suited for Telangana climate.',
      'author': 'Bala R',
      'tags': ['Seeds', 'Cotton'],
      'votes': 6,
      'answers': 2,
      'createdAt': '3d ago',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    var items = _questions;
    if (_selectedTopic != 'All') {
      items = items.where((q) => (q['tags'] as List).contains(_selectedTopic)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((qn) =>
          (qn['title'] as String).toLowerCase().contains(q) ||
          (qn['body'] as String).toLowerCase().contains(q)).toList();
    }
    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ask-question'),
        backgroundColor: AppColors.brand600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ask', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search questions...', prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18),
                      onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                  : null,
            ),
          ),
        ),

        // Topic chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final topic = _topics[i];
              final active = topic == _selectedTopic;
              return ChoiceChip(
                label: Text(topic, style: TextStyle(
                    fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    color: active ? Colors.white : AppColors.gray600)),
                selected: active,
                onSelected: (_) => setState(() => _selectedTopic = topic),
                selectedColor: AppColors.brand600,
                backgroundColor: Colors.white,
                side: BorderSide(color: active ? AppColors.brand600 : AppColors.gray200),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: items.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('💬', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('No questions found', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _QuestionCard(
                    data: items[i],
                    onTap: () => context.push('/question/${items[i]['id']}'),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _QuestionCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          Text(data['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(data['body'], style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),

          // Tags
          Wrap(spacing: 6, runSpacing: 4, children: [
            ...(data['tags'] as List).map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.brand50, borderRadius: BorderRadius.circular(20)),
              child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.brand700)),
            )),
          ]),
          const SizedBox(height: 10),

          // Footer
          Row(children: [
            const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.gray400),
            const SizedBox(width: 2),
            Text('${data['votes']}', style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.w500)),
            const SizedBox(width: 14),
            const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.gray400),
            const SizedBox(width: 2),
            Text('${data['answers']}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            const Spacer(),
            Text(data['author'], style: const TextStyle(fontSize: 11, color: AppColors.brand600, fontWeight: FontWeight.w500)),
            const Text(' · ', style: TextStyle(color: AppColors.gray300)),
            Text(data['createdAt'], style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          ]),
        ]),
      ),
    );
  }
}
