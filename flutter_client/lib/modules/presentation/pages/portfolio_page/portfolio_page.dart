import 'package:flutter/material.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  static const Color deepText = Color(0xFF241B60);
  static const Color mutedText = Color(0xFF756E93);
  static const Color brandPink = Color(0xFFD4147A);
  static const Color pageBackground = Color(0xFFFCF9FF);
  static const Color cardBackground = Colors.white;
  static const Color softSurface = Color(0xFFF3EDF8);
  static const Color divider = Color(0xFFE7DFF0);
  static const Color green = Color(0xFF27AE60);
  static const Color red = Color(0xFFD93B3B);
  static const Color neutral = Color(0xFF7D718F);

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  int selectedPeriod = 2;
  int? touchedIndex;

  final periods = const ['DIA', 'SEM', 'MÊS', 'SEMESTRE', 'YTD'];

  final spotsRed = const [
    FlSpot(0, 62),
    FlSpot(1, 58),
    FlSpot(2, 50),
    FlSpot(3, 55),
    FlSpot(4, 63),
    FlSpot(5, 71),
    FlSpot(6, 78),
  ];

  final spotsGreen = const [
    FlSpot(2, 50),
    FlSpot(3, 55),
    FlSpot(4, 63),
    FlSpot(5, 71),
    FlSpot(6, 78),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PortfolioView.pageBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildPatrimonioHero(),
            const SizedBox(height: 16),
            _buildPerformanceCard(),
            const SizedBox(height: 14),
            _buildMetricasRow(),
            const SizedBox(height: 18),
            _buildListaInvestimentos(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFF241B60),
          child: Icon(Icons.person, size: 16, color: Colors.white),
        ),
        const Spacer(),
        const Text(
          'MesclaInvest',
          style: TextStyle(
            color: PortfolioView.brandPink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: PortfolioView.deepText,
          ),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPatrimonioHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PATRIMÔNIO TOTAL',
          style: TextStyle(
            color: PortfolioView.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              'R\$ 142.580,00',
              style: TextStyle(
                color: PortfolioView.deepText,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                '+2,4%',
                style: TextStyle(
                  color: PortfolioView.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PortfolioView.cardBackground,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: PortfolioView.deepText.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Performance',
                style: TextStyle(
                  color: PortfolioView.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(Icons.trending_up_rounded, color: PortfolioView.green),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 185,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 35,
                maxY: 85,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Color(0xFFEDE5F6), strokeWidth: 1),
                  getDrawingVerticalLine: (value) =>
                      const FlLine(color: Color(0xFFF2EDF8), strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchSpotThreshold: 20,
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        const FlLine(color: Colors.transparent, strokeWidth: 0),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: barData.color!,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(14),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    tooltipMargin: 12,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isGreen = spot.barIndex == 1;
                        return LineTooltipItem(
                          'R\$ ${spot.y.toStringAsFixed(0)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: isGreen ? 'Linha positiva' : 'Linha base',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      touchedIndex = response?.lineBarSpots?.isNotEmpty == true
                          ? response!.lineBarSpots!.first.spotIndex
                          : null;
                    });
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsRed,
                    isCurved: true,
                    color: PortfolioView.red,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: spotsGreen,
                    isCurved: true,
                    color: PortfolioView.green,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(periods.length, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _PeriodChip(
                    label: periods[index],
                    selected: selectedPeriod == index,
                    onTap: () {
                      setState(() {
                        selectedPeriod = index;
                      });
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

  Widget _buildMetricasRow() {
    return Row(
      children: const [
        Expanded(
          child: _MetricaCard(
            icon: Icons.trending_up_rounded,
            title: 'RENTABILIDADE',
            value: '+18,4%',
            iconColor: PortfolioView.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricaCard(
            icon: Icons.calendar_month_outlined,
            title: 'PROVENTOS',
            value: 'R\$ 840',
            iconColor: PortfolioView.deepText,
          ),
        ),
      ],
    );
  }

  Widget _buildListaInvestimentos() {
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
                color: PortfolioView.deepText,
                fontWeight: FontWeight.w900,
              ),
            ),
            GestureDetector(
              onTap: () {
                Modular.to.pushNamed(AppRoutes.allInvestments);
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 13,
                  color: PortfolioView.brandPink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildInvestimentoTile(
          icon: Icons.account_balance_rounded,
          nome: 'Vitality.',
          subtitulo: 'HEALTHTECH • 120 COTAS',
          valor: 'R\$ 42.400',
          rendimento: '+12,5%',
          rendimentoColor: PortfolioView.green,
        ),
        _buildInvestimentoTile(
          icon: Icons.agriculture_rounded,
          nome: 'AgroMais',
          subtitulo: 'AGROTECH • 45 COTAS',
          valor: 'R\$ 35.680',
          rendimento: '+8,2%',
          rendimentoColor: const Color(0xFF8C7311),
        ),
        _buildInvestimentoTile(
          icon: Icons.medical_services_outlined,
          nome: 'Locus.ai',
          subtitulo: 'AI • 80 COTAS',
          valor: 'R\$ 42.750',
          rendimento: '0,0%',
          rendimentoColor: PortfolioView.mutedText,
        ),
        _buildInvestimentoTile(
          icon: Icons.credit_card_rounded,
          nome: 'StudyFlow',
          subtitulo: 'EDTECH • 15 COTAS',
          valor: 'R\$ 21.750',
          rendimento: '-2,1%',
          rendimentoColor: PortfolioView.red,
        ),
      ],
    );
  }

  Widget _buildInvestimentoTile({
    required IconData icon,
    required String nome,
    required String subtitulo,
    required String valor,
    required String rendimento,
    required Color rendimentoColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PortfolioView.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PortfolioView.deepText.withValues(alpha: 0.03),
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
            child: Icon(icon, color: PortfolioView.deepText, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    color: PortfolioView.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: PortfolioView.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  color: PortfolioView.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rendimento,
                style: TextStyle(
                  color: rendimentoColor,
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
}

class _MetricaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _MetricaCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: PortfolioView.deepText.withValues(alpha: 0.03),
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
              color: PortfolioView.mutedText,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              color: PortfolioView.deepText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
            color: selected ? PortfolioView.softSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              color: selected
                  ? PortfolioView.brandPink
                  : PortfolioView.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
