import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final name = auth.displayName;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.brand600,
        onRefresh: () async {},
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
class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('☀️ Today\'s Weather', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray500)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('28°C', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                Text('Partly Cloudy', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
                const SizedBox(height: 2),
                Text('Hyderabad', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('💧 65%', style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                const SizedBox(height: 4),
                const Text('💨 12 km/h', style: TextStyle(fontSize: 13, color: AppColors.gray600)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Alerts Section ──
class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚠️ Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray500)),
        const SizedBox(height: 8),
        _alertCard('🔴', 'Pest Alert: Fall Armyworm', 'Active in your region. Check maize crops.', AppColors.red50, AppColors.red100),
        const SizedBox(height: 6),
        _alertCard('🟡', 'Weather Warning', 'Heavy rainfall expected in next 48 hours.', AppColors.amber50, AppColors.amber100),
      ],
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
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.gray600), maxLines: 2),
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
class _RecentDiagnosesList extends StatelessWidget {
  const _RecentDiagnosesList();

  @override
  Widget build(BuildContext context) {
    // Placeholder data – in production, fetch from Riverpod provider
    final items = [
      {'crop': 'Rice', 'disease': 'Bacterial Leaf Blight', 'severity': 'moderate', 'date': '28 Feb', 'img': 'https://images.unsplash.com/photo-1536304993881-460e47950734?w=200&q=80'},
      {'crop': 'Tomato', 'disease': 'Early Blight', 'severity': 'severe', 'date': '25 Feb', 'img': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=200&q=80'},
      {'crop': 'Cotton', 'disease': 'Healthy', 'severity': 'low', 'date': '22 Feb', 'img': 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=200&q=80'},
    ];

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
      children: items.map((d) => _DiagnosisCard(data: d)).toList(),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final Map<String, String> data;
  const _DiagnosisCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final severity = data['severity'] ?? 'low';
    final (bg, fg) = switch (severity) {
      'severe' => (AppColors.orange100, AppColors.orange700),
      'moderate' => (AppColors.yellow100, AppColors.yellow700),
      'critical' => (AppColors.red100, AppColors.red700),
      _ => (AppColors.green100, AppColors.green700),
    };

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
          child: CachedNetworkImage(
            imageUrl: data['img'] ?? '',
            width: 48, height: 48, fit: BoxFit.cover,
            placeholder: (_, __) => Container(width: 48, height: 48, color: AppColors.gray100,
                child: const Center(child: Text('🌾'))),
            errorWidget: (_, __, ___) => Container(width: 48, height: 48, color: AppColors.gray100,
                child: const Center(child: Text('🌾'))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['crop'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
          const SizedBox(height: 2),
          Text(data['disease'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(severity, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
          ),
          const SizedBox(height: 4),
          Text(data['date'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
      ]),
    );
  }
}

// ── Market Prices Widget ──
class _MarketPricesWidget extends StatelessWidget {
  const _MarketPricesWidget();

  @override
  Widget build(BuildContext context) {
    final prices = [
      {'commodity': 'Rice (Paddy)', 'market': 'Warangal', 'price': '2,450'},
      {'commodity': 'Cotton', 'market': 'Adilabad', 'price': '7,200'},
      {'commodity': 'Maize', 'market': 'Karimnagar', 'price': '1,980'},
    ];
    return Column(children: prices.map((p) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['commodity']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
          const SizedBox(height: 2),
          Text(p['market']!, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
        ]),
        Text('₹${p['price']}/q', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.brand700)),
      ]),
    )).toList());
  }
}

// ── Upcoming Tasks Widget ──
class _UpcomingTasksWidget extends StatelessWidget {
  const _UpcomingTasksWidget();

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {'icon': '💧', 'title': 'Irrigate Rice Field', 'date': '05 Mar'},
      {'icon': '🧪', 'title': 'Apply Urea Fertilizer', 'date': '08 Mar'},
      {'icon': '📋', 'title': 'Check for pests', 'date': '10 Mar'},
    ];
    return Column(children: tasks.map((t) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(children: [
        Text(t['icon']!, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
          const SizedBox(height: 2),
          Text(t['date']!, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ])),
      ]),
    )).toList());
  }
}
