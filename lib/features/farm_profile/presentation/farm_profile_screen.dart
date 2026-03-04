import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class FarmProfileScreen extends ConsumerStatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  ConsumerState<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends ConsumerState<FarmProfileScreen> {
  final _farmNameController = TextEditingController(text: 'Green Valley Farm');
  final _areaController = TextEditingController(text: '12');
  String _soilType = 'Clay Loam';
  String _irrigation = 'Drip';
  String _state = 'Telangana';
  String _district = 'Warangal';
  bool _editing = false;
  bool _saving = false;
  final List<String> _crops = ['Rice', 'Cotton', 'Maize'];
  String? _addCrop;

  @override
  void dispose() {
    _farmNameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() { _saving = false; _editing = false; });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm profile updated!'), backgroundColor: AppColors.green500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Profile'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _editing = !_editing),
            child: Text(_editing ? 'Cancel' : 'Edit',
                style: const TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600&q=80'),
                fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken)),
            ),
            child: Column(children: [
              const Text('🌾', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(_farmNameController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              Text('$_district, $_state', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text('${_areaController.text} acres', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
            ]),
          ),
          const SizedBox(height: 24),

          // Farm Details
          _sectionTitle('Farm Details'),
          const SizedBox(height: 10),
          _field('Farm Name', _farmNameController, _editing),
          _field('Area (acres)', _areaController, _editing, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _dropdownField('Soil Type', _soilType, AppConstants.soilTypes, _editing, (v) => setState(() => _soilType = v)),
          _dropdownField('Irrigation', _irrigation, AppConstants.irrigationTypes, _editing, (v) => setState(() => _irrigation = v)),
          const SizedBox(height: 20),

          // Location
          _sectionTitle('Location'),
          const SizedBox(height: 10),
          _dropdownField('State', _state, ['Telangana', 'Andhra Pradesh', 'Karnataka', 'Maharashtra', 'Tamil Nadu'], _editing, (v) => setState(() => _state = v)),
          _dropdownField('District', _district, ['Warangal', 'Karimnagar', 'Nizamabad', 'Adilabad', 'Khammam'], _editing, (v) => setState(() => _district = v)),
          const SizedBox(height: 20),

          // Crops
          _sectionTitle('Crops Grown'),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ..._crops.map((c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 12, color: AppColors.brand700)),
              backgroundColor: AppColors.brand50,
              side: const BorderSide(color: AppColors.brand100),
              deleteIcon: _editing ? const Icon(Icons.close, size: 16, color: AppColors.brand600) : null,
              onDeleted: _editing ? () => setState(() => _crops.remove(c)) : null,
            )),
            if (_editing)
              ActionChip(
                label: const Text('+ Add', style: TextStyle(fontSize: 12, color: AppColors.brand600, fontWeight: FontWeight.w600)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.brand200, style: BorderStyle.solid),
                onPressed: () => _showAddCropDialog(),
              ),
          ]),
          const SizedBox(height: 24),

          if (_editing)
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  void _showAddCropDialog() {
    final available = AppConstants.cropOptions.where((c) => !_crops.contains(c)).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Crop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: available.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(available[i], style: const TextStyle(fontSize: 14)),
                onTap: () {
                  setState(() => _crops.add(available[i]));
                  Navigator.pop(ctx);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700));

  Widget _field(String label, TextEditingController ctrl, bool enabled, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl, enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdownField(String label, String value, List<String> items, bool enabled, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: enabled ? (v) { if (v != null) onChanged(v); } : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
