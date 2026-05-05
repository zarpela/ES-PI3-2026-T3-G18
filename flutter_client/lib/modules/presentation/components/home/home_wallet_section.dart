import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_header.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/components/home/home_section.dart';
import 'package:flutter_client/modules/presentation/components/home/home_transaction_history_list.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class HomeWalletSection extends StatelessWidget {
  const HomeWalletSection({
    required this.controller,
    required this.onProfileTap,
    required this.onDepositTap,
    required this.onWithdrawTap,
    required this.onHistoryTap,
    required this.onInvestTap,
    this.showHeader = true,
    super.key,
  });

  final HomeController controller;
  final VoidCallback onProfileTap;
  final VoidCallback onDepositTap;
  final VoidCallback onWithdrawTap;
  final VoidCallback onHistoryTap;
  final ValueChanged<HomeSection> onInvestTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          HomeHeader(
            profileImage: controller.profileImage,
            userInitials: controller.userInitials,
            onProfileTap: onProfileTap,
          ),
        const SizedBox(height: 26),
        _WalletBalanceHero(controller: controller),
        const SizedBox(height: 28),
        _WalletQuickActions(
          onDepositTap: onDepositTap,
          onWithdrawTap: onWithdrawTap,
          onHistoryTap: onHistoryTap,
          onInvestTap: () => onInvestTap(HomeSection.explorar),
        ),
        const SizedBox(height: 30),
        const Text(
          'Historico recente',
          style: TextStyle(
            color: HomePalette.deepText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        if (controller.isWalletLoading &&
            controller.recentTransactionsPreview.isEmpty)
          const _LoadingCard()
        else
          HomeTransactionHistoryList(
            transactions: controller.recentTransactionsPreview,
            formatCurrencyAmount: controller.formatCurrencyAmount,
          ),
      ],
    );
  }
}

class _WalletBalanceHero extends StatelessWidget {
  const _WalletBalanceHero({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'SALDO DISPONIVEL',
              style: TextStyle(
                color: HomePalette.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              controller.isBalanceVisible
                  ? Icons.remove_red_eye_outlined
                  : Icons.visibility_off_outlined,
              color: HomePalette.mutedText,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: controller.toggleBalanceVisibility,
          child: Text(
            controller.availableBalanceLabel,
            style: const TextStyle(
              color: HomePalette.deepText,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: HomePalette.softYellow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            controller.walletVariationLabel,
            style: const TextStyle(
              color: Color(0xFF655116),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletQuickActions extends StatelessWidget {
  const _WalletQuickActions({
    required this.onDepositTap,
    required this.onWithdrawTap,
    required this.onHistoryTap,
    required this.onInvestTap,
  });

  final VoidCallback onDepositTap;
  final VoidCallback onWithdrawTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onInvestTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _WalletQuickAction(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Depositar',
          onTap: onDepositTap,
        ),
        _WalletQuickAction(
          icon: Icons.currency_exchange_rounded,
          label: 'Sacar',
          onTap: onWithdrawTap,
        ),
        _WalletQuickAction(
          icon: Icons.receipt_long_outlined,
          label: 'Extrato',
          onTap: onHistoryTap,
        ),
        _WalletQuickAction(
          icon: Icons.account_balance_outlined,
          label: 'Investir',
          onTap: onInvestTap,
        ),
      ],
    );
  }
}

class _WalletQuickAction extends StatelessWidget {
  const _WalletQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF0E8FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: HomePalette.brandPink, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: HomePalette.deepText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
      height: 220,
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
