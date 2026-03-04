import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class NewSoilTestScreen extends StatefulWidget {
  const NewSoilTestScreen({super.key});

  @override
  State<NewSoilTestScreen> createState() => _NewSoilTestScreenState();
}

class _NewSoilTestScreenState extends State<NewSoilTestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _showMicro = false;

  // Primary params
  final _ph = TextEditingController(text: '6.5');
  final _nitrogen = TextEditingController();
  final _phosphorus = TextEditingController();
  final _potassium = TextEditingController();
  final _organicCarbon = TextEditingController();
  final _ec = TextEditingController();

  // Micro params
  final _zinc = TextEditingController();
  final _iron = TextEditingController();
  final _manganese = TextEditingController();
  final _copper = TextEditingController();
  final _boron = TextEditingController();
  final _sulphur = TextEditingController();

  String _soilType = '';
  String _cropName = '';

  @override
  void dispose() {
    for (final c in [_ph, _nitrogen, _phosphorus, _potassium, _organicCarbon, _ec, _zinc, _iron, _manganese, _copper, _boron, _sulphur]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soil test submitted!'), backgroundColor: AppColors.green500));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Soil Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.brand50, Colors.white]),
                borderRadius: BorderRadius.circular(16)),
              child: const Column(children: [
                Text('🧪', style: TextStyle(fontSize: 36)),
                SizedBox(height: 8),
                Text('Soil Test Parameters', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                SizedBox(height: 4),
                Text('Enter your soil test report values', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
              ]),
            ),
            const SizedBox(height: 20),

            // Soil Type
            _sectionTitle('Soil Type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _soilType.isEmpty ? null : _soilType,
              hint: const Text('Select soil type', style: TextStyle(fontSize: 14)),
              items: AppConstants.soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) => setState(() => _soilType = v ?? ''),
              decoration: const InputDecoration(),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Crop
            _sectionTitle('Crop'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _cropName.isEmpty ? null : _cropName,
              hint: const Text('Select crop', style: TextStyle(fontSize: 14)),
              items: AppConstants.cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) => setState(() => _cropName = v ?? ''),
              decoration: const InputDecoration(),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Primary parameters
            _sectionTitle('Primary Parameters'),
            const SizedBox(height: 12),
            _paramRow('pH', _ph, '0-14'),
            _paramRow('Nitrogen (N)', _nitrogen, 'kg/ha'),
            _paramRow('Phosphorus (P)', _phosphorus, 'kg/ha'),
            _paramRow('Potassium (K)', _potassium, 'kg/ha'),
            _paramRow('Organic Carbon', _organicCarbon, '%'),
            _paramRow('Elec. Conductivity', _ec, 'dS/m'),

            const SizedBox(height: 16),

            // Toggle micronutrients
            GestureDetector(
              onTap: () => setState(() => _showMicro = !_showMicro),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brand50, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Micronutrients (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brand700)),
                  Icon(_showMicro ? Icons.expand_less : Icons.expand_more, color: AppColors.brand700),
                ]),
              ),
            ),

            if (_showMicro) ...[
              const SizedBox(height: 12),
              _paramRow('Zinc (Zn)', _zinc, 'ppm'),
              _paramRow('Iron (Fe)', _iron, 'ppm'),
              _paramRow('Manganese (Mn)', _manganese, 'ppm'),
              _paramRow('Copper (Cu)', _copper, 'ppm'),
              _paramRow('Boron (B)', _boron, 'ppm'),
              _paramRow('Sulphur (S)', _sulphur, 'ppm'),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Soil Test'),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700));

  Widget _paramRow(String label, TextEditingController ctrl, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray600))),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: '0', suffixText: unit,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        )),
      ]),
    );
  }
}
