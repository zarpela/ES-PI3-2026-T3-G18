//feito por Abdallah
// feito por pedro, marcelo
import 'package:flutter/material.dart';
import 'package:flutter_client/core/app_session.dart';
import 'package:flutter_client/modules/presentation/components/home/home_bottom_navigation.dart';
import 'package:flutter_client/modules/presentation/components/home/home_explore_section.dart';
import 'package:flutter_client/modules/presentation/components/home/home_history_sheet.dart';
import 'package:flutter_client/modules/presentation/components/home/home_inicio_section.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/components/home/home_section.dart';
import 'package:flutter_client/modules/presentation/components/home/home_wallet_section.dart';
import 'package:flutter_client/modules/presentation/components/main_header.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/wallet_amount_page.dart';
import 'package:flutter_client/modules/presentation/pages/portfolio_page/portfolio_page.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Modular.get<HomeController>();
  HomeSection currentSection = HomeSection.inicio;

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensureAuthorizedSession(),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _ensureAuthorizedSession() async {
    if (!AppSession.instance.isAccessGranted ||
        controller.currentUser == null) {
      controller.reset();
      await controller.auth.signOut();
      if (mounted) {
        Modular.to.navigate(AppRoutes.login);
      }
      return;
    }

    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktopShell = mediaQuery.size.width >= 640;
    final borderRadius = BorderRadius.circular(isDesktopShell ? 34 : 0);
    final topInset = isDesktopShell ? 12.0 : mediaQuery.padding.top;
    final bottomInset = isDesktopShell ? 10.0 : mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: isDesktopShell
          ? HomePalette.shellBackground
          : HomePalette.pageBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HomePalette.pageBackground,
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, topInset + 12, 18, 0),
                    child: MainHeader(
                      controller: controller,
                      onProfileTap: _handleProfilePhotoTap,
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: HomePalette.brandPink,
                      displacement: 28,
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      notificationPredicate: (notification) =>
                          notification.depth == 0,
                      onRefresh: _handleRefresh,
                      child: ListView(
                        key: PageStorageKey<String>(
                          'home-${currentSection.name}',
                        ),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                        children: [
                          _buildCurrentSection(),
                          const SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ),
                  HomeBottomNavigation(
                    currentSection: currentSection,
                    bottomInset: bottomInset,
                    onSectionSelected: _selectSection,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openStartupDetails(Map<String, dynamic> startup) {
    Modular.to.pushNamed(AppRoutes.startupDetailsPage, arguments: startup);
  }

  Widget _buildCurrentSection() {
    switch (currentSection) {
      case HomeSection.inicio:
        return HomeInicioSection(
          controller: controller,
          onProfileTap: _handleProfilePhotoTap,
          onDepositTap: () =>
              _openWalletAmountPage(WalletAmountPageMode.deposit),
          onWithdrawTap: () =>
              _openWalletAmountPage(WalletAmountPageMode.withdraw),
          onHistoryTap: _showHistorySheet,
          onFeaturedTap: () =>
              _openStartupDetailsByName(controller.featuredStartupName),
          onRetry: controller.refresh,
          showHeader: false,
        );

      case HomeSection.explorar:
        return HomeExploreSection(
          controller: controller,
          onProfileTap: _handleProfilePhotoTap,
          onRetry: controller.refresh,
          onStartupTap: _openStartupDetails,
          showHeader: false,
        );
      case HomeSection.carteira:
        return HomeWalletSection(
          controller: controller,
          onProfileTap: _handleProfilePhotoTap,
          onDepositTap: () =>
              _openWalletAmountPage(WalletAmountPageMode.deposit),
          onWithdrawTap: () =>
              _openWalletAmountPage(WalletAmountPageMode.withdraw),
          onHistoryTap: _showHistorySheet,
          onInvestTap: _selectSection,
          showHeader: false,
        );

      case HomeSection.portfolio:
        return PortfolioView(controller: controller);
    }
  }

  void _handleProfilePhotoTap() {
    Modular.to.pushNamed(AppRoutes.settings);
  }

  Future<void> _openWalletAmountPage(WalletAmountPageMode mode) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => WalletAmountPage(controller: controller, mode: mode),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _showHistorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return HomeHistorySheet(
          transactions: controller.recentTransactions,
          formatCurrencyAmount: controller.formatCurrencyAmount,
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    if (currentSection == HomeSection.carteira) {
      await controller.refreshWallet();
      return;
    }

    await controller.refresh();
  }

  void _selectSection(HomeSection section) {
    if (currentSection == section) {
      return;
    }

    setState(() {
      currentSection = section;
    });
  }

  void _openStartupDetailsByName(String startupName) {
    final startup = _findStartupByName(startupName);

    if (startup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Startup "$startupName" não encontrada.'),
          backgroundColor: HomePalette.brandPink,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Modular.to.pushNamed(AppRoutes.startupDetailsPage, arguments: startup);
  }

  Map<String, dynamic>? _findStartupByName(String startupName) {
    final normalizedTarget = startupName.trim().toLowerCase();

    for (final startup in controller.startups) {
      final currentName = '${startup['name'] ?? ''}'.trim().toLowerCase();
      if (currentName == normalizedTarget) {
        return startup;
      }
    }

    if (controller.featuredStartupName.trim().toLowerCase() ==
            normalizedTarget &&
        controller.startups.isNotEmpty) {
      return controller.startups.first;
    }

    return null;
  }
}
