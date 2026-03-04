import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MandiPricesScreen extends StatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  bool _showMyCrops = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final _myCrops = ['Rice', 'Cotton'];

  final List<Map<String, dynamic>> _prices = [
    {'commodity': 'Rice (Paddy)', 'market': 'Warangal', 'price': 2450, 'change': 2.5, 'unit': 'quintal', 'date': '28 Feb'},
    {'commodity': 'Cotton', 'market': 'Adilabad', 'price': 7200, 'change': -1.8, 'unit': 'quintal', 'date': '28 Feb'},
    {'commodity': 'Maize', 'market': 'Karimnagar', 'price': 1980, 'change': 3.2, 'unit': 'quintal', 'date': '28 Feb'},
    {'commodity': 'Wheat', 'market': 'Nizamabad', 'price': 2850, 'change': 0.5, 'unit': 'quintal', 'date': '27 Feb'},
    {'commodity': 'Groundnut', 'market': 'Kurnool', 'price': 5600, 'change': -0.3, 'unit': 'quintal', 'date': '27 Feb'},
    {'commodity': 'Sunflower', 'market': 'Raichur', 'price': 6100, 'change': 1.1, 'unit': 'quintal', 'date': '27 Feb'},
    {'commodity': 'Soybean', 'market': 'Latur', 'price': 4500, 'change': -2.1, 'unit': 'quintal', 'date': '26 Feb'},
    {'commodity': 'Turmeric', 'market': 'Nizamabad', 'price': 8900, 'change': 4.5, 'unit': 'quintal', 'date': '26 Feb'},
    {'commodity': 'Red Chilli', 'market': 'Guntur', 'price': 12500, 'change': 0.0, 'unit': 'quintal', 'date': '26 Feb'},
    {'commodity': 'Tomato', 'market': 'Madanapalle', 'price': 1800, 'change': -5.2, 'unit': 'quintal', 'date': '25 Feb'},
  ];

  List<Map<String, dynamic>> get _filtered {
    var items = _prices;
    if (_showMyCrops) {
      items = items.where((p) =>
          _myCrops.any((c) => (p['commodity'] as String).toLowerCase().contains(c.toLowerCase()))).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((p) =>
          (p['commodity'] as String).toLowerCase().contains(q) ||
          (p['market'] as String).toLowerCase().contains(q)).toList();
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
      appBar: AppBar(title: const Text('Mandi Prices')),
      body: Column(children: [
        // Toggle bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showMyCrops = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_showMyCrops ? AppColors.brand600 : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    border: Border.all(color: AppColors.brand600),
                  ),
                  child: Center(child: Text('All Crops',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: !_showMyCrops ? Colors.white : AppColors.brand600))),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showMyCrops = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _showMyCrops ? AppColors.brand600 : Colors.white,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                    border: Border.all(color: AppColors.brand600),
                  ),
                  child: Center(child: Text('My Crops',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: _showMyCrops ? Colors.white : AppColors.brand600))),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search commodity or market...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18),
                      onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(alignment: Alignment.centerLeft,
              child: Text('${items.length} commodities', style: const TextStyle(fontSize: 12, color: AppColors.gray400))),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: items.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📊', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('No prices found', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _PriceCard(data: items[i]),
                ),
        ),
      ]),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PriceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final change = data['change'] as double;
    final isUp = change >= 0;
    final changeColor = change > 0 ? AppColors.green600 : change < 0 ? AppColors.red500 : AppColors.gray500;
    final changeIcon = change > 0 ? '▲' : change < 0 ? '▼' : '—';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: AppColors.brand50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('🌾', style: TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['commodity'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 2),
          Row(children: [
            Text(data['market'], style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
            const Text(' · ', style: TextStyle(color: AppColors.gray300)),
            Text(data['date'], style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${data['price']}/${data['unit']}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.brand700)),
          const SizedBox(height: 2),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(changeIcon, style: TextStyle(fontSize: 10, color: changeColor)),
            const SizedBox(width: 2),
            Text('${change.abs()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: changeColor)),
          ]),
        ]),
      ]),
    );
  }
}
