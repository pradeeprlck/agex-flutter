import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';

// ── Providers ──
final mandiPricesProvider = FutureProvider.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.listMandiPrices(
    commodity: params['commodity'],
    state: params['state'],
    page: int.tryParse(params['page'] ?? '1') ?? 1,
  );
  return res.data as Map<String, dynamic>;
});

final myCropPricesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getMyCropPrices();
  return res.data as Map<String, dynamic>;
});

final pricePredictionProvider = FutureProvider.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getPricePrediction(
    commodity: params['commodity']!,
    market: params['market'],
    state: params['state'],
  );
  return res.data as Map<String, dynamic>;
});

final commoditiesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getMandiCommodities();
  final list = (res.data['commodities'] as List).cast<String>();
  return list;
});

class MandiPricesScreen extends ConsumerStatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  ConsumerState<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends ConsumerState<MandiPricesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showMyCrops = false;

  // Prediction state
  String? _selectedCommodity;
  bool _predictionRequested = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brand600,
          labelColor: AppColors.brand700,
          unselectedLabelColor: AppColors.gray500,
          tabs: const [
            Tab(icon: Icon(Icons.price_change_outlined, size: 20), text: 'Prices'),
            Tab(icon: Icon(Icons.auto_graph_rounded, size: 20), text: 'AI Prediction'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PricesTab(
            showMyCrops: _showMyCrops,
            searchQuery: _searchQuery,
            searchController: _searchController,
            onToggleMyCrops: (v) => setState(() => _showMyCrops = v),
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onPredictTap: (commodity) {
              setState(() {
                _selectedCommodity = commodity;
                _predictionRequested = true;
              });
              _tabController.animateTo(1);
            },
          ),
          _PredictionTab(
            selectedCommodity: _selectedCommodity,
            predictionRequested: _predictionRequested,
            onCommoditySelected: (c) => setState(() {
              _selectedCommodity = c;
              _predictionRequested = true;
            }),
          ),
        ],
      ),
    );
  }
}

// ── Prices Tab ──
class _PricesTab extends ConsumerWidget {
  final bool showMyCrops;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<bool> onToggleMyCrops;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onPredictTap;

  const _PricesTab({
    required this.showMyCrops,
    required this.searchQuery,
    required this.searchController,
    required this.onToggleMyCrops,
    required this.onSearchChanged,
    required this.onPredictTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = <String, String?>{
      'page': '1',
      if (searchQuery.isNotEmpty) 'commodity': searchQuery,
    };

    final pricesAsync = showMyCrops
        ? ref.watch(myCropPricesProvider)
        : ref.watch(mandiPricesProvider(params));

    return Column(children: [
      // Toggle bar
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(children: [
          _ToggleButton(
            label: 'All Crops',
            isActive: !showMyCrops,
            isLeft: true,
            onTap: () => onToggleMyCrops(false),
          ),
          _ToggleButton(
            label: 'My Crops',
            isActive: showMyCrops,
            isLeft: false,
            onTap: () => onToggleMyCrops(true),
          ),
        ]),
      ),
      const SizedBox(height: 8),

      // Search
      if (!showMyCrops)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search commodity or market...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      })
                  : null,
            ),
          ),
        ),
      const SizedBox(height: 8),

      // List
      Expanded(
        child: pricesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand600)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.red500))),
          data: (data) {
            final prices = (data['prices'] as List?) ?? [];
            if (prices.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('📊', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text('No prices found', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
              ]));
            }
            return RefreshIndicator(
              color: AppColors.brand600,
              onRefresh: () async {
                if (showMyCrops) {
                  ref.invalidate(myCropPricesProvider);
                } else {
                  ref.invalidate(mandiPricesProvider);
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: prices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = prices[i] as Map<String, dynamic>;
                  return _PriceCard(
                    data: p,
                    onPredictTap: () => onPredictTap(p['commodity']?.toString() ?? ''),
                  );
                },
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ── Prediction Tab ──
class _PredictionTab extends ConsumerWidget {
  final String? selectedCommodity;
  final bool predictionRequested;
  final ValueChanged<String> onCommoditySelected;

  const _PredictionTab({
    required this.selectedCommodity,
    required this.predictionRequested,
    required this.onCommoditySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commoditiesAsync = ref.watch(commoditiesProvider);

    if (!predictionRequested || selectedCommodity == null || selectedCommodity!.isEmpty) {
      return _CommodityPicker(
        commoditiesAsync: commoditiesAsync,
        onSelected: onCommoditySelected,
      );
    }

    final predAsync = ref.watch(pricePredictionProvider({'commodity': selectedCommodity}));

    return predAsync.when(
      loading: () => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: AppColors.brand600),
          const SizedBox(height: 16),
          Text('AI is analyzing $selectedCommodity prices...',
              style: const TextStyle(color: AppColors.gray500, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('This may take a few seconds',
              style: TextStyle(color: AppColors.gray400, fontSize: 11)),
        ]),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.amber500),
            const SizedBox(height: 12),
            Text('Could not predict $selectedCommodity prices',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(e.toString(), textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.invalidate(pricePredictionProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => onCommoditySelected(''),
              child: const Text('Pick different commodity'),
            ),
          ]),
        ),
      ),
      data: (data) {
        final pred = (data['prediction'] as Map<String, dynamic>?) ?? {};
        final cached = data['cached'] == true;
        return _PredictionResultView(
          prediction: pred,
          cached: cached,
          commodity: selectedCommodity!,
          onChangeCommodity: () => onCommoditySelected(''),
        );
      },
    );
  }
}

