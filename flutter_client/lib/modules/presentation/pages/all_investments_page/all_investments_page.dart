import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/filter_chip.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AllInvestmentsPage extends StatefulWidget {
  const AllInvestmentsPage({super.key});

  @override
  State<AllInvestmentsPage> createState() => _AllInvestmentsPageState();
}

class _AllInvestmentsPageState extends State<AllInvestmentsPage> {
  static const Color deepText = Color(0xFF241B60);

  final HomeController controller = Modular.get<HomeController>();

  String _selectedFilter = 'TODOS';

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
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

  @override
  Widget build(BuildContext context) {
    final tokens = controller.walletTokens;

    final sectors =
        tokens
            .map((token) => _sectorForToken(token).trim())
            .where((sector) => sector.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final filters = <String>['TODOS', ...sectors.map((s) => s.toUpperCase())];

    final filtered = tokens.where((token) {
      if (_selectedFilter == 'TODOS') return true;
      final sector = _sectorForToken(token).toUpperCase();
      return sector == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: HomePalette.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: deepText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomFilterChip(
                    label: filter,
                    isActive: isActive,
                    onTap: () => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Builder(
              builder: (_) {
                if (controller.isWalletLoading && tokens.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: HomePalette.brandPink,
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum investimento encontrado.',
                      style: TextStyle(
                        color: deepText.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    ...filtered.map((token) => _buildInvestmentCard(token)),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(Map<String, dynamic> token) {
    final startupId = (token['startupId'] ?? '').toString().trim();
    final startup = _findStartupById(startupId);
    final sector = _sectorForToken(token);
    final stage = (startup?['stage'] ?? '').toString().replaceAll('_', ' ');
    final name = (token['startupName'] ?? startup?['name'] ?? startupId)
        .toString();

    final quantity = _asInt(token['quantity']);
    final averagePrice = _asDouble(token['averagePrice']);
    final currentPrice = _calculateTokenPrice(startup);

    final totalValue = _asDouble(token['currentValue']) > 0
        ? _asDouble(token['currentValue'])
        : quantity * (currentPrice > 0 ? currentPrice : averagePrice);
    final returnPercent = _asDouble(token['profitLossPercent']);

    final isPositive = returnPercent >= 0;
    final rendimento = _formatPercent(returnPercent);

    return _InvestmentCard(
      logoText: sector.isNotEmpty ? sector.substring(0, 1).toUpperCase() : 'T',
      nome: name,
      setor: sector.isEmpty ? 'TOKENS' : sector.toUpperCase(),
      ticker: stage.isEmpty
          ? '$quantity TOKENS'
          : '${stage.toUpperCase()} • $quantity TOKENS',
      valor: controller.formatCurrencyAmount(totalValue),
      rendimento: rendimento,
      isPositive: isPositive,
      onComprar: () => _openTransaction(startupId, TransactionType.buy),
      onVender: () => _openTransaction(startupId, TransactionType.sell),
    );
  }

  void _openTransaction(String startupId, TransactionType type) {
    if (startupId.isEmpty) return;
    Modular.to.pushNamed(
      AppRoutes.transactionPage,
      arguments: {'type': type, 'id': startupId},
    );
  }

  Map<String, dynamic>? _findStartupById(String startupId) {
    if (startupId.isEmpty) return null;
    for (final startup in controller.allStartups) {
      final id = (startup['id'] ?? '').toString().trim();
      if (id == startupId) return startup;
    }
    return null;
  }

  String _sectorForToken(Map<String, dynamic> token) {
    final startupId = (token['startupId'] ?? '').toString().trim();
    final startup = _findStartupById(startupId);
    return (startup?['sector'] ?? '').toString();
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

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPercent(double value) {
    if (!value.isFinite || value.abs() > 1000) {
      return '--';
    }

    final normalized = value.toStringAsFixed(2).replaceAll('.', ',');
    return '${value >= 0 ? '+' : ''}$normalized%';
  }
}

class _InvestmentCard extends StatelessWidget {
  final String logoText;
  final String nome;
  final String setor;
  final String ticker;
  final String valor;
  final String rendimento;
  final bool isPositive;
  final VoidCallback onComprar;
  final VoidCallback onVender;

  const _InvestmentCard({
    required this.logoText,
    required this.nome,
    required this.setor,
    required this.ticker,
    required this.valor,
    required this.rendimento,
    required this.isPositive,
    required this.onComprar,
    required this.onVender,
  });

  @override
  Widget build(BuildContext context) {
    final Color trendColor = isPositive
        ? const Color(0xFF27AE60)
        : const Color(0xFFD93B3B);
    final IconData trendIcon = isPositive
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    const Color deepText = Color(0xFF241B60);
    const Color mutedText = Color(0xFF756E93);
    const Color brandPink = Color(0xFFD4147A);
    const Color panelBackground = Color(0xFFF4EEFB);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: deepText.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: deepText,
                ),
                alignment: Alignment.center,
                child: Text(
                  logoText.isNotEmpty ? logoText.substring(0, 1) : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepText,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$setor • $ticker',
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 112),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      valor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepText,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(trendIcon, color: trendColor, size: 12),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            rendimento,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: trendColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
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
          const SizedBox(height: 24),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onComprar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'COMPRAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onVender,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandPink,
                    side: const BorderSide(color: panelBackground, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'VENDER',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
