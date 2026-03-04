import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';

// ── Providers ──
final schemesProvider = FutureProvider.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.listSchemes(
    type: params['type'],
    state: params['state'],
    search: params['search'],
    page: int.tryParse(params['page'] ?? '1') ?? 1,
  );
  return res.data as Map<String, dynamic>;
});

final mySchemesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getMySchemes();
  return res.data as Map<String, dynamic>;
});

final schemeTypesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.getSchemeTypes();
  return (res.data['types'] as List).cast<String>();
});

class SchemesScreen extends ConsumerStatefulWidget {
  const SchemesScreen({super.key});

  @override
  ConsumerState<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends ConsumerState<SchemesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedType;
  final _searchController = TextEditingController();

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
        title: const Text('Government Schemes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brand600,
          labelColor: AppColors.brand700,
          unselectedLabelColor: AppColors.gray500,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt, size: 20), text: 'All Schemes'),
            Tab(icon: Icon(Icons.person_search, size: 20), text: 'For Me'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllSchemesTab(
            searchQuery: _searchQuery,
            selectedType: _selectedType,
            searchController: _searchController,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onTypeChanged: (v) => setState(() => _selectedType = v),
          ),
          const _MyRecommendationsTab(),
        ],
      ),
    );
  }
}

// ── All Schemes Tab ──
class _AllSchemesTab extends ConsumerWidget {
  final String searchQuery;
  final String? selectedType;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;

  const _AllSchemesTab({
    required this.searchQuery,
    required this.selectedType,
    required this.searchController,
    required this.onSearchChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = <String, String?>{
      'page': '1',
      if (searchQuery.isNotEmpty) 'search': searchQuery,
      if (selectedType != null) 'type': selectedType,
    };

    final schemesAsync = ref.watch(schemesProvider(params));
    final typesAsync = ref.watch(schemeTypesProvider);

    return Column(children: [
      // Search
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search schemes...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 18),
                    onPressed: () { searchController.clear(); onSearchChanged(''); })
                : null,
          ),
        ),
      ),

      // Type chips
      typesAsync.when(
        loading: () => const SizedBox(height: 8),
        error: (_, __) => const SizedBox(height: 8),
        data: (types) => SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              _FilterChip(
                label: 'All',
                isActive: selectedType == null,
                onTap: () => onTypeChanged(null),
              ),
              ...types.map((t) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _FilterChip(
                  label: _typeLabel(t),
                  isActive: selectedType == t,
                  onTap: () => onTypeChanged(t),
                ),
              )),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),

      // List
      Expanded(
        child: schemesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand600)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.red500))),
          data: (data) {
            final schemes = (data['schemes'] as List?) ?? [];
            if (schemes.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.policy_outlined, size: 48, color: AppColors.gray300),
                const SizedBox(height: 12),
                const Text('No schemes found', style: TextStyle(fontSize: 14, color: AppColors.gray400)),
              ]));
            }
            return RefreshIndicator(
              color: AppColors.brand600,
              onRefresh: () async => ref.invalidate(schemesProvider),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: schemes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SchemeCard(scheme: schemes[i] as Map<String, dynamic>),
              ),
            );
          },
        ),
      ),
    ]);
  }

  static String _typeLabel(String type) {
    const labels = {
      'subsidy': 'Subsidy',
      'insurance': 'Insurance',
      'credit': 'Credit/Loan',
      'market': 'Market',
      'input': 'Inputs',
      'training': 'Training',
      'infrastructure': 'Infra',
      'other': 'Other',
    };
    return labels[type] ?? type;
  }
}

// ── My Recommendations Tab ──
class _MyRecommendationsTab extends ConsumerWidget {
  const _MyRecommendationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(mySchemesProvider);

    return matchesAsync.when(
      loading: () => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppColors.brand600),
        const SizedBox(height: 16),
        const Text('AI is matching schemes to your profile...',
            style: TextStyle(color: AppColors.gray500, fontSize: 13)),
        const SizedBox(height: 4),
        const Text('This may take a few seconds',
            style: TextStyle(color: AppColors.gray400, fontSize: 11)),
      ])),
      error: (e, _) => Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.amber500),
          const SizedBox(height: 12),
          const Text('Could not find matching schemes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(e.toString(), textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ref.invalidate(mySchemesProvider),
            icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry'),
          ),
        ]),
      )),
      data: (data) {
        final matches = (data['matches'] as List?) ?? [];
        if (matches.isEmpty) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.person_pin_circle_outlined, size: 48, color: AppColors.gray300),
              const SizedBox(height: 16),
              Text(data['message']?.toString() ?? 'Complete your farm profile to get personalized recommendations.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.gray500)),
            ]),
          ));
        }
        return RefreshIndicator(
          color: AppColors.brand600,
          onRefresh: () async => ref.invalidate(mySchemesProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              if (i == 0) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF15803D), AppColors.brand600]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('AI-Matched Schemes',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${matches.length} schemes matched to your profile',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    ])),
                  ]),
                );
              }
              final match = matches[i - 1] as Map<String, dynamic>;
              return _MatchedSchemeCard(match: match);
            },
          ),
        );
      },
    );
  }
}