// ── Commodity Picker for Prediction ──
class _CommodityPicker extends StatelessWidget {
  final AsyncValue<List<String>> commoditiesAsync;
  final ValueChanged<String> onSelected;

  const _CommodityPicker({required this.commoditiesAsync, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return commoditiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand600)),
      error: (e, _) => Center(child: Text('Error loading commodities: $e')),
      data: (commodities) {
        if (commodities.isEmpty) {
          return const Center(child: Text('No commodities available'));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF15803D), AppColors.brand600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Price Predictor',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Select a commodity to get AI-powered price forecasts',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    ],
                  )),
                ]),
              ),
              const SizedBox(height: 16),
              const Text('Select Commodity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: commodities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    return InkWell(
                      onTap: () => onSelected(commodities[i]),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gray100),
                        ),
                        child: Row(children: [
                          const Text('🌾', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(commodities[i],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                          const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Prediction Result View ──
class _PredictionResultView extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final bool cached;
  final String commodity;
  final VoidCallback onChangeCommodity;

  const _PredictionResultView({
    required this.prediction,
    required this.cached,
    required this.commodity,
    required this.onChangeCommodity,
  });

  @override
  Widget build(BuildContext context) {
    final trend = prediction['trend']?.toString() ?? 'stable';
    final trendStrength = prediction['trendStrength']?.toString() ?? 'moderate';
    final currentAvg = prediction['currentAvgPrice'];
    final sevenDay = prediction['sevenDayPrediction'] as Map<String, dynamic>? ?? {};
    final thirtyDay = prediction['thirtyDayOutlook'] as Map<String, dynamic>? ?? {};
    final insight = prediction['insight']?.toString() ?? '';
    final advice = prediction['farmerAdvice']?.toString() ?? '';
    final factors = (prediction['factors'] as List?)?.cast<String>() ?? [];

    final trendIcon = trend == 'up' ? Icons.trending_up : trend == 'down' ? Icons.trending_down : Icons.trending_flat;
    final trendColor = trend == 'up' ? AppColors.green600 : trend == 'down' ? AppColors.red500 : AppColors.amber500;
    final trendLabel = '${trend[0].toUpperCase()}${trend.substring(1)} ($trendStrength)';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Text(commodity,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray800))),
          TextButton.icon(
            onPressed: onChangeCommodity,
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('Change', style: TextStyle(fontSize: 12)),
          ),
        ]),
        if (cached) ...[
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.cached, size: 12, color: AppColors.gray400),
            const SizedBox(width: 4),
            Text('Cached prediction', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
          ]),
        ],
        const SizedBox(height: 12),

        // Trend Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [trendColor.withOpacity(0.08), trendColor.withOpacity(0.03)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: trendColor.withOpacity(0.2)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: trendColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(trendIcon, color: trendColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price Trend', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
              const SizedBox(height: 2),
              Text(trendLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: trendColor)),
              if (currentAvg != null) ...[
                const SizedBox(height: 2),
                Text('Current avg: ₹${_formatNum(currentAvg)}/qtl',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
              ],
            ])),
          ]),
        ),
        const SizedBox(height: 14),

        // 7-Day Prediction
        if (sevenDay.isNotEmpty) ...[
          _ForecastCard(
            title: '7-Day Forecast',
            icon: Icons.calendar_today,
            data: sevenDay,
          ),
          const SizedBox(height: 10),
        ],

        // 30-Day Outlook
        if (thirtyDay.isNotEmpty) ...[
          _ForecastCard(
            title: '30-Day Outlook',
            icon: Icons.date_range,
            data: thirtyDay,
          ),
          const SizedBox(height: 14),
        ],

        // AI Insight
        if (insight.isNotEmpty) ...[
          _InfoPanel(
            icon: Icons.lightbulb_outline,
            title: 'AI Insight',
            body: insight,
            accentColor: AppColors.blue500,
          ),
          const SizedBox(height: 10),
        ],

        // Farmer Advice
        if (advice.isNotEmpty) ...[
          _InfoPanel(
            icon: Icons.agriculture,
            title: 'Advice for Farmers',
            body: advice,
            accentColor: AppColors.brand600,
          ),
          const SizedBox(height: 10),
        ],

        // Factors
        if (factors.isNotEmpty) ...[
          const Text('Key Factors', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 8),
          ...factors.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.circle, size: 6, color: AppColors.brand500),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: AppColors.gray600))),
            ]),
          )),
        ],

        const SizedBox(height: 16),
        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.amber50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.amber100),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.amber600),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'AI predictions are estimates based on historical data. Actual prices may vary due to market conditions.',
              style: TextStyle(fontSize: 11, color: AppColors.amber600),
            )),
          ]),
        ),
      ]),
    );
  }

  static String _formatNum(dynamic n) {
    if (n == null) return '-';
    final d = n is num ? n : num.tryParse(n.toString()) ?? 0;
    return d.toStringAsFixed(0);
  }
}

