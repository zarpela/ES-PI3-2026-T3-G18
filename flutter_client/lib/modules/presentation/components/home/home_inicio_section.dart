import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_header.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class HomeInicioSection extends StatelessWidget {
  const HomeInicioSection({
    required this.controller,
    required this.onProfileTap,
    required this.onDepositTap,
    required this.onWithdrawTap,
    required this.onHistoryTap,
    required this.onFeaturedTap,
    required this.onRetry,
    this.showHeader = true,
    super.key,
  });

  final HomeController controller;
  final VoidCallback onProfileTap;
  final VoidCallback onDepositTap;
  final VoidCallback onWithdrawTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onFeaturedTap;
  final Future<void> Function() onRetry;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
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
        _InvestedBalanceCard(controller: controller),
        const SizedBox(height: 24),
        _InicioActionsGrid(
          onDepositTap: onDepositTap,
          onWithdrawTap: onWithdrawTap,
          onHistoryTap: onHistoryTap,
        ),
        const SizedBox(height: 24),
        if (controller.isStartupsLoading && controller.featuredStartup == null)
          const _LoadingCard()
        else if (controller.errorMessage != null &&
            controller.featuredStartup == null)
          _ErrorCard(message: controller.errorMessage, onRetry: onRetry)
        else
          _FeaturedCard(
            name: controller.featuredStartupName,
            description: controller.featuredStartupDescription,
            imageUrl: _featuredImageFor(controller.featuredStartup),
            onPressed: onFeaturedTap,
          ),
      ],
    );
  }
}

class _InvestedBalanceCard extends StatelessWidget {
  const _InvestedBalanceCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
              color: HomePalette.mutedText,
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
                    color: HomePalette.deepText,
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
                    color: HomePalette.mutedText,
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
              color: HomePalette.softYellow,
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
}

class _InicioActionsGrid extends StatelessWidget {
  const _InicioActionsGrid({
    required this.onDepositTap,
    required this.onWithdrawTap,
    required this.onHistoryTap,
  });

  final VoidCallback onDepositTap;
  final VoidCallback onWithdrawTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.account_balance_rounded,
                label: 'Depositar',
                iconColor: Colors.white,
                iconBackground: const LinearGradient(
                  colors: [Color(0xFFD4147A), Color(0xFFB71269)],
                ),
                onTap: onDepositTap,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Sacar',
                iconColor: Colors.white,
                iconBackground: const LinearGradient(
                  colors: [Color(0xFF7A6AE3), Color(0xFF655AC4)],
                ),
                onTap: onWithdrawTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionCard(
          icon: Icons.receipt_long_outlined,
          label: 'Extrato',
          iconColor: HomePalette.brandPurple,
          iconBackground: const LinearGradient(
            colors: [Color(0xFFE7DEFF), Color(0xFFD8CEFF)],
          ),
          onTap: onHistoryTap,
          wide: true,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final LinearGradient iconBackground;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: wide ? 108 : 112,
      decoration: BoxDecoration(
        color: HomePalette.panel,
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
          onTap: onTap,
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
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.onPressed,
  });

  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
                    color: HomePalette.softYellow,
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
                  name,
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
                  description,
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
                          color: HomePalette.brandPink.withValues(alpha: 0.26),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onPressed,
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
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: HomePalette.panel,
        borderRadius: BorderRadius.circular(34),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: HomePalette.brandPink),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: HomePalette.panel,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: HomePalette.brandPink,
            size: 38,
          ),
          const SizedBox(height: 14),
          const Text(
            'Nao foi possivel carregar o destaque.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HomePalette.deepText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message ?? 'Tente novamente em instantes.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomePalette.mutedText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
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
    );
  }
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
