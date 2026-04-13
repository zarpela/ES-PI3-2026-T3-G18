
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Modular.get<HomeController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Color bg = const Color(0xFFFAF8F3);
  final Color surface = const Color(0xFFFDF9F0);
  final Color surfaceAlt = const Color(0xFFF5F0E6);
  final Color border = const Color(0xFFD9D0BC);
  final Color text = const Color(0xFF1C1A14);
  final Color textMuted = const Color(0xFF6B6350);
  final Color textFaint = const Color(0xFFB0A890);
  final Color primary = const Color(0xFFB45309);
  final Color primaryLight = const Color(0xFFFEF3C7);
  final Color success = const Color(0xFF166534);
  final Color successBg = const Color(0xFFDCFCE7);

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.load());
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startups = controller.startups;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bg,
      drawer: isMobile ? Drawer(child: _buildSidebar()) : null,
      body: Row(
        children: [
          if (!isMobile) SizedBox(width: 250, child: _buildSidebar()),
          Expanded(
            child: Column(
              children: [
                _buildTopbar(isMobile),
                Expanded(
                  child: RefreshIndicator(
                    color: primary,
                    onRefresh: controller.refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPageHeader(),
                            const SizedBox(height: 24),
                            _buildStats(),
                            const SizedBox(height: 24),
                            _buildFilters(),
                            const SizedBox(height: 20),
                            if (controller.isLoading)
                              _buildSkeletonGrid(isMobile)
                            else if (controller.errorMessage != null)
                              _buildErrorState()
                            else if (startups.isEmpty)
                              _buildEmptyState()
                            else
                              _buildCatalogGrid(startups, isMobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.candlestick_chart, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MesclaInvest', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
                      Text('Plataforma de investimentos', style: TextStyle(fontSize: 12, color: textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _sectionLabel('Principal'),
                  _navItem(Icons.dashboard_outlined, 'Visão Geral'),
                  _navItem(Icons.search_rounded, 'Catálogo', active: true, badge: '${controller.totalStartups}'),
                  _navItem(Icons.show_chart_rounded, 'Meu Portfólio'),
                  _navItem(Icons.attach_money_rounded, 'Investimentos'),
                  _sectionLabel('Análise'),
                  _navItem(Icons.analytics_outlined, 'Mercado'),
                  _navItem(Icons.description_outlined, 'Relatórios'),
                  _sectionLabel('Configurações'),
                  _navItem(Icons.settings_outlined, 'Configurações'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(999)),
                    child: Center(child: Text('IN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Investidor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text)),
                        Text('Conta Premium', style: TextStyle(fontSize: 12, color: textMuted)),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: textFaint),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textFaint)),
    );
  }

  Widget _navItem(IconData icon, String label, {bool active = false, String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: active ? primaryLight : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 20, color: active ? primary : textMuted),
        title: Text(label, style: TextStyle(fontSize: 14, color: active ? primary : textMuted, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFDE68A), borderRadius: BorderRadius.circular(999)),
                child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primary)),
              )
            : null,
      ),
    );
  }

  Widget _buildTopbar(bool isMobile) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: surface, border: Border(bottom: BorderSide(color: border))),
      child: Row(
        children: [
          if (isMobile)
            IconButton(onPressed: () => scaffoldKey.currentState?.openDrawer(), icon: const Icon(Icons.menu)),
          Text('MesclaInvest', style: TextStyle(fontSize: 14, color: textMuted)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('/', style: TextStyle(fontSize: 14, color: textFaint)),
          ),
          Text('Catálogo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text)),
          const Spacer(),
          SizedBox(
            width: isMobile ? 160 : 240,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Buscar startup...',
                prefixIcon: Icon(Icons.search, size: 18, color: textFaint),
                hintStyle: TextStyle(fontSize: 14, color: textFaint),
                filled: true,
                fillColor: surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide(color: primary)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Wrap(
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catálogo de Startups', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: text)),
            const SizedBox(height: 4),
            Text('Explore e invista nas melhores startups do mercado', style: TextStyle(fontSize: 14, color: textMuted)),
          ],
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: controller.refresh,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Atualizar catálogo'),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        return GridView.count(
          crossAxisCount: wide ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: wide ? 1.7 : 1.45,
          children: [
            _statCard('Total de Startups', '${controller.totalStartups}', 'catálogo carregado'),
            _statCard('Cap. Total Captada', _sumRaisedLabel(), 'somatório da API'),
            _statCard('Startups Abertas', '${controller.openRounds}', 'rodada ativa', neutral: true),
            _statCard('Setores', '${controller.sectorsCount}', 'diversificado', neutral: true),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String value, String delta, {bool neutral = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: textMuted)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: text)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: neutral ? surfaceAlt : successBg, borderRadius: BorderRadius.circular(999)),
            child: Text(delta, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: neutral ? textMuted : success)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _filterChip('Todas', 'all', controller.totalStartups),
        _filterChip('Fintech', 'fintech', controller.countBySector('fintech')),
        _filterChip('Healthtech', 'healthtech', controller.countBySector('healthtech')),
        _filterChip('Agtech', 'agtech', controller.countBySector('agtech')),
        _filterChip('Edtech', 'edtech', controller.countBySector('edtech')),
        _filterChip('Logtech', 'logtech', controller.countBySector('logtech')),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: surface, border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedSort,
              items: const [
                DropdownMenuItem(value: 'raised', child: Text('Maior captação')),
                DropdownMenuItem(value: 'name', child: Text('Nome A–Z')),
                DropdownMenuItem(value: 'stage', child: Text('Estágio')),
              ],
              onChanged: (value) {
                if (value != null) controller.setSort(value);
              },
            ),
          ),
        ),
        ToggleButtons(
          isSelected: [!controller.listView, controller.listView],
          onPressed: (index) => controller.toggleView(index == 1),
          borderRadius: BorderRadius.circular(12),
          selectedColor: primary,
          fillColor: primaryLight,
          color: textMuted,
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.grid_view_rounded, size: 18)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.view_list_rounded, size: 18)),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value, int count) {
    final active = controller.selectedFilter == value;
    return InkWell(
      onTap: () => controller.setFilter(value),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? primaryLight : surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? const Color(0xFFFDE68A) : border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: active ? primary : textMuted)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFFDE68A) : const Color(0xFFEDE6D6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? primary : textMuted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid(bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (controller.listView ? 1 : 3),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: controller.listView ? 3.2 : 0.95,
      ),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [_skeletonBox(48, 48, radius: 14), const SizedBox(width: 12), Expanded(child: Column(children: [_skeletonBox(double.infinity, 14), const SizedBox(height: 8), _skeletonBox(double.infinity, 12)]))]),
            const SizedBox(height: 16),
            _skeletonBox(double.infinity, 12),
            const SizedBox(height: 8),
            _skeletonBox(180, 12),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _skeletonBox(double.infinity, 54, radius: 12)), const SizedBox(width: 8), Expanded(child: _skeletonBox(double.infinity, 54, radius: 12)), const SizedBox(width: 8), Expanded(child: _skeletonBox(double.infinity, 54, radius: 12))]),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox(double width, double height, {double radius = 8}) {
    return Container(width: width, height: height, decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(radius)));
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.cloud_off_rounded, color: Color(0xFF991B1B), size: 30),
            ),
            const SizedBox(height: 16),
            Text('Erro ao carregar catálogo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
            const SizedBox(height: 8),
            Text(controller.errorMessage ?? 'Ocorreu um erro.', style: TextStyle(fontSize: 14, color: textMuted)),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
              onPressed: controller.refresh,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(18)),
              child: Icon(Icons.search_off_rounded, color: textFaint, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Nenhuma startup encontrada', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
            const SizedBox(height: 8),
            Text('Tente ajustar os filtros ou a busca.', style: TextStyle(fontSize: 14, color: textMuted)),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
              onPressed: controller.resetFilters,
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogGrid(List<StartupModel> startups, bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: startups.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (controller.listView ? 1 : 3),
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: controller.listView ? 3.2 : 0.95,
      ),
      itemBuilder: (_, index) => _startupCard(startups[index]),
    );
  }

  Widget _startupCard(StartupModel s) {
    final sectorStyle = _sectorStyle(s.sector);
    final stageColor = _stageColor(s.stage);
    final isPositive = !s.roi.trim().startsWith('-');

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDetails(s),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: s.logoBackground, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                    child: Center(child: Text(s.logoText, style: TextStyle(fontWeight: FontWeight.w800, color: s.logoForeground))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
                        const SizedBox(height: 4),
                        Text(s.tagline, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: sectorStyle.$1, borderRadius: BorderRadius.circular(999)),
                    child: Text(sectorStyle.$3, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sectorStyle.$2)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, height: 1.45, color: textMuted)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _metricBox(s.raised, 'Captado')),
                        const SizedBox(width: 8),
                        Expanded(child: _metricBox('${s.investors}', 'Investidores')),
                        const SizedBox(width: 8),
                        Expanded(child: _metricBox(s.roi, 'ROI médio', color: isPositive ? success : const Color(0xFF991B1B))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: s.tags.isEmpty
                          ? [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(999), border: Border.all(color: border)),
                                child: Text('Sem tags', style: TextStyle(fontSize: 11, color: textMuted)),
                              )
                            ]
                          : s.tags
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(999), border: Border.all(color: border)),
                                    child: Text(tag, style: TextStyle(fontSize: 11, color: textMuted)),
                                  ))
                              .toList(),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: stageColor, borderRadius: BorderRadius.circular(999))),
                        const SizedBox(width: 8),
                        Text(_stageLabel(s.stage), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted)),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => _showDetails(s),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textMuted,
                            side: BorderSide(color: border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Ver mais'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => _showInvestMessage(s),
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Investir'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String value, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color ?? text)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: textFaint)),
        ],
      ),
    );
  }

  (Color, Color, String) _sectorStyle(String sector) {
    switch (sector) {
      case 'fintech':
        return (const Color(0xFFFEF3C7), const Color(0xFFB45309), 'Fintech');
      case 'healthtech':
        return (const Color(0xFFDCFCE7), const Color(0xFF166534), 'Healthtech');
      case 'agtech':
        return (const Color(0xFFD1FAE5), const Color(0xFF065F46), 'Agtech');
      case 'edtech':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF), 'Edtech');
      case 'logtech':
        return (const Color(0xFFEDE9FE), const Color(0xFF5B21B6), 'Logtech');
      default:
        return (const Color(0xFFF3F4F6), const Color(0xFF374151), 'Startup');
    }
  }

  Color _stageColor(String stage) {
    final lowered = stage.toLowerCase();
    if (lowered.contains('seed')) return const Color(0xFFF59E0B);
    if (lowered.contains('b')) return const Color(0xFF10B981);
    if (lowered.contains('a')) return const Color(0xFF3B82F6);
    if (lowered.contains('c')) return const Color(0xFF8B5CF6);
    return const Color(0xFF6B7280);
  }

  String _stageLabel(String stage) {
    switch (stage) {
      case 'Serie A': return 'Série A';
      case 'Serie B': return 'Série B';
      case 'Serie C': return 'Série C';
      default: return stage;
    }
  }

  String _sumRaisedLabel() {
    final total = controller.startups.fold<int>(0, (sum, item) {
      final clean = item.raised.replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(clean) ?? 0);
    });
    if (total >= 1000) {
      return 'R\$ ${(total / 1000).toStringAsFixed(1).replaceAll('.', ',')}M';
    }
    return 'R\$ $total';
  }

  void _showDetails(StartupModel startup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 16),
            Text(startup.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: text)),
            const SizedBox(height: 6),
            Text(startup.tagline, style: TextStyle(fontSize: 14, color: textMuted)),
            const SizedBox(height: 16),
            Text(startup.description, style: TextStyle(fontSize: 14, color: textMuted, height: 1.5)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: startup.raw.entries
                  .take(8)
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(999)),
                        child: Text('${e.key}: ${e.value}', style: TextStyle(fontSize: 11, color: textMuted)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvestMessage(StartupModel startup) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fluxo de investimento para ${startup.name} em desenvolvimento.'),
        backgroundColor: primary,
      ),
    );
  }
}