// ── Forecast Card ──
class _ForecastCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic> data;
  const _ForecastCard({required this.title, required this.icon, required this.data});

  @override
  Widget build(BuildContext context) {
    final low = data['low'] ?? data['min'] ?? data['minPrice'];
    final high = data['high'] ?? data['max'] ?? data['maxPrice'];
    final avg = data['average'] ?? data['avgPrice'] ?? data['expected'];
    final conf = data['confidence']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.brand600),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const Spacer(),
          if (conf.isNotEmpty) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brand50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$conf confidence',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.brand700)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          if (low != null) _PriceChip(label: 'Low', value: '₹${_fmt(low)}', color: AppColors.red500),
          if (avg != null) ...[const SizedBox(width: 10), _PriceChip(label: 'Expected', value: '₹${_fmt(avg)}', color: AppColors.brand600)],
          if (high != null) ...[const SizedBox(width: 10), _PriceChip(label: 'High', value: '₹${_fmt(high)}', color: AppColors.blue500)],
        ]),
      ]),
    );
  }

  static String _fmt(dynamic n) => n == null ? '-' : (n is num ? n : num.tryParse(n.toString()) ?? 0).toStringAsFixed(0);
}

class _PriceChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PriceChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.gray500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ── Info Panel ──
class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color accentColor;
  const _InfoPanel({required this.icon, required this.title, required this.body, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accentColor)),
        ]),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 12, color: AppColors.gray700, height: 1.5)),
      ]),
    );
  }
}

// ── Price Card ──
class _PriceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onPredictTap;
  const _PriceCard({required this.data, required this.onPredictTap});

  @override
  Widget build(BuildContext context) {
    final commodity = data['commodity']?.toString() ?? '';
    final market = data['market']?.toString() ?? '';
    final modal = data['modalPrice'] ?? data['price'];
    final maxP = data['maxPrice'];
    final minP = data['minPrice'];
    final date = data['arrivalDate']?.toString().substring(0, 10) ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.brand50, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('🌾', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
            const SizedBox(height: 2),
            Text('$market • $date', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (modal != null)
              Text('₹${_fmt(modal)}/qtl',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.brand700)),
            if (minP != null && maxP != null)
              Text('₹${_fmt(minP)} – ₹${_fmt(maxP)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
          ]),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 30,
          child: OutlinedButton.icon(
            onPressed: onPredictTap,
            icon: const Icon(Icons.auto_graph, size: 14),
            label: const Text('Predict Price', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brand600,
              side: const BorderSide(color: AppColors.brand200),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]),
    );
  }

  static String _fmt(dynamic n) => n == null ? '-' : (n is num ? n : num.tryParse(n.toString()) ?? 0).toStringAsFixed(0);
}

// ── Toggle Button ──
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLeft;
  final VoidCallback onTap;
  const _ToggleButton({required this.label, required this.isActive, required this.isLeft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.brand600 : Colors.white,
            borderRadius: isLeft
                ? const BorderRadius.horizontal(left: Radius.circular(10))
                : const BorderRadius.horizontal(right: Radius.circular(10)),
            border: Border.all(color: AppColors.brand600),
          ),
          child: Center(child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.brand600))),
        ),
      ),
    );
  }
}
