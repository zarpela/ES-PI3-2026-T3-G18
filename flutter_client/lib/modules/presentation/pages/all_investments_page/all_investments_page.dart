import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/filter_chip.dart';


class AllInvestmentsPage extends StatefulWidget {
  const AllInvestmentsPage({super.key});

  @override
  State<AllInvestmentsPage> createState() => _AllInvestmentsPageState();
}

class _AllInvestmentsPageState extends State<AllInvestmentsPage> {
  static const Color deepText = Color(0xFF241B60);
  static const Color mutedText = Color(0xFF756E93);
  static const Color brandPink = Color(0xFFD4147A);
  static const Color pageBackground = Color(0xFFFCF9FF);
  static const Color panelBackground = Color(0xFFF4EEFB);
  static const Color softYellow = Color(0xFFFFDE74);
  static const Color greenTrend = Color(0xFF27AE60);
  static const Color redTrend = Color(0xFFD93B3B);

  String _selectedFilter = 'TODOS'; //TODO: trocar pelo selecionado no controller;

  final List<String> _filters = ['TODOS', 'AÇÕES', 'FIIS', 'CRIPTO'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
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
              children: _filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomFilterChip(
                    label: filter,
                    isActive: isActive,
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    softYellow: softYellow,
                    mutedText: mutedText,
                    panelBackground: panelBackground, 
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _InvestmentCard(
                  logoText: 'FINTECH',
                  nome: 'NuBank S.A.',
                  setor: 'FINTECH',
                  ticker: 'NUBR33',
                  valor: 'R\$ 42.400',
                  rendimento: '+12,5%',
                  isPositive: true,
                  onComprar: () {},
                  onVender: () {},
                ),
                _InvestmentCard(
                  logoText: 'AGRO',
                  nome: 'AgroMais',
                  setor: 'AGROTECH',
                  ticker: 'AGRO3',
                  valor: 'R\$ 18.250',
                  rendimento: '-2,4%',
                  isPositive: false,
                  onComprar: () {},
                  onVender: () {},
                ),
                _InvestmentCard(
                  logoText: 'HEALTH',
                  nome: 'LifeCare App',
                  setor: 'HEALTHTECH',
                  ticker: 'LIFE3',
                  valor: 'R\$ 31.900',
                  rendimento: '+5,8%',
                  isPositive: true,
                  onComprar: () {},
                  onVender: () {},
                ),
                const SizedBox(height: 100), 
              ],
            ),
          ),
        ],
      ),
    );
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
    final Color trendColor = isPositive ? const Color(0xFF27AE60) : const Color(0xFFD93B3B);
    final IconData trendIcon = isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
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
            color: deepText.withOpacity(0.04),
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
                  logoText.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        color: deepText,
                        fontSize: 18,
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    valor,
                    style: const TextStyle(
                      color: deepText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(trendIcon, color: trendColor, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        rendimento,
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
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
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}