import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({required this.controller, super.key});

  final HomeController controller;

  static const Color colorFintech = Color(0xFFD4147A);
  static const Color colorAgrotech = Color(0xFF8C7311);
  static const Color colorHealthtech = Color(0xFFAEB2FF);

  @override
  Widget build(BuildContext context) {
    final invested = controller.investedBalance ?? 0;
    final totalPatrimonio = controller.availableBalance + invested;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatrimonioHero(totalPatrimonio),
        const SizedBox(height: 24),
        _buildComposicaoCard(),
        const SizedBox(height: 16),
        _buildMetricasRow(),
        const SizedBox(height: 32),
        _buildListaInvestimentos(),
      ],
    );
  }

  Widget _buildPatrimonioHero(double totalPatrimonio) {
    final returnPercent = controller.estimatedReturnPercent;
    final sign = (returnPercent ?? 0) >= 0 ? '+' : '';
    final returnLabel = returnPercent == null
        ? '--'
        : '$sign${returnPercent.toStringAsFixed(1).replaceAll('.', ',')}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PATRIMÔNIO TOTAL',
          style: TextStyle(
            color: HomePalette.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              controller.isBalanceVisible
                  ? controller.formatCurrencyAmount(totalPatrimonio)
                  : 'R\$ ******',
              style: const TextStyle(
                color: HomePalette.deepText,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                returnLabel,
                style: const TextStyle(
                  color: HomePalette.brandPink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.remove_red_eye_outlined,
                color: HomePalette.deepText,
              ),
              onPressed: controller.toggleBalanceVisibility,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComposicaoCard() {
    final tokens = controller.walletTokens;
    final sectors = tokens
        .map((token) => _sectorForToken(token).toLowerCase())
        .where((sector) => sector.isNotEmpty)
        .toSet();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: HomePalette.deepText.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Composição',
                style: TextStyle(
                  color: HomePalette.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(Icons.pie_chart_outline_rounded, color: HomePalette.brandPink),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'SETORES',
                            style: TextStyle(
                              fontSize: 10,
                              color: HomePalette.mutedText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${sectors.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              color: HomePalette.deepText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 16,
                        color: colorHealthtech,
                      ),
                    ),
                    const SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 16,
                        color: colorAgrotech,
                      ),
                    ),
                    const SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 0.45,
                        strokeWidth: 16,
                        color: colorFintech,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: colorFintech, title: 'FINTECH', value: '--'),
                    SizedBox(height: 12),
                    _LegendItem(color: colorAgrotech, title: 'AGROTECH', value: '--'),
                    SizedBox(height: 12),
                    _LegendItem(color: colorHealthtech, title: 'HEALTHTECH', value: '--'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricaCard(
            icon: Icons.trending_up_rounded,
            title: 'RENTABILIDADE',
            value: controller.estimatedReturnPercent == null
                ? '--'
                : '${controller.estimatedReturnPercent!.toStringAsFixed(1).replaceAll('.', ',')}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricaCard(
            icon: Icons.savings_outlined,
            title: 'INVESTIDO',
            value: controller.investedBalance == null
                ? 'R\$ --'
                : controller.formatCurrencyAmount(controller.investedBalance!),
            iconColor: HomePalette.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricaCard({
    required IconData icon,
    required String title,
    required String value,
    Color iconColor = HomePalette.brandPink,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: HomePalette.deepText.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: HomePalette.mutedText,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: HomePalette.deepText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaInvestimentos() {
    final tokens = controller.walletTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Seus Investimentos',
              style: TextStyle(
                fontSize: 22,
                color: HomePalette.deepText,
                fontWeight: FontWeight.w900,
              ),
            ),
            GestureDetector(
              onTap: () => Modular.to.pushNamed(AppRoutes.allInvestments),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 13,
                  color: HomePalette.brandPink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (controller.isWalletLoading && tokens.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: CircularProgressIndicator(color: HomePalette.brandPink),
            ),
          )
        else if (tokens.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Você ainda não possui tokens.',
              style: TextStyle(
                color: HomePalette.mutedText.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ...tokens.map(_buildTokenTile),
      ],
    );
  }

  Widget _buildTokenTile(Map<String, dynamic> token) {
    final startupId = (token['startupId'] ?? '').toString().trim();
    final startup = _findStartupById(startupId);
    final sector = _sectorForToken(token);
    final name = (token['startupName'] ?? startup?['name'] ?? startupId).toString();
    final quantity = _asInt(token['quantity']);
    final averagePrice = _asDouble(token['averagePrice']);
    final currentPrice = _calculateTokenPrice(startup);
    final returnPercent = (averagePrice > 0 && currentPrice > 0)
        ? ((currentPrice / averagePrice) - 1) * 100
        : 0.0;

    final totalValue = quantity * (currentPrice > 0 ? currentPrice : averagePrice);

    final rendimentoNeutro = returnPercent.abs() <= 0.05;
    final rendimentoNegativo = returnPercent < -0.05;

    return _buildInvestimentoTile(
      icon: _iconForSector(sector),
      nome: name,
      subtitulo: '${sector.toUpperCase()} • $quantity TOKENS',
      valor: controller.formatCurrencyAmount(totalValue),
      rendimento:
          '${returnPercent >= 0 ? '+' : ''}${returnPercent.toStringAsFixed(1).replaceAll('.', ',')}%',
      rendimentoNegativo: rendimentoNegativo,
      rendimentoNeutro: rendimentoNeutro,
      onComprar: () => _openTransaction(startupId, TransactionType.buy),
      onVender: () => _openTransaction(startupId, TransactionType.sell),
    );
  }

  Widget _buildInvestimentoTile({
    required IconData icon,
    required String nome,
    required String subtitulo,
    required String valor,
    required String rendimento,
    required VoidCallback onComprar,
    required VoidCallback onVender,
    bool rendimentoNegativo = false,
    bool rendimentoNeutro = false,
  }) {
    Color corRendimento = HomePalette.brandPink;
    if (rendimentoNegativo) corRendimento = const Color(0xFFD93B3B);
    if (rendimentoNeutro) corRendimento = HomePalette.mutedText;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: HomePalette.deepText.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: HomePalette.deepText, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: HomePalette.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: HomePalette.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onVender,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HomePalette.brandPink,
                          side: BorderSide(
                            color: HomePalette.brandPink.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Vender',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onComprar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomePalette.brandPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Comprar',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  color: HomePalette.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rendimento,
                style: TextStyle(
                  color: corRendimento,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openTransaction(String startupId, TransactionType type) {
    if (startupId.isEmpty) return;
    Modular.to.pushNamed(
      AppRoutes.transactionPage,
      arguments: {
        'type': type,
        'id': startupId,
      },
    );
  }

  String _sectorForToken(Map<String, dynamic> token) {
    final startupId = (token['startupId'] ?? '').toString().trim();
    final startup = _findStartupById(startupId);
    return (startup?['sector'] ?? '').toString();
  }

  Map<String, dynamic>? _findStartupById(String startupId) {
    if (startupId.isEmpty) return null;
    for (final startup in controller.allStartups) {
      final id = (startup['id'] ?? '').toString().trim();
      if (id == startupId) return startup;
    }
    return null;
  }

  double _calculateTokenPrice(Map<String, dynamic>? startup) {
    if (startup == null) return 0.0;
    final emittedTokens = _asDouble(startup['totalEmittedTokens']);
    final targetCapital = _asDouble(startup['targetCapital']);

    if (emittedTokens > 0 && targetCapital > 0) {
      final price = targetCapital / emittedTokens;
      if (price.isFinite && price > 0) {
        return price;
      }
    }

    return 0.0;
  }

  IconData _iconForSector(String sector) {
    final normalized = sector.trim().toLowerCase();
    if (normalized.contains('agro')) return Icons.agriculture_rounded;
    if (normalized.contains('health')) return Icons.health_and_safety_outlined;
    if (normalized.contains('fin')) return Icons.account_balance_rounded;
    return Icons.business_center_outlined;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _LegendItem({
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: HomePalette.mutedText,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: HomePalette.deepText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
