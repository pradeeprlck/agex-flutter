import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CreateCalendarScreen extends StatefulWidget {
  const CreateCalendarScreen({super.key});

  @override
  State<CreateCalendarScreen> createState() => _CreateCalendarScreenState();
}

class _CreateCalendarScreenState extends State<CreateCalendarScreen> {
  String _crop = '';
  final _varietyController = TextEditingController();
  String _season = 'Kharif';
  DateTime _startDate = DateTime.now();
  bool _submitting = false;

  final _seasons = ['Kharif', 'Rabi', 'Zaid', 'Summer', 'Perennial'];

  @override
  void dispose() {
    _varietyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_crop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a crop')));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar created!'), backgroundColor: AppColors.green500));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Calendar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.brand50, Colors.white]),
              borderRadius: BorderRadius.circular(16)),
            child: const Column(children: [
              Text('📅', style: TextStyle(fontSize: 40)),
              SizedBox(height: 8),
              Text('New Crop Calendar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
              SizedBox(height: 4),
              Text('Plan your crop activities', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
            ]),
          ),
          const SizedBox(height: 24),

          // Crop
          _label('Crop'),
          DropdownButtonFormField<String>(
            value: _crop.isEmpty ? null : _crop,
            hint: const Text('Select crop', style: TextStyle(fontSize: 14)),
            items: AppConstants.cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _crop = v ?? ''),
            decoration: const InputDecoration(),
          ),
          const SizedBox(height: 16),

          // Variety
          _label('Variety (Optional)'),
          TextField(
            controller: _varietyController,
            decoration: const InputDecoration(hintText: 'e.g. BPT-5204'),
          ),
          const SizedBox(height: 16),

          // Season
          _label('Season'),
          DropdownButtonFormField<String>(
            value: _season,
            items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _season = v ?? 'Kharif'),
            decoration: const InputDecoration(),
          ),
          const SizedBox(height: 16),

          // Start date
          _label('Start Date'),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2023),
                lastDate: DateTime(2026),
              );
              if (date != null) setState(() => _startDate = date);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray300),
                borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    style: const TextStyle(fontSize: 14, color: AppColors.gray700)),
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.gray400),
              ]),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Calendar'),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
  );
}