// ── Scheme Card ──
class _SchemeCard extends StatelessWidget {
  final Map<String, dynamic> scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final name = scheme['name']?.toString() ?? '';
    final desc = scheme['description']?.toString() ?? '';
    final type = scheme['type']?.toString() ?? '';
    final ministry = scheme['ministry']?.toString() ?? '';
    final url = scheme['officialUrl']?.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _typeColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_typeLabel(type),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _typeColor(type))),
          ),
          const Spacer(),
          if (url != null && url.isNotEmpty)
            GestureDetector(
              onTap: () => _openUrl(url),
              child: const Icon(Icons.open_in_new, size: 16, color: AppColors.blue500),
            ),
        ]),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
        const SizedBox(height: 4),
        Text(desc, maxLines: 3, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500, height: 1.4)),
        if (ministry.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(ministry, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
        ],
        // Expandable detail
        const SizedBox(height: 8),
        _SchemeDetailExpander(scheme: scheme),
      ]),
    );
  }

  static void _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  static Color _typeColor(String type) {
    const colors = {
      'subsidy': AppColors.green600,
      'insurance': AppColors.blue500,
      'credit': AppColors.amber500,
      'market': AppColors.brand600,
      'input': AppColors.green700,
      'training': Color(0xFF7C3AED),
      'infrastructure': AppColors.gray600,
    };
    return colors[type] ?? AppColors.gray500;
  }

  static String _typeLabel(String type) {
    const labels = {
      'subsidy': 'SUBSIDY',
      'insurance': 'INSURANCE',
      'credit': 'CREDIT/LOAN',
      'market': 'MARKET',
      'input': 'INPUTS',
      'training': 'TRAINING',
      'infrastructure': 'INFRASTRUCTURE',
      'other': 'OTHER',
    };
    return labels[type] ?? type.toUpperCase();
  }
}

// ── Scheme Detail Expander ──
class _SchemeDetailExpander extends StatefulWidget {
  final Map<String, dynamic> scheme;
  const _SchemeDetailExpander({required this.scheme});

  @override
  State<_SchemeDetailExpander> createState() => _SchemeDetailExpanderState();
}

class _SchemeDetailExpanderState extends State<_SchemeDetailExpander> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final benefits = widget.scheme['benefits']?.toString() ?? '';
    final process = widget.scheme['applicationProcess']?.toString() ?? '';
    final docs = (widget.scheme['requiredDocuments'] as List?)?.cast<String>() ?? [];
    final portal = widget.scheme['portalName']?.toString() ?? '';

    if (benefits.isEmpty && process.isEmpty && docs.isEmpty) return const SizedBox();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(children: [
          Text(_expanded ? 'Hide details' : 'View details',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.brand600)),
          Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16, color: AppColors.brand600),
        ]),
      ),
      if (_expanded) ...[
        const SizedBox(height: 8),
        if (benefits.isNotEmpty) ...[
          const Text('Benefits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 2),
          Text(benefits, style: const TextStyle(fontSize: 11, color: AppColors.gray600, height: 1.4)),
          const SizedBox(height: 8),
        ],
        if (process.isNotEmpty) ...[
          const Text('How to Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 2),
          Text(process, style: const TextStyle(fontSize: 11, color: AppColors.gray600, height: 1.4)),
          const SizedBox(height: 8),
        ],
        if (docs.isNotEmpty) ...[
          const Text('Required Documents', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700)),
          const SizedBox(height: 4),
          ...docs.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.check_circle, size: 10, color: AppColors.brand500)),
              const SizedBox(width: 6),
              Expanded(child: Text(d, style: const TextStyle(fontSize: 11, color: AppColors.gray600))),
            ]),
          )),
        ],
        if (portal.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.language, size: 12, color: AppColors.blue500),
            const SizedBox(width: 4),
            Text(portal, style: const TextStyle(fontSize: 11, color: AppColors.blue500)),
          ]),
        ],
      ],
    ]);
  }
}

// ── Matched Scheme Card (with AI enrichment) ──
class _MatchedSchemeCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _MatchedSchemeCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = (match['scheme'] as Map<String, dynamic>?) ?? {};
    final score = (match['eligibilityScore'] as num?)?.toDouble() ?? 0;
    final reason = match['reason']?.toString() ?? '';
    final howToApply = match['howToApply']?.toString() ?? '';
    final name = scheme['name']?.toString() ?? '';
    final type = scheme['type']?.toString() ?? '';
    final url = scheme['officialUrl']?.toString();

    final scorePercent = (score * 100).round();
    final scoreColor = score >= 0.8 ? AppColors.green600 : score >= 0.6 ? AppColors.amber500 : AppColors.gray500;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$scorePercent% Match',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scoreColor)),
          ),
          const SizedBox(width: 8),
          if (type.isNotEmpty) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(type.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppColors.gray500)),
          ),
          const Spacer(),
          if (url != null && url.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(url);
                if (uri != null) try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (_) {}
              },
              child: const Icon(Icons.open_in_new, size: 16, color: AppColors.blue500),
            ),
        ]),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray800)),
        if (reason.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_outline, size: 14, color: AppColors.green600),
              const SizedBox(width: 6),
              Expanded(child: Text(reason, style: const TextStyle(fontSize: 11, color: AppColors.green700, height: 1.4))),
            ]),
          ),
        ],
        if (howToApply.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.directions_walk, size: 14, color: AppColors.blue600),
              const SizedBox(width: 6),
              Expanded(child: Text(howToApply, style: const TextStyle(fontSize: 11, color: AppColors.gray700, height: 1.4))),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ── Filter Chip ──
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brand600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.brand600 : AppColors.gray200),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : AppColors.gray600,
        )),
      ),
    );
  }
}
