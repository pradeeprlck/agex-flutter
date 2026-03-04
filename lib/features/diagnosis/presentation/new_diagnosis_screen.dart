import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class NewDiagnosisScreen extends StatefulWidget {
  const NewDiagnosisScreen({super.key});

  @override
  State<NewDiagnosisScreen> createState() => _NewDiagnosisScreenState();
}

class _NewDiagnosisScreenState extends State<NewDiagnosisScreen> {
  int _step = 1;
  final List<String> _images = [];
  String _cropName = '';
  final _symptomController = TextEditingController();
  bool _submitting = false;
  bool _showCropPicker = false;

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _addDemoImage() {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 images allowed')),
      );
      return;
    }
    setState(() {
      _images.add('https://images.unsplash.com/photo-1536304993881-460e47950734?w=300&q=80');
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _submitting = false);
      context.push('/diagnosis-result/demo-id');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Diagnosis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 24),

            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
            if (_step == 3) _buildStep3(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [1, 2, 3].map((s) {
        final isActive = _step >= s;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.brand600 : AppColors.gray200,
              ),
              child: Center(
                child: Text('$s', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.gray500)),
              ),
            ),
            if (s < 3) Container(
              width: 40, height: 2, margin: const EdgeInsets.symmetric(horizontal: 8),
              color: _step > s ? AppColors.brand600 : AppColors.gray200,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Crop Photos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        const SizedBox(height: 4),
        const Text('Take clear photos of affected leaves, stems, or fruits', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _addDemoImage,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.brand600,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.brand600.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Column(children: [
                  Text('📸', style: TextStyle(fontSize: 28)),
                  SizedBox(height: 8),
                  Text('Take Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _addDemoImage,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.brand200, width: 2),
                ),
                child: const Column(children: [
                  Text('🖼️', style: TextStyle(fontSize: 28)),
                  SizedBox(height: 8),
                  Text('Upload Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brand700)),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        if (_images.isNotEmpty)
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _images.asMap().entries.map((e) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(e.value, width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(top: -4, right: -4,
                  child: GestureDetector(
                    onTap: () => setState(() => _images.removeAt(e.key)),
                    child: Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red500),
                      child: const Center(child: Text('✕', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
              ],
            )).toList(),
          ),

        const SizedBox(height: 8),
        Center(child: Text('Up to 3 images allowed', style: TextStyle(fontSize: 11, color: AppColors.gray400))),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _images.isEmpty ? null : () => setState(() => _step = 2),
          child: const Text('Next →'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Crop Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        const SizedBox(height: 4),
        const Text('Select crop type and describe symptoms', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
        const SizedBox(height: 20),

        const Text('🌿 Crop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _showCropPicker = !_showCropPicker),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gray300)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_cropName.isEmpty ? 'Select crop...' : _cropName,
                  style: TextStyle(fontSize: 14, color: _cropName.isEmpty ? AppColors.gray400 : AppColors.gray800)),
              Text(_showCropPicker ? '▲' : '▼', style: const TextStyle(color: AppColors.gray400)),
            ]),
          ),
        ),

        if (_showCropPicker)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gray200)),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppConstants.cropOptions.length,
              itemBuilder: (_, i) {
                final crop = AppConstants.cropOptions[i];
                final selected = _cropName == crop;
                return ListTile(
                  dense: true,
                  selected: selected,
                  selectedTileColor: AppColors.brand50,
                  title: Text(crop, style: TextStyle(
                    fontSize: 13, color: selected ? AppColors.brand700 : AppColors.gray700,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                  onTap: () => setState(() { _cropName = crop; _showCropPicker = false; }),
                );
              },
            ),
          ),

        const SizedBox(height: 20),
        const Text('Symptoms Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700)),
        const SizedBox(height: 8),
        TextField(
          controller: _symptomController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Describe what you see...'),
        ),

        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('← Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _cropName.isEmpty ? null : () => setState(() => _step = 3),
              child: const Text('Next →'),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review & Submit', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(_images[i], width: 100, height: 100, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Crop', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
            Text(_cropName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
            if (_symptomController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Symptoms', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
              Text(_symptomController.text, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
            ],
          ]),
        ),

        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step = 2),
              child: const Text('← Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitting ? null : _handleSubmit,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('🚀 Submit'),
            ),
          ),
        ]),
      ],
    );
  }
}
