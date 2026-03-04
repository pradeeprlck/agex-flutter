import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SoilTestResultScreen extends StatelessWidget {
  final String testId;
  const SoilTestResultScreen({super.key, required this.testId});

  @override
  Widget build(BuildContext context) {
    // Demo data
    const rating = 'moderate';
    final (ratingBg, ratingFg, ratingLabel, ratingEmoji) = switch (rating) {
      'good' => (AppColors.green100, AppColors.green700, 'Good Health', '🟢'),
      'moderate' => (AppColors.yellow100, AppColors.yellow700, 'Moderate Health', '🟡'),
      _ => (AppColors.red100, AppColors.red700, 'Poor Health', '🔴'),
    };

    final params = [
      {'name': 'pH', 'value': 6.5, 'ideal': '6.0-7.5', 'status': 'optimal'},
      {'name': 'Nitrogen (N)', 'value': 180, 'ideal': '250-350 kg/ha', 'status': 'low'},
      {'name': 'Phosphorus (P)', 'value': 22, 'ideal': '20-30 kg/ha', 'status': 'optimal'},
      {'name': 'Potassium (K)', 'value': 195, 'ideal': '150-250 kg/ha', 'status': 'optimal'},
      {'name': 'Organic Carbon', 'value': 0.4, 'ideal': '> 0.5%', 'status': 'low'},
      {'name': 'EC', 'value': 0.8, 'ideal': '< 1.0 dS/m', 'status': 'optimal'},
    ];

    final deficiencies = [
      {'nutrient': 'Nitrogen', 'severity': 'Moderate', 'recommendation': 'Apply 40-50 kg Urea/acre at tillering stage'},
      {'nutrient': 'Organic Carbon', 'severity': 'Low', 'recommendation': 'Add FYM or vermicompost @ 5 tons/acre'},
    ];

    final recommendations = [
      'Apply balanced NPK fertilizer (12:32:16) as basal dose',
      'Add organic matter to improve carbon content',
      'Use green manuring with dhaincha or sunhemp',
      'Maintain proper field drainage',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Test Result'),
        actions: [IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Health rating hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ratingBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ratingFg.withOpacity(0.3)),
            ),
            child: Column(children: [
              Text(ratingEmoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(ratingLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ratingFg)),
              const SizedBox(height: 4),
              Text('Clay Loam · Rice', style: TextStyle(fontSize: 13, color: ratingFg.withOpacity(0.7))),
            ]),
          ),
          const SizedBox(height: 20),

          // Parameters grid
          const Text('📊 Soil Parameters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.8,
              mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemCount: params.length,
            itemBuilder: (_, i) {
              final p = params[i];
              final status = p['status'] as String;
              final (statBg, statFg) = status == 'optimal'
                  ? (AppColors.green50, AppColors.green700)
                  : status == 'low'
                      ? (AppColors.red50, AppColors.red600)
                      : (AppColors.yellow50, AppColors.yellow700);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray100)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(p['name'] as String, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${p['value']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: statBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statFg)),
                    ),
                  ]),
                  Text('Ideal: ${p['ideal']}', style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
                ]),
              );
            },
          ),
          const SizedBox(height: 20),

          // Deficiencies
          if (deficiencies.isNotEmpty) ...[
            const Text('⚠️ Deficiencies Found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
            const SizedBox(height: 12),
            ...deficiencies.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.red50, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red100)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(d['nutrient']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.red100, borderRadius: BorderRadius.circular(20)),
                    child: Text(d['severity']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.red700)),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(d['recommendation']!, style: const TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.4)),
              ]),
            )),
            const SizedBox(height: 16),
          ],

          // Recommendations
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brand50, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brand100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡 Recommendations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.brand700)),
              const SizedBox(height: 12),
              ...recommendations.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 20, height: 20, margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.brand100),
                    child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.brand700))),
                  ),
                  Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.4))),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
