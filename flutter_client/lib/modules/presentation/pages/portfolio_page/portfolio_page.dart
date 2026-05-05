import 'package:flutter/material.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PortfolioView extends StatelessWidget {
  const PortfolioView({super.key});

  static const Color deepText = Color(0xFF241B60);
  static const Color mutedText = Color(0xFF756E93);
  static const Color brandPink = Color(0xFFD4147A);
  static const Color pageBackground = Color(0xFFFCF9FF);
  
  static const Color colorFintech = Color(0xFFD4147A);
  static const Color colorAgrotech = Color(0xFF8C7311);
  static const Color colorHealthtech = Color(0xFFAEB2FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatrimonioHero(),
        const SizedBox(height: 24),
        _buildComposicaoCard(),
        const SizedBox(height: 16),
        _buildMetricasRow(),
        const SizedBox(height: 32),
        _buildListaInvestimentos(),
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
            color: mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'R\$ ***.***,**',
              style: TextStyle(
                color: deepText,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                '+2,4%',
                style: TextStyle(
                  color: brandPink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, color: deepText),
              onPressed: () {}, 
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComposicaoCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Composição',
                style: TextStyle(
                  color: deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(Icons.pie_chart_outline_rounded, color: brandPink),
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
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SETORES', style: TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.bold)),
                          Text('3', style: TextStyle(fontSize: 24, color: deepText, fontWeight: FontWeight.w900)),
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
                    _LegendItem(color: colorFintech, title: 'FINTECH', value: '45%'),
                    SizedBox(height: 12),
                    _LegendItem(color: colorAgrotech, title: 'AGROTECH', value: '25%'),
                    SizedBox(height: 12),
                    _LegendItem(color: colorHealthtech, title: 'HEALTHTECH', value: '30%'),
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
            value: '+**,*%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricaCard(
            icon: Icons.calendar_month_outlined,
            title: 'PROVENTOS',
            value: 'R\$ ***',
            iconColor: mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricaCard({required IconData icon, required String title, required String value, Color iconColor = brandPink}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: deepText.withOpacity(0.03),
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
            style: const TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, color: deepText, fontWeight: FontWeight.w900),
          ),
        ],
      ),
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
            Text(
              'Seus Investimentos',
              style: TextStyle(fontSize: 22, color: deepText, fontWeight: FontWeight.w900),
            ),
            GestureDetector(
              onTap: () {
                Modular.to.pushNamed(AppRoutes.allInvestments); 
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(fontSize: 13, color: brandPink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInvestimentoTile(
          icon: Icons.account_balance_rounded,
          nome: 'Vitality.',
          subtitulo: 'HEALTHTECH • *** COTAS',
          valor: 'R\$ **.***',
          rendimento: '+**,*%',
        ),
        _buildInvestimentoTile(
          icon: Icons.agriculture_rounded,
          nome: 'AgroMais',
          subtitulo: 'AGROTECH • ** COTAS',
          valor: 'R\$ **.***',
          rendimento: '+*,*%',
        ),
        _buildInvestimentoTile(
          icon: Icons.medical_services_outlined,
          nome: 'Locus.ai',
          subtitulo: 'AI • ** COTAS',
          valor: 'R\$ **.***',
          rendimento: '0.0%',
          rendimentoNeutro: true,
        ),
        _buildInvestimentoTile(
          icon: Icons.credit_card_rounded,
          nome: 'StudyFlow',
          subtitulo: 'EDTECH • ** COTAS',
          valor: 'R\$ **.***',
          rendimento: '-*,*%',
          rendimentoNegativo: true,
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
    bool rendimentoNegativo = false,
    bool rendimentoNeutro = false,
  }) {
    Color corRendimento = brandPink;
    if (rendimentoNegativo) corRendimento = const Color(0xFFD93B3B);
    if (rendimentoNeutro) corRendimento = mutedText;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: deepText.withOpacity(0.03),
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
            child: Icon(icon, color: deepText, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(color: deepText, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitulo, style: const TextStyle(color: mutedText, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(valor, style: const TextStyle(color: deepText, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(rendimento, style: TextStyle(color: corRendimento, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _LegendItem({required this.color, required this.title, required this.value});

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
            Text(title, style: const TextStyle(fontSize: 10, color: PortfolioView.mutedText, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            Text(value, style: const TextStyle(fontSize: 14, color: PortfolioView.deepText, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}