import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final List<String> _selectedTags = [];
  bool _submitting = false;

  final _allTags = ['Pest Control', 'Fertilizers', 'Irrigation', 'Seeds', 'Market', 'Weather', 'Soil', 'Organic'];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in the title and body')));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question posted!'), backgroundColor: AppColors.green500));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask a Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Graphic
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.brand50, Colors.white]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(children: [
              Text('💡', style: TextStyle(fontSize: 36)),
              SizedBox(height: 8),
              Text('Ask the Community', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
              SizedBox(height: 4),
              Text('Get help from experienced farmers', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
            ]),
          ),
          const SizedBox(height: 24),

          // Title
          const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'What\'s your question?'),
            maxLength: 200,
          ),
          const SizedBox(height: 16),

          // Body
          const Text('Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 6),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(hintText: 'Describe your question in detail...'),
            maxLines: 6,
            maxLength: 2000,
          ),
          const SizedBox(height: 16),

          // Tags
          const Text('Tags', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: _allTags.map((t) {
            final selected = _selectedTags.contains(t);
            return FilterChip(
              label: Text(t, style: TextStyle(fontSize: 12,
                  color: selected ? Colors.white : AppColors.gray600,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
              selected: selected,
              selectedColor: AppColors.brand600,
              backgroundColor: Colors.white,
              side: BorderSide(color: selected ? AppColors.brand600 : AppColors.gray200),
              onSelected: (_) {
                setState(() {
                  if (selected) {
                    _selectedTags.remove(t);
                  } else if (_selectedTags.length < 3) {
                    _selectedTags.add(t);
                  }
                });
              },
            );
          }).toList()),
          Text('Choose up to 3 tags', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Post Question'),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
