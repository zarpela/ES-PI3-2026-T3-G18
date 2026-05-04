//feito por pedro henrique bonetto

import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Modular.get<HomeController>();
  int currentIndex = 1;

  static const Color bg = Color(0xFFF7F3FA);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF2E2340);
  static const Color textMuted = Color(0xFF7D718F);
  static const Color primary = Color(0xFFC2187A);
  static const Color primaryDark = Color(0xFFA31568);
  static const Color chipBg = Color(0xFFF3E8FF);
  static const Color yellowChip = Color(0xFFFFE79A);
  static const Color border = Color(0xFFE7DFF0);

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.load());
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startups = controller.startups;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: _buildBottomNav(),
      body: RefreshIndicator(
        color: primary,
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 24),
          children: [
            _buildTopHeader(),
            const SizedBox(height: 20),
            _buildHeroText(),
            const SizedBox(height: 18),
            _buildFilters(),
            const SizedBox(height: 18),
            if (controller.isLoading)
              _buildSkeletonList()
            else if (controller.errorMessage != null)
              _buildErrorState()
            else if (startups.isEmpty)
              _buildEmptyState()
            else
              ...startups.map(_buildStartupCard),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFEDE7F6),
          child: const Text(
            'MI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MesclaInvest',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Startups',
          style: TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Invista no futuro hoje mesmo.',
          style: TextStyle(
            fontSize: 13,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip('Tudo', 'all', active: controller.selectedFilter == 'all', color: yellowChip),
          _chip('Agrotech', 'agtech', active: controller.selectedFilter == 'agtech'),
          _chip('Fintech', 'fintech', active: controller.selectedFilter == 'fintech'),
          _chip('Health', 'healthtech', active: controller.selectedFilter == 'healthtech'),
          _chip('Edtech', 'edtech', active: controller.selectedFilter == 'edtech'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, {required bool active, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => controller.setFilter(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? (color ?? chipBg) : const Color(0xFFF2EEF7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF5A5069),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartupCard(Map<String, dynamic> s) {
    final image = _imageBySector('${s['sector'] ?? ''}');
    final sectorBadge = _sectorLabel('${s['sector'] ?? ''}');
    final price = _formatRaised('${s['raised'] ?? ''}');
    final investment = _fakeTicketByStage('${s['stage'] ?? ''}');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 132,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sectorBadge.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (s['name'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (s['description'] ?? '').toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CAPTAÇÃO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (s['roi'] ?? '').toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INVESTIMENTO MÍN.',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            investment,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => _showInvestMessage(s),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Investir',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Container(
                height: 132,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _skel(double.infinity, 18),
                    const SizedBox(height: 8),
                    _skel(double.infinity, 12),
                    const SizedBox(height: 6),
                    _skel(150, 12),
                    const SizedBox(height: 16),
                    _skel(120, 12),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _skel(120, 18)),
                        const SizedBox(width: 16),
                        _skel(90, 38, radius: 999),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skel(double width, double height, {double radius = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECF6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.cloud_off_rounded, color: primary),
            ),
            const SizedBox(height: 14),
            const Text(
              'Erro ao carregar catálogo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Não foi possível carregar as startups.',
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF4EFF8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.search_off_rounded, color: textMuted),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma startup encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar os filtros ou a busca.',
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Início', 0),
            _navItem(Icons.travel_explore_rounded, 'Explorar', 1, active: true),
            _navItem(Icons.candlestick_chart_rounded, 'Carteira', 2),
            _navItem(Icons.person_outline_rounded, 'Perfil', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {bool active = false}) {
    return InkWell(
      onTap: () {
        setState(() => currentIndex = index);
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: active ? primary : textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? primary : textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sectorLabel(String sector) {
    switch (sector.toLowerCase()) {
      case 'fintech':
        return 'Fintech';
      case 'agtech':
        return 'Agrotech';
      case 'healthtech':
        return 'Health';
      case 'edtech':
        return 'Edtech';
      case 'logtech':
        return 'Logtech';
      default:
        return 'Startup';
    }
  }

  String _imageBySector(String sector) {
    switch (sector.toLowerCase()) {
      case 'fintech':
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=1200&auto=format&fit=crop';
      case 'agtech':
        return 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1200&auto=format&fit=crop';
      case 'healthtech':
        return 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=1200&auto=format&fit=crop';
      case 'edtech':
        return 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1200&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1200&auto=format&fit=crop';
    }
  }

  String _formatRaised(String value) {
    if (value.trim().isEmpty) return 'R\$ 0';
    return value.contains('R\$') ? value : 'R\$ $value';
  }

  String _fakeTicketByStage(String stage) {
    final lower = stage.toLowerCase();
    if (lower.contains('seed')) return 'R\$ 5.000';
    if (lower.contains('series a') || lower == 'a') return 'R\$ 25.000';
    if (lower.contains('series b') || lower == 'b') return 'R\$ 50.000';
    return 'R\$ 10.000';
  }

  void _showInvestMessage(Map<String, dynamic> startup) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fluxo de investimento para ${(startup['name'] ?? 'startup')} em desenvolvimento.',
        ),
        backgroundColor: primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}