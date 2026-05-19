import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_header.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class HomeExploreSection extends StatelessWidget {
  const HomeExploreSection({
    required this.controller,
    required this.onProfileTap,
    required this.onRetry,
    required this.onStartupTap,
    this.showHeader = true,
    super.key,
  });

  final HomeController controller;
  final VoidCallback onProfileTap;
  final Future<void> Function() onRetry;
  final ValueChanged<Map<String, dynamic>> onStartupTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final startups = controller.startups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          HomeHeader(
            profileImage: controller.profileImage,
            userInitials: controller.userInitials,
            onProfileTap: onProfileTap,
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 1.5,
            color: HomePalette.dividerBlue,
          ),
          const SizedBox(height: 18),
        ],
        _ExploreHero(totalStartups: controller.totalStartups),
        const SizedBox(height: 18),
        _SearchField(controller: controller),
        const SizedBox(height: 16),
        const Text(
          'Setor',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: HomePalette.mutedText,
          ),
        ),
        const SizedBox(height: 8),
        _ExploreFilters(controller: controller),
        const SizedBox(height: 12),
        const Text(
          'Estágio',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: HomePalette.mutedText,
          ),
        ),
        const SizedBox(height: 8),
        _ExploreStageFilters(controller: controller),
        const SizedBox(height: 18),
        if (controller.isStartupsLoading && startups.isEmpty)
          _ExploreSkeletonList()
        else if (controller.errorMessage != null)
          _ExploreErrorState(message: controller.errorMessage, onRetry: onRetry)
        else if (startups.isEmpty)
          _ExploreEmptyState(onResetFilters: controller.resetFilters)
        else
          ...startups.map(
            (startup) => _StartupCard(
              controller: controller,
              startup: startup,
              onTapStartup: () => onStartupTap(startup),
              onInvestTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Em desenvolvimento'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ExploreHero extends StatelessWidget {
  const _ExploreHero({required this.totalStartups});

  final int totalStartups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Startups',
          style: TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: HomePalette.deepText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Invista no futuro hoje mesmo.',
          style: TextStyle(fontSize: 13, color: HomePalette.mutedText),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: HomePalette.activeNavBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$totalStartups oportunidades carregadas',
            style: const TextStyle(
              color: HomePalette.brandPink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D1654).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: HomePalette.mutedText),
          hintText: 'Buscar startup',
          hintStyle: TextStyle(color: HomePalette.mutedText),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _ExploreFilters extends StatelessWidget {
  const _ExploreFilters({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Tudo',
            value: 'all',
            count: controller.totalStartups,
            isActive: controller.selectedFilter == 'all',
            onTap: controller.setFilter,
            activeColor: HomePalette.softYellow,
          ),
          _FilterChip(
            label: 'Startup',
            value: 'startup',
            count: controller.sectorCount('startup'),
            isActive: controller.selectedFilter == 'startup',
            onTap: controller.setFilter,
          ),
          _FilterChip(
            label: 'Agrotech',
            value: 'agtech',
            count: controller.sectorCount('agtech'),
            isActive: controller.selectedFilter == 'agtech',
            onTap: controller.setFilter,
          ),
          _FilterChip(
            label: 'Fintech',
            value: 'fintech',
            count: controller.sectorCount('fintech'),
            isActive: controller.selectedFilter == 'fintech',
            onTap: controller.setFilter,
          ),
          _FilterChip(
            label: 'Health',
            value: 'healthtech',
            count: controller.sectorCount('healthtech'),
            isActive: controller.selectedFilter == 'healthtech',
            onTap: controller.setFilter,
          ),
          _FilterChip(
            label: 'Edtech',
            value: 'edtech',
            count: controller.sectorCount('edtech'),
            isActive: controller.selectedFilter == 'edtech',
            onTap: controller.setFilter,
          ),
        ],
      ),
    );
  }
}

