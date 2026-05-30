//feito por Abdallah
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/components/home/home_section.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    required this.currentSection,
    required this.bottomInset,
    required this.onSectionSelected,
    super.key,
  });

  final HomeSection currentSection;
  final double bottomInset;
  final ValueChanged<HomeSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: HomePalette.navBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HomeNavItem(
              icon: Icons.home_outlined,
              label: 'INÍCIO',
              isActive: currentSection == HomeSection.inicio,
              onTap: () => onSectionSelected(HomeSection.inicio),
            ),
          ),
          Expanded(
            child: _HomeNavItem(
              icon: Icons.search_rounded,
              label: 'EXPLORAR',
              isActive: currentSection == HomeSection.explorar,
              onTap: () => onSectionSelected(HomeSection.explorar),
            ),
          ),
          Expanded(
            child: _HomeNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'CARTEIRA',
              isActive: currentSection == HomeSection.carteira,
              onTap: () => onSectionSelected(HomeSection.carteira),
            ),
          ),
          Expanded(
            child: _HomeNavItem(
              icon: Icons.pie_chart_outline_rounded,
              label: 'PORTFÓLIO',
              isActive: currentSection == HomeSection.portfolio,
              onTap: () => onSectionSelected(HomeSection.portfolio),
            ),
          ),
        ],
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
                ? HomePalette.activeNavBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 29,
                color: isActive ? HomePalette.brandPink : HomePalette.mutedText,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? HomePalette.brandPink
                      : HomePalette.mutedText,
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
