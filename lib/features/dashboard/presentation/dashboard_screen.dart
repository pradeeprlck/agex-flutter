import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_service.dart';
import '../../auth/providers/auth_provider.dart';

// ── Providers ──
final weatherProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getCurrentWeather(params: {'lat': '17.385', 'lon': '78.4867'});
  return res.data as Map<String, dynamic>;
});

final alertsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getAlerts();
  return (res.data['alerts'] as List?) ?? [];
});

final recentDiagnosesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.listDiagnoses(page: 1, limit: 3);
  return (res.data['diagnoses'] as List?) ?? [];
});

final dashboardPricesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.listMandiPrices(page: 1, limit: 5);
  return (res.data['prices'] as List?) ?? [];
});

final upcomingTasksProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getUpcomingTasks();
  return (res.data['tasks'] as List?) ?? [];
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final name = auth.displayName;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.brand600,
        onRefresh: () async {
          ref.invalidate(weatherProvider);
          ref.invalidate(alertsProvider);
          ref.invalidate(recentDiagnosesProvider);
          ref.invalidate(dashboardPricesProvider);
          ref.invalidate(upcomingTasksProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Custom App Bar ──
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: AppColors.brand600,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF15803D), AppColors.brand600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('AgriExpert',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: Text(name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Welcome, $name 👋',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Quick Diagnosis CTA ──
                  _QuickDiagnosisCta(onTap: () => context.go('/diagnose')),
                  const SizedBox(height: 16),

                  // ── Weather Widget ──
                  const _WeatherCard(),
                  const SizedBox(height: 16),

                  // ── Alerts ──
                  const _AlertsSection(),
                  const SizedBox(height: 16),

                  // ── Feature Grid ──
                  _buildSectionLabel('🔧 Quick Actions'),
                  const SizedBox(height: 10),
                  _FeatureGrid(
                    onSoilTest: () => context.push('/soil-tests'),
                    onMandi: () => context.push('/mandi-prices'),
                    onCalendar: () => context.push('/crop-calendars'),
                    onCommunity: () => context.go('/community'),
                    onSchemes: () => context.push('/schemes'),
                  ),
                  const SizedBox(height: 20),

                  // ── Recent Diagnoses ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel('🔬 Recent Diagnoses'),
                      TextButton(
                        onPressed: () => context.go('/history'),
                        child: const Text('View All', style: TextStyle(color: AppColors.brand600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const _RecentDiagnosesList(),
                  const SizedBox(height: 20),

                  // ── Market Prices Widget ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel('🏪 Market Prices'),
                      TextButton(
                        onPressed: () => context.push('/mandi-prices'),
                        child: const Text('View All', style: TextStyle(color: AppColors.brand600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const _MarketPricesWidget(),
                  const SizedBox(height: 20),

                  // ── Upcoming Tasks ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel('📅 Upcoming Tasks'),
                      TextButton(
                        onPressed: () => context.push('/crop-calendars'),
                        child: const Text('View All', style: TextStyle(color: AppColors.brand600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const _UpcomingTasksWidget(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray500));
}

// ── Quick Diagnosis CTA ──
class _QuickDiagnosisCta extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickDiagnosisCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [AppColors.brand600, Color(0xFF15803D)],
          ),
          boxShadow: [
            BoxShadow(color: AppColors.brand600.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Center(child: Text('📷', style: TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Diagnosis', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Take a photo of your crop', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            const Text('›', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ── Weather Card ──
class _WeatherCard extends ConsumerWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: weather.when(
        loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Row(children: [
          const Text('☀️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(child: Text('Weather unavailable', style: TextStyle(fontSize: 13, color: AppColors.gray400))),
        ]),
        data: (w) {
          final temp = (w['temperature'] as num?)?.round() ?? '--';
          final desc = w['description'] as String? ?? '';
          final city = w['city'] as String? ?? '';
          final humidity = w['humidity'] ?? '--';
          final wind = (w['windSpeed'] as num?)?.toStringAsFixed(1) ?? '--';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('☀️ Today\'s Weather', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray500)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$temp°C', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                    Text(_capitalize(desc), style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
                    const SizedBox(height: 2),
                    Text(city, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('💧 $humidity%', style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
                    const SizedBox(height: 4),
                    Text('💨 $wind km/h', style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ── Alerts Section ──
class _AlertsSection extends ConsumerWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return alerts.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray500)),
            const SizedBox(height: 8),
            ...items.take(3).map((a) {
              final severity = (a['severity'] as String?) ?? 'medium';
              final (icon, bg, border) = switch (severity) {
                'critical' => ('🔴', AppColors.red50, AppColors.red100),
                'high' => ('🔴', AppColors.red50, AppColors.red100),
                'medium' => ('🟡', AppColors.amber50, AppColors.amber100),
                _ => ('🟢', AppColors.green50, AppColors.green100),
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _alertCard(icon, a['title'] ?? '', a['description'] ?? '', bg, border),
              );
            }),
          ],
        );
      },
    );
  }

  static Widget _alertCard(String icon, String title, String desc, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.gray600), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

// ── Feature Grid ──
class _FeatureGrid extends StatelessWidget {
  final VoidCallback onSoilTest, onMandi, onCalendar, onCommunity, onSchemes;
  const _FeatureGrid({required this.onSoilTest, required this.onMandi, required this.onCalendar, required this.onCommunity, required this.onSchemes});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: [
        _featureTile('🧪', 'Soil Test', onSoilTest),
        _featureTile('🏪', 'Mandi', onMandi),
        _featureTile('📅', 'Calendar', onCalendar),
        _featureTile('💬', 'Community', onCommunity),
        _featureTile('🏛️', 'Schemes', onSchemes),
      ],
    );
  }

  Widget _featureTile(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.gray700)),
        ]),
      ),
    );
  }
}

// ── Recent Diagnoses ──
class _RecentDiagnosesList extends ConsumerWidget {
  const _RecentDiagnosesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnoses = ref.watch(recentDiagnosesProvider);

    return diagnoses.when(
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Failed to load', style: TextStyle(color: AppColors.gray400, fontSize: 13))),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Column(children: [
              Text('🌿', style: TextStyle(fontSize: 40)),
              SizedBox(height: 8),
              Text('No recent diagnoses', style: TextStyle(color: AppColors.gray400, fontSize: 13)),
            ])),
          );
        }
        return Column(
          children: items.map<Widget>((d) => _DiagnosisCard(data: d as Map<String, dynamic>)).toList(),
        );
      },
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DiagnosisCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final severity = (data['severity'] as String?) ?? 'low';
    final (bg, fg) = switch (severity) {
      'severe' => (AppColors.orange100, AppColors.orange700),
      'moderate' => (AppColors.yellow100, AppColors.yellow700),
      'critical' => (AppColors.red100, AppColors.red700),
      _ => (AppColors.green100, AppColors.green700),
    };

    final crop = data['cropName'] as String? ?? '';
    final disease = data['disease'] as String? ?? (data['result']?['disease'] as String? ?? 'Unknown');
    final dateStr = data['createdAt'] as String?;
    final dateFormatted = dateStr != null
        ? DateFormat('dd MMM').format(DateTime.parse(dateStr))
        : '';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final baseUrl = AppConstants.prodBaseUrl.replaceAll('/api/v1', '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl.startsWith('http') ? imageUrl : '$baseUrl$imageUrl',
                  width: 48, height: 48, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(width: 48, height: 48, color: AppColors.gray100,
                      child: const Center(child: Text('🌾'))),
                  errorWidget: (_, __, ___) => Container(width: 48, height: 48, color: AppColors.gray100,
                      child: const Center(child: Text('🌾'))),
                )
              : Container(width: 48, height: 48, color: AppColors.gray100,
                  child: const Center(child: Text('🌾'))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(crop, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
          const SizedBox(height: 2),
          Text(disease, style: const TextStyle(fontSize: 11, color: AppColors.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(severity, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
          ),
          const SizedBox(height: 4),
          Text(dateFormatted, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
      ]),
    );
  }
}

// ── Market Prices Widget ──
class _MarketPricesWidget extends ConsumerWidget {
  const _MarketPricesWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(dashboardPricesProvider);

    return prices.when(
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: Text('Prices unavailable', style: TextStyle(color: AppColors.gray400, fontSize: 13))),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No price data available', style: TextStyle(color: AppColors.gray400, fontSize: 13))),
          );
        }
        return Column(children: items.take(5).map<Widget>((p) {
          final price = p as Map<String, dynamic>;
          final commodity = price['commodity'] as String? ?? '';
          final market = price['market'] as String? ?? '';
          final modalPrice = price['modalPrice'] as num? ?? 0;
          final unit = price['unit'] as String? ?? 'Quintal';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(commodity, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
                const SizedBox(height: 2),
                Text(market, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
              ])),
              Text('₹${NumberFormat('#,##0').format(modalPrice)}/${unit[0].toLowerCase()}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.brand700)),
            ]),
          );
        }).toList());
      },
    );
  }
}

// ── Upcoming Tasks Widget ──
class _UpcomingTasksWidget extends ConsumerWidget {
  const _UpcomingTasksWidget();

  static const _categoryIcons = {
    'irrigation': '💧', 'fertilizer': '🧪', 'pesticide': '🧴',
    'inspection': '📋', 'harvest': '🌾', 'sowing': '🌱', 'pruning': '✂️',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(upcomingTasksProvider);

    return tasks.when(
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No upcoming tasks', style: TextStyle(color: AppColors.gray400, fontSize: 13))),
          );
        }
        return Column(children: items.take(5).map<Widget>((t) {
          final task = t as Map<String, dynamic>;
          final title = task['title'] as String? ?? '';
          final crop = task['cropName'] as String? ?? '';
          final category = task['category'] as String? ?? '';
          final icon = _categoryIcons[category] ?? '📋';
          final dateStr = task['scheduledDate'] as String?;
          final dateFormatted = dateStr != null
              ? DateFormat('dd MMM').format(DateTime.parse(dateStr))
              : '';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: Row(children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
                const SizedBox(height: 2),
                Text(crop.isNotEmpty ? '$crop · $dateFormatted' : dateFormatted,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
              ])),
            ]),
          );
        }).toList());
      },
    );
  }
}
