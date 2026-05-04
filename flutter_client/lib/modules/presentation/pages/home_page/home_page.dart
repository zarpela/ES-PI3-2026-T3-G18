import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum _HomeSection { inicio, explorar, carteira, perfil }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Modular.get<HomeController>();

  static const Color shellBackground = Color(0xFF1F1E24);
  static const Color pageBackground = Color(0xFFFCF9FF);
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color panel = Color(0xFFF4EEFB);
  static const Color dividerBlue = Color(0xFF3C9BFF);
  static const Color brandPink = Color(0xFFD4147A);
  static const Color brandPurple = Color(0xFF655AC4);
  static const Color deepText = Color(0xFF241B60);
  static const Color mutedText = Color(0xFF756E93);
  static const Color softYellow = Color(0xFFFFDE74);
  static const Color activeNavBackground = Color(0xFFECE4FF);

  _HomeSection _currentSection = _HomeSection.carteira;

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
    final mediaQuery = MediaQuery.of(context);
    final isDesktopShell = mediaQuery.size.width >= 640;
    final borderRadius = BorderRadius.circular(isDesktopShell ? 34 : 0);
    final topInset = isDesktopShell ? 12.0 : mediaQuery.padding.top;
    final bottomInset = isDesktopShell ? 10.0 : mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: isDesktopShell ? shellBackground : pageBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: pageBackground,
              borderRadius: borderRadius,
              boxShadow: isDesktopShell
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: brandPink,
                      onRefresh: controller.refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(18, topInset + 12, 18, 24),
                        children: _buildSectionChildren(),
                      ),
                    ),
                  ),
                  _buildBottomNavigation(bottomInset),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionChildren() {
    return switch (_currentSection) {
      _HomeSection.inicio => _buildInicioSection(),
      _HomeSection.explorar => _buildExplorarSection(),
      _HomeSection.carteira => _buildCarteiraSection(),
      _HomeSection.perfil => _buildPerfilSection(),
    };
  }

  List<Widget> _buildInicioSection() {
    return [
      _buildHeader(),
      const SizedBox(height: 16),
      const Divider(height: 1, thickness: 1.5, color: dividerBlue),
      const SizedBox(height: 18),
      _buildWelcomeCard(),
      const SizedBox(height: 22),
      _buildShortcutCard(
        title: 'Explorar Startups',
        description:
            'Volte para o catalogo que voce ja usava e descubra novas oportunidades.',
        buttonLabel: 'Abrir explorar',
        onPressed: () => _selectSection(_HomeSection.explorar),
      ),
      const SizedBox(height: 18),
      if (controller.isLoading && controller.featuredStartup == null)
        _buildLoadingCard()
      else if (controller.errorMessage != null &&
          controller.featuredStartup == null)
        _buildErrorCard()
      else
        _buildFeaturedCard(controller.featuredStartup),
    ];
  }

  List<Widget> _buildCarteiraSection() {
    return [
      _buildHeader(),
      const SizedBox(height: 16),
      const Divider(height: 1, thickness: 1.5, color: dividerBlue),
      const SizedBox(height: 18),
      _buildBalanceCard(),
      const SizedBox(height: 24),
      _buildActionsGrid(),
      const SizedBox(height: 24),
      if (controller.isLoading && controller.featuredStartup == null)
        _buildLoadingCard()
      else if (controller.errorMessage != null &&
          controller.featuredStartup == null)
        _buildErrorCard()
      else
        _buildFeaturedCard(controller.featuredStartup),
    ];
  }

  List<Widget> _buildExplorarSection() {
    final startups = controller.startups;

    return [
      _buildHeader(),
      const SizedBox(height: 16),
      const Divider(height: 1, thickness: 1.5, color: dividerBlue),
      const SizedBox(height: 18),
      _buildExploreHero(),
      const SizedBox(height: 18),
      _buildSearchField(),
      const SizedBox(height: 16),
      _buildExploreFilters(),
      const SizedBox(height: 18),
      if (controller.isLoading)
        _buildExploreSkeletonList()
      else if (controller.errorMessage != null)
        _buildExploreErrorState()
      else if (startups.isEmpty)
        _buildExploreEmptyState()
      else
        ...startups.map(_buildStartupCard),
    ];
  }

  List<Widget> _buildPerfilSection() {
    return [
      _buildHeader(),
      const SizedBox(height: 16),
      const Divider(height: 1, thickness: 1.5, color: dividerBlue),
      const SizedBox(height: 22),
      _buildProfileCard(),
      const SizedBox(height: 18),
      _buildShortcutCard(
        title: 'Sua foto de perfil',
        description:
            'Toque no avatar ou no botao abaixo para trocar a foto que aparece no cabecalho.',
        buttonLabel: 'Alterar foto',
        onPressed: _handleProfilePhotoTap,
      ),
    ];
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: _handleProfilePhotoTap,
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(1.6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF243645), Color(0xFF182632)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF4EEF8),
                        image: controller.profileImage == null
                            ? null
                            : DecorationImage(
                                image: controller.profileImage!,
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: controller.profileImage == null
                          ? Center(
                              child: Text(
                                controller.userInitials,
                                style: const TextStyle(
                                  color: deepText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: brandPink,
                        shape: BoxShape.circle,
                        border: Border.all(color: pageBackground, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'MesclaInvest',
            style: TextStyle(
              color: brandPink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F3FF), Color(0xFFECE3FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ola, ${controller.userLabel}',
            style: const TextStyle(
              color: deepText,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seu painel principal continua aqui, e agora a aba Explorar voltou com o catalogo de startups.',
            style: TextStyle(color: mutedText, fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6EDF7), Color(0xFFE5DCF5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SALDO INVESTIDO',
            style: TextStyle(
              color: mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.balanceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: controller.toggleBalanceVisibility,
                  icon: Icon(
                    controller.isBalanceVisible
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off_outlined,
                    color: mutedText,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: softYellow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              controller.performanceLabel,
              style: const TextStyle(
                color: Color(0xFF655116),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.account_balance_rounded,
                label: 'Depositar',
                iconColor: Colors.white,
                iconBackground: const LinearGradient(
                  colors: [Color(0xFFD4147A), Color(0xFFB71269)],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildActionCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Sacar',
                iconColor: Colors.white,
                iconBackground: const LinearGradient(
                  colors: [Color(0xFF7A6AE3), Color(0xFF655AC4)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildActionCard(
          icon: Icons.receipt_long_outlined,
          label: 'Extrato',
          iconColor: brandPurple,
          iconBackground: const LinearGradient(
            colors: [Color(0xFFE7DEFF), Color(0xFFD8CEFF)],
          ),
          wide: true,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required LinearGradient iconBackground,
    bool wide = false,
  }) {
    return Container(
      height: wide ? 108 : 112,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D1654).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => _showPlaceholderMessage(label),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF433D5E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: deepText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: mutedText, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Startups',
          style: TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: deepText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Invista no futuro hoje mesmo.',
          style: TextStyle(fontSize: 13, color: mutedText),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: activeNavBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${controller.totalStartups} oportunidades carregadas',
            style: const TextStyle(
              color: brandPink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
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
          prefixIcon: Icon(Icons.search_rounded, color: mutedText),
          hintText: 'Buscar startup',
          hintStyle: TextStyle(color: mutedText),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildExploreFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tudo', 'all', activeColor: softYellow),
          _buildFilterChip('Agrotech', 'agtech'),
          _buildFilterChip('Fintech', 'fintech'),
          _buildFilterChip('Health', 'healthtech'),
          _buildFilterChip('Edtech', 'edtech'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {Color? activeColor}) {
    final isActive = controller.selectedFilter == value;
    final count = value == 'all'
        ? controller.totalStartups
        : controller.sectorCount(value);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => controller.setFilter(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? (activeColor ?? activeNavBackground) : panel,
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
                  color: mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartupCard(Map<String, dynamic> startup) {
    final image = _imageBySector((startup['sector'] ?? '').toString());
    final sectorBadge = _sectorLabel((startup['sector'] ?? '').toString());
    final raised = (startup['raised'] ?? 'R\$ 0').toString();
    final investment = _fakeTicketByStage((startup['stage'] ?? '').toString());
    final roi = _startupRoiLabel(startup);
    final name = (startup['name'] ?? 'Startup').toString();
    final description = (startup['description'] ?? 'Sem descricao informada.')
        .toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
              Container(
                height: 132,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: brandPink,
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
                    color: deepText,
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
                    color: mutedText,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CAPTACAO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: mutedText,
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
                        color: brandPink,
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
                          color: mutedText,
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
                              color: mutedText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            investment,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: deepText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => _showStartupMessage(name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPink,
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

  Widget _buildExploreSkeletonList() {
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
                    _buildSkeletonLine(double.infinity, 18),
                    const SizedBox(height: 8),
                    _buildSkeletonLine(double.infinity, 12),
                    const SizedBox(height: 6),
                    _buildSkeletonLine(150, 12),
                    const SizedBox(height: 16),
                    _buildSkeletonLine(120, 12),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _buildSkeletonLine(120, 18)),
                        const SizedBox(width: 16),
                        _buildSkeletonLine(90, 38, radius: 999),
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

  Widget _buildSkeletonLine(double width, double height, {double radius = 10}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECF6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic>? startup) {
    final imageUrl = _featuredImageFor(startup);

    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x05000000), Color(0x40000000), Color(0xCC000000)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: softYellow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'DESTAQUE',
                    style: TextStyle(
                      color: Color(0xFF655116),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  controller.featuredStartupName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.featuredStartupDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF4EEFF),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4147A), Color(0xFFB51369)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: brandPink.withValues(alpha: 0.26),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () =>
                          _showStartupMessage(controller.featuredStartupName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Conhecer Oportunidade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: navBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HomeNavItem(
              icon: Icons.home_outlined,
              label: 'INICIO',
              isActive: _currentSection == _HomeSection.inicio,
              onTap: () => _selectSection(_HomeSection.inicio),
            ),
          ),
          Expanded(
            child: _HomeNavItem(
              icon: Icons.search_rounded,
              label: 'EXPLORAR',
              isActive: _currentSection == _HomeSection.explorar,
              onTap: () => _selectSection(_HomeSection.explorar),
            ),
          ),
          Expanded(
            child: _HomeNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'CARTEIRA',
              isActive: _currentSection == _HomeSection.carteira,
              onTap: () => _selectSection(_HomeSection.carteira),
            ),
          ),
          Expanded(
            child: _HomeNavItem(
              icon: Icons.person_outline_rounded,
              label: 'PERFIL',
              isActive: _currentSection == _HomeSection.perfil,
              onTap: () => _selectSection(_HomeSection.perfil),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(34),
      ),
      child: const Center(child: CircularProgressIndicator(color: brandPink)),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: brandPink, size: 38),
          const SizedBox(height: 14),
          const Text(
            'Nao foi possivel carregar o destaque.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: deepText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.errorMessage ?? 'Tente novamente em instantes.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedText, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: controller.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreErrorState() {
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
              child: const Icon(Icons.cloud_off_rounded, color: brandPink),
            ),
            const SizedBox(height: 14),
            const Text(
              'Erro ao carregar catalogo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: deepText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ??
                  'Nao foi possivel carregar as startups.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: mutedText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPink,
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

  Widget _buildExploreEmptyState() {
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
              child: const Icon(Icons.search_off_rounded, color: mutedText),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma startup encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: deepText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar os filtros ou a busca.',
              style: TextStyle(fontSize: 13, color: mutedText),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPink,
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

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFD4147A), Color(0xFF655AC4)],
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: controller.profileImage == null
                    ? null
                    : DecorationImage(
                        image: controller.profileImage!,
                        fit: BoxFit.cover,
                      ),
              ),
              child: controller.profileImage == null
                  ? Center(
                      child: Text(
                        controller.userInitials,
                        style: const TextStyle(
                          color: deepText,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.userLabel,
            style: const TextStyle(
              color: deepText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.currentUser?.email ?? 'Conta MesclaInvest',
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _handleProfilePhotoTap() async {
    final updated = await controller.selectProfilePhoto();

    if (!mounted) {
      return;
    }

    if (updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto atualizada com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nenhuma foto foi selecionada.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectSection(_HomeSection section) {
    if (_currentSection == section) {
      return;
    }

    setState(() {
      _currentSection = section;
    });
  }

  String _featuredImageFor(Map<String, dynamic>? startup) {
    final sector = (startup?['sector'] ?? '').toString().trim().toLowerCase();

    switch (sector) {
      case 'fintech':
        return 'https://images.unsplash.com/photo-1550565118-3a14e8d0386f?q=80&w=1200&auto=format&fit=crop';
      case 'healthtech':
        return 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=1200&auto=format&fit=crop';
      case 'edtech':
        return 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=1200&auto=format&fit=crop';
      case 'agtech':
        return 'https://images.unsplash.com/photo-1509391366360-2e959784a276?q=80&w=1200&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?q=80&w=1200&auto=format&fit=crop';
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
      default:
        return 'Startup';
    }
  }

  String _fakeTicketByStage(String stage) {
    final lower = stage.toLowerCase();
    if (lower.contains('seed')) {
      return 'R\$ 5.000';
    }
    if (lower.contains('series a') || lower == 'a') {
      return 'R\$ 25.000';
    }
    if (lower.contains('series b') || lower == 'b') {
      return 'R\$ 50.000';
    }
    return 'R\$ 10.000';
  }

  String _startupRoiLabel(Map<String, dynamic> startup) {
    final roi = (startup['roi'] ?? '').toString().trim();
    if (roi.isEmpty) {
      return 'Potencial em analise';
    }
    return roi;
  }

  void _showPlaceholderMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action em desenvolvimento.'),
        backgroundColor: brandPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStartupMessage(String startupName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir detalhes de $startupName em desenvolvimento.'),
        backgroundColor: brandPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  const _HomeNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 74,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? _HomePageState.activeNavBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 29,
                color: isActive
                    ? _HomePageState.brandPink
                    : _HomePageState.mutedText,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? _HomePageState.brandPink
                      : _HomePageState.mutedText,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
