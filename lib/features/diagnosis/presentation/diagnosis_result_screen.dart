import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final String diagnosisId;
  const DiagnosisResultScreen({super.key, required this.diagnosisId});

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> with SingleTickerProviderStateMixin {
  bool _loading = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  // Demo data
  final _result = {
    'cropName': 'Rice',
    'status': 'completed',
    'diseaseName': 'Bacterial Leaf Blight',
    'severity': 'moderate',
    'confidence': 0.87,
    'description': 'Bacterial leaf blight (BLB) is one of the most serious diseases of rice. It causes wilting of seedlings, yellowing and drying of leaves.',
    'recommendations': [
      'Apply copper-based bactericides like copper hydroxide',
      'Use resistant varieties (e.g., IR-64, Swarna)',
      'Avoid excess nitrogen fertilization',
      'Ensure proper drainage in the field',
      'Remove and destroy infected plant debris',
    ],
    'preventiveMeasures': [
      'Use certified disease-free seed',
      'Practice crop rotation with non-host crops',
      'Maintain balanced fertilization',
    ],
    'images': [
      'https://images.unsplash.com/photo-1536304993881-460e47950734?w=400&q=80',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _loading = false);
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
      body: _loading ? _buildLoading() : _buildResult(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 80, height: 80,
            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.brand600),
          ),
          const SizedBox(height: 24),
          const Text('Analyzing your crop...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 8),
          Text('Our AI is examining the images', style: TextStyle(fontSize: 13, color: AppColors.gray400)),
        ]),
      ),
    );
  }

  Widget _buildResult() {
    final severity = _result['severity'] as String;
    final confidence = (_result['confidence'] as double) * 100;
    final (bg, fg, label) = switch (severity) {
      'severe' => (AppColors.orange100, AppColors.orange700, 'Severe'),
      'moderate' => (AppColors.yellow100, AppColors.yellow700, 'Moderate'),
      'critical' => (AppColors.red100, AppColors.red700, 'Critical'),
      _ => (AppColors.green100, AppColors.green700, 'Low'),
    };

    return FadeTransition(
      opacity: _fadeIn,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: (_result['images'] as List).first,
              height: 200, width: double.infinity, fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 200, color: AppColors.gray100),
              errorWidget: (_, __, ___) => Container(height: 200, color: AppColors.gray100,
                  child: const Center(child: Text('🌾', style: TextStyle(fontSize: 40)))),
            ),
          ),
          const SizedBox(height: 16),

          // Disease info card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(_result['diseaseName'] as String,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Text('🌾 ', style: TextStyle(fontSize: 12)),
                Text(_result['cropName'] as String, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
                const Spacer(),
                Text('${confidence.toStringAsFixed(0)}% confidence', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.brand600)),
              ]),
              const SizedBox(height: 12),

              // Confidence bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.gray100,
                  color: confidence > 80 ? AppColors.green500 : confidence > 50 ? AppColors.yellow500 : AppColors.red500,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Description
          _sectionCard('📋 About this Disease', [
            Text(_result['description'] as String,
                style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.5)),
          ]),
          const SizedBox(height: 12),

          // Recommendations
          _sectionCard('💊 Recommended Treatment', [
            ...(_result['recommendations'] as List<String>).asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 22, height: 22, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.brand50),
                  child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brand700))),
                ),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.4))),
              ]),
            )),
          ]),
          const SizedBox(height: 12),

          // Preventive measures
          _sectionCard('🛡️ Preventive Measures', [
            ...(_result['preventiveMeasures'] as List<String>).map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✅ ', style: TextStyle(fontSize: 12)),
                Expanded(child: Text(m, style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.4))),
              ]),
            )),
          ]),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}