class _ExploreStageFilters extends StatelessWidget {
  const _ExploreStageFilters({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Todos',
            value: 'all',
            count: controller.stageCount('all'),
            isActive: controller.selectedStageFilter == 'all',
            onTap: controller.setStageFilter,
            activeColor: HomePalette.softYellow,
          ),
          _FilterChip(
            label: 'Novo',
            value: 'novo',
            count: controller.stageCount('novo'),
            isActive: controller.selectedStageFilter == 'novo',
            onTap: controller.setStageFilter,
          ),
          _FilterChip(
            label: 'Em operação',
            value: 'em_operacao',
            count: controller.stageCount('em_operacao'),
            isActive: controller.selectedStageFilter == 'em_operacao',
            onTap: controller.setStageFilter,
          ),
          _FilterChip(
            label: 'Em expansão',
            value: 'em_expansao',
            count: controller.stageCount('em_expansao'),
            isActive: controller.selectedStageFilter == 'em_expansao',
            onTap: controller.setStageFilter,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  final String label;
  final String value;
  final int count;
  final bool isActive;
  final ValueChanged<String> onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor ?? HomePalette.activeNavBackground
                : HomePalette.panel,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF5A5069),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({
    required this.controller,
    required this.startup,
    required this.onTapStartup,
    required this.onInvestTap,
  });

  final HomeController controller;
  final Map<String, dynamic> startup;
  final VoidCallback onTapStartup;
  final VoidCallback onInvestTap;

  @override
  Widget build(BuildContext context) {
    final realImage = controller.backgroundImageOf(startup);
    final fallbackImage = imageBySector((startup['sector'] ?? '').toString());
    final sectorBadge = sectorLabel((startup['sector'] ?? '').toString());
    final stageLabel = formatStageLabel((startup['stage'] ?? '').toString());
    final raised = (startup['raised'] ?? 'R\$ 0').toString();
    final investment = fakeTicketByStage((startup['stage'] ?? '').toString());
    final roi = startupRoiLabel(startup);
    final name = (startup['name'] ?? 'Startup').toString();
    final description = (startup['description'] ?? 'Sem descricao informada.')
        .toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTapStartup,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: SizedBox(
                        height: 132,
                        width: double.infinity,
                        child: realImage != null
                            ? Image.network(
                                realImage,
                                fit: BoxFit.cover,
                                webHtmlElementStrategy:
                                    WebHtmlElementStrategy.prefer,
                                errorBuilder: (_, error, __) {
                                  debugPrint(
                                    'Erro ao carregar imagem real da startup $name: $realImage / $error',
                                  );
                                  return Image.network(
                                    fallbackImage,
                                    fit: BoxFit.cover,
                                    webHtmlElementStrategy:
                                        WebHtmlElementStrategy.prefer,
                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        color: const Color(0xFFEDE7F6),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                          color: HomePalette.mutedText,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : Image.network(
                                fallbackImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: const Color(0xFFEDE7F6),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: HomePalette.mutedText,
                                      size: 28,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: HomePalette.brandPink,
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
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: HomePalette.deepText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: HomePalette.mutedText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: HomePalette.panel,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          stageLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.deepText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'CAPTACAO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: HomePalette.mutedText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            raised,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: HomePalette.brandPink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              roi,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: HomePalette.mutedText,
                              ),
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
                                  'INVESTIMENTO MIN.',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: HomePalette.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  investment,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: HomePalette.deepText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: onInvestTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HomePalette.brandPink,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
          ),
        ),
      ),
    );
  }
}

class _ExploreSkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            children: const [
              _SkeletonTop(),
              Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  children: [
                    _SkeletonLine(double.infinity, 18),
                    SizedBox(height: 8),
                    _SkeletonLine(double.infinity, 12),
                    SizedBox(height: 6),
                    _SkeletonLine(150, 12),
                    SizedBox(height: 16),
                    _SkeletonLine(120, 12),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _SkeletonLine(120, 18)),
                        SizedBox(width: 16),
                        _SkeletonLine(90, 38, radius: 999),
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
}

class _SkeletonTop extends StatelessWidget {
  const _SkeletonTop();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: const BoxDecoration(
        color: Color(0xFFEDE7F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine(this.width, this.height, {this.radius = 10});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECF6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ExploreErrorState extends StatelessWidget {
  const _ExploreErrorState({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(
                Icons.cloud_off_rounded,
                color: HomePalette.brandPink,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Erro ao carregar catalogo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: HomePalette.deepText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Nao foi possivel carregar as startups.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: HomePalette.mutedText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomePalette.brandPink,
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
}

class _ExploreEmptyState extends StatelessWidget {
  const _ExploreEmptyState({required this.onResetFilters});

  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(
                Icons.search_off_rounded,
                color: HomePalette.mutedText,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma startup encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: HomePalette.deepText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar os filtros ou a busca.',
              style: TextStyle(fontSize: 13, color: HomePalette.mutedText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onResetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomePalette.brandPink,
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
}

String imageBySector(String sector) {
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

String sectorLabel(String sector) {
  switch (sector.toLowerCase()) {
    case 'fintech':
      return 'Fintech';
    case 'agtech':
      return 'Agrotech';
    case 'healthtech':
      return 'Health';
    case 'edtech':
      return 'Edtech';
    default:
      return 'Startup';
  }
}

String fakeTicketByStage(String stage) {
  final lower = stage
      .trim()
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (lower.contains('expansao') ||
      lower.contains('expansão') ||
      lower.contains('series b')) {
    return 'R\$ 50.000';
  }

  if (lower.contains('operacao') ||
      lower.contains('operação') ||
      lower.contains('series a')) {
    return 'R\$ 25.000';
  }

  return 'R\$ 10.000';
}

String startupRoiLabel(Map<String, dynamic> startup) {
  final roi = (startup['roi'] ?? '').toString().trim();
  if (roi.isEmpty) {
    return 'Potencial em analise';
  }
  return roi;
}

String formatStageLabel(String stage) {
  final lower = stage
      .trim()
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (lower.contains('expansao') ||
      lower.contains('expansão') ||
      lower.contains('em expansao') ||
      lower.contains('em expansão') ||
      lower.contains('series b') ||
      lower.contains('serie b')) {
    return 'Em expansão';
  }

  if (lower.contains('operacao') ||
      lower.contains('operação') ||
      lower.contains('em operacao') ||
      lower.contains('em operação') ||
      lower.contains('series a') ||
      lower.contains('serie a')) {
    return 'Em operação';
  }

  if (lower.contains('seed') ||
      lower.contains('pre seed') ||
      lower.contains('preseed') ||
      lower.contains('novo') ||
      lower.contains('nova') ||
      lower.contains('new') ||
      lower.contains('inicial') ||
      lower.contains('idea') ||
      lower.contains('ideia')) {
    return 'Novo';
  }

  return 'Novo';
}
