// Abdallah El-Khatib

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({required this.controller, super.key});

  final HomeController controller;

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  final List<_PortfolioPeriod> _periods = const [
    _PortfolioPeriod('DIA', 'daily'),
    _PortfolioPeriod('SEM', 'weekly'),
    _PortfolioPeriod('MES', 'monthly'),
    _PortfolioPeriod('6M', '6months'),
    _PortfolioPeriod('YTD', 'ytd'),
  ];

  int _selectedPeriod = 2;
  bool _isChartLoading = true;
  String? _chartError;
  List<_PortfolioPoint> _points = [];

  @override
  void initState() {
    super.initState();
    _loadPortfolioHistory();
  }

  Future<void> _loadPortfolioHistory() async {
    setState(() {
      _isChartLoading = true;
      _chartError = null;
    });

    try {
      final result = await _functions.httpsCallable('getPortfolioHistory').call(
        {'period': _periods[_selectedPeriod].value},
      );
      final raw = result.data;
      final data = raw is Map && raw['data'] is List
          ? raw['data'] as List
          : <dynamic>[];
      final points = data
          .whereType<Map>()
          .map(
            (item) => _PortfolioPoint.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((point) => point.totalValue >= 0)
          .toList();

      if (!mounted) return;
      setState(() {
        _points = points;
        _isChartLoading = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _chartError = e.message ?? 'Nao foi possivel carregar o grafico.';
        _isChartLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _chartError = 'Erro inesperado ao carregar o grafico.';
        _isChartLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatrimonioHero(),
        const SizedBox(height: 18),
        _buildPerformanceCard(),
        const SizedBox(height: 14),
        _buildMetricasRow(),
        const SizedBox(height: 22),
        _buildListaInvestimentos(),
      ],
    );
  }

  Widget _buildPatrimonioHero() {
    final wallet = widget.controller.wallet ?? {};
    final total = _asDouble(wallet['portfolioTotal']) > 0
        ? _asDouble(wallet['portfolioTotal'])
        : widget.controller.availableBalance +
              _asDouble(wallet['totalCurrentValue']);
    final returnPercent = _asDouble(wallet['totalProfitLossPercent']);
    final returnLabel =
        '${returnPercent >= 0 ? '+' : ''}${returnPercent.toStringAsFixed(1).replaceAll('.', ',')}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PATRIMONIO TOTAL',
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
            Expanded(
              child: Text(
                widget.controller.isBalanceVisible
                    ? widget.controller.formatCurrencyAmount(total)
                    : 'R\$ ******',
                style: const TextStyle(
                  color: HomePalette.deepText,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                returnLabel,
                style: TextStyle(
                  color: returnPercent >= 0
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFD93B3B),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                widget.controller.isBalanceVisible
                    ? Icons.remove_red_eye_outlined
                    : Icons.visibility_off_outlined,
                color: HomePalette.deepText,
              ),
              onPressed: widget.controller.toggleBalanceVisibility,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
                'Performance',
                style: TextStyle(
                  color: HomePalette.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(Icons.show_chart_rounded, color: HomePalette.brandPink),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(height: 178, child: _buildChartBody()),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_periods.length, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _PeriodChip(
                    label: _periods[index].label,
                    selected: _selectedPeriod == index,
                    onTap: () {
                      setState(() => _selectedPeriod = index);
                      _loadPortfolioHistory();
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBody() {
    if (_isChartLoading) {
      return const Center(
        child: CircularProgressIndicator(color: HomePalette.brandPink),
      );
    }

    if (_chartError != null) {
      return Center(
        child: Text(
          _chartError!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: HomePalette.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_points.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de portfolio para o periodo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: HomePalette.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final spots = List.generate(
      _points.length,
      (index) => FlSpot(index.toDouble(), _points[index].totalValue),
    );
    final values = _points.map((point) => point.totalValue).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final verticalPadding = (maxValue - minValue).abs() < 1
        ? 10.0
        : (maxValue - minValue) * 0.16;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: (minValue - verticalPadding).clamp(0, double.infinity).toDouble(),
        maxY: maxValue + verticalPadding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxValue - minValue).abs() <= 1
              ? 10
              : (maxValue - minValue) / 4,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFEDE5F6), strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(12),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final point = _points[spot.x.toInt()];
                return LineTooltipItem(
                  '${widget.controller.formatCurrencyAmount(point.totalValue)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: point.shortDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: HomePalette.brandPink,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: HomePalette.brandPink.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasRow() {
    final wallet = widget.controller.wallet ?? {};

    return Row(
      children: [
        Expanded(
          child: _MetricaCard(
            icon: Icons.trending_up_rounded,
            title: 'RENTABILIDADE',
            value:
                '${_asDouble(wallet['totalProfitLossPercent']).toStringAsFixed(1).replaceAll('.', ',')}%',
            iconColor: HomePalette.brandPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricaCard(
            icon: Icons.savings_outlined,
            title: 'INVESTIDO',
            value: widget.controller.formatCurrencyAmount(
              _asDouble(wallet['totalInvested']),
            ),
            iconColor: HomePalette.deepText,
          ),
        ),
      ],
    );
  }

  Widget _buildListaInvestimentos() {
    final tokens = widget.controller.walletTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        const SizedBox(height: 16),
        if (widget.controller.isWalletLoading && tokens.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: HomePalette.brandPink),
            ),
          )
        else if (tokens.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Voce ainda nao possui tokens.',
              style: TextStyle(
                color: HomePalette.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ...tokens.take(4).map(_buildTokenTile),
      ],
    );
  }

  Widget _buildTokenTile(Map<String, dynamic> token) {
    final startupId = (token['startupId'] ?? '').toString().trim();
    final startup = _findStartupById(startupId);
    final sector = (startup?['sector'] ?? '').toString();
    final name = (token['startupName'] ?? startup?['name'] ?? startupId)
        .toString();
    final quantity = _asInt(token['quantity']);
    final currentValue = _asDouble(token['currentValue']) > 0
        ? _asDouble(token['currentValue'])
        : quantity * _calculateTokenPrice(startup);
    final profitPercent = _asDouble(token['profitLossPercent']);
    final isNegative = profitPercent < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HomePalette.deepText.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EEF7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_iconForSector(sector), color: HomePalette.deepText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomePalette.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sector.toUpperCase()} - $quantity TOKENS',
                  style: const TextStyle(
                    color: HomePalette.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _openTransaction(startupId, TransactionType.sell),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HomePalette.brandPink,
                          side: BorderSide(
                            color: HomePalette.brandPink.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: const Text('Vender'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _openTransaction(startupId, TransactionType.buy),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomePalette.brandPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text('Comprar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.controller.formatCurrencyAmount(currentValue),
                style: const TextStyle(
                  color: HomePalette.deepText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(1).replaceAll('.', ',')}%',
                style: TextStyle(
                  color: isNegative
                      ? const Color(0xFFD93B3B)
                      : const Color(0xFF27AE60),
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
      arguments: {'type': type, 'id': startupId},
    );
  }

  Map<String, dynamic>? _findStartupById(String startupId) {
    for (final startup in widget.controller.allStartups) {
      if ((startup['id'] ?? '').toString() == startupId) return startup;
    }
    return null;
  }

  double _calculateTokenPrice(Map<String, dynamic>? startup) {
    if (startup == null) return 0;
    final raw = startup['raw'];
    final data = raw is Map ? Map<String, dynamic>.from(raw) : startup;
    final directPrice = _asDouble(
      data['tokenPrice'] ?? data['unitPrice'] ?? data['valorToken'],
    );

    if (directPrice > 0) return directPrice;

    final emittedTokens = _asDouble(data['totalEmittedTokens']);
    final targetCapital = _asDouble(data['targetCapital']);

    if (emittedTokens > 0 && targetCapital > 0) {
      return targetCapital / emittedTokens;
    }

    return 0;
  }

  IconData _iconForSector(String sector) {
    final normalized = sector.toLowerCase();
    if (normalized.contains('agro')) return Icons.agriculture_rounded;
    if (normalized.contains('health')) return Icons.health_and_safety_outlined;
    if (normalized.contains('fin')) return Icons.account_balance_rounded;
    if (normalized.contains('edu')) return Icons.school_outlined;
    return Icons.business_center_outlined;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _PortfolioPeriod {
  const _PortfolioPeriod(this.label, this.value);

  final String label;
  final String value;
}

class _PortfolioPoint {
  const _PortfolioPoint({required this.timestamp, required this.totalValue});

  final DateTime timestamp;
  final double totalValue;

  String get shortDate =>
      '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';

  factory _PortfolioPoint.fromMap(Map<String, dynamic> map) {
    return _PortfolioPoint(
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      totalValue: map['totalValue'] is num
          ? (map['totalValue'] as num).toDouble()
          : double.tryParse(map['totalValue']?.toString() ?? '') ?? 0,
    );
  }
}

class _MetricaCard extends StatelessWidget {
  const _MetricaCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: HomePalette.deepText.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: HomePalette.mutedText,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              color: HomePalette.deepText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? HomePalette.activeNavBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              color: selected ? HomePalette.brandPink : HomePalette.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
