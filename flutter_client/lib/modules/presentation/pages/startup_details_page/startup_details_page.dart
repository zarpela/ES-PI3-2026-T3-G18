import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class StartupDetailsPage extends StatelessWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({super.key, required this.startup});

  static const Color bg = Color(0xFFF7F3FA);
  static const Color surface = Color(0xFFF2ECF8);
  static const Color surfaceStrong = Colors.white;
  static const Color text = Color(0xFF2E2340);
  static const Color textMuted = Color(0xFF7D718F);
  static const Color textLight = Color(0xFF9B90AA);
  static const Color primary = Color(0xFFC2187A);
  static const Color chipBg = Color(0xFFF1E9F8);
  static const Color divider = Color(0xFFE7DFF0);

  @override
  Widget build(BuildContext context) {
    final sector = '${startup['sector'] ?? ''}';
    final image = _imageBySector(sector);
    final name = '${startup['name'] ?? 'Startup'}';
    final description = '${startup['description'] ?? 'Sem descrição'}';
    final stage = '${startup['stage'] ?? 'Não informado'}';
    final raised = _formatRaised('${startup['raised'] ?? ''}');
    final roi = '${startup['roi'] ?? 'Não informado'}';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 14),
                _buildHeroCard(image: image, name: name, sector: sector),
                const SizedBox(height: 18),
                _buildMetricsRow(raised: raised, stage: stage),
                const SizedBox(height: 22),
                _buildHeadline(name, description),
                const SizedBox(height: 18),
                _buildSummaryCard(description),
                const SizedBox(height: 24),
                _buildSectionKicker('SÓCIOS E FUNDADORES'),
                const SizedBox(height: 10),
                _buildFounderCard(
                  name: 'Dr. Ricardo\nLemos',
                  role: 'CEO & Fundador',
                  percent: '42%',
                  description:
                      'Doutor pelo MIT com mais de 15 anos de experiência em gestão de recursos hídricos e inovação tecnológica sustentável.',
                ),
                const SizedBox(height: 12),
                _buildFounderCard(
                  name: 'Dra. Beatriz\nSantos',
                  role: 'CTO',
                  percent: '18%',
                  description:
                      'Especialista em Inteligência Artificial e IoT, liderou o desenvolvimento de sistemas críticos para a indústria aeroespacial antes da EcoFlow.',
                ),
                const SizedBox(height: 22),
                _buildSectionKicker('CONSELHO CONSULTIVO'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniAdvisorCard(
                        name: 'Marcus Vale',
                        role: 'Estrategista ESG',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniAdvisorCard(
                        name: 'Helena Rocha',
                        role: 'Investimentos Venture\nCapital',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildSectionKicker('DEMONSTRAÇÃO DA TECNOLOGIA'),
                const SizedBox(height: 10),
                _buildDemoCard(image),
                const SizedBox(height: 22),
                _buildQuestionsHeader(),
                const SizedBox(height: 10),
                _buildPublicQuestionCard(),
                const SizedBox(height: 12),
                _buildPrivateQuestionCard(),
                const SizedBox(height: 8),
              ],
            ),
            _buildBottomBar(context, name),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: text,
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            'MesclaInvest',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.share_outlined, size: 18, color: text),
          const SizedBox(width: 14),
          const Icon(Icons.notifications_none_rounded, size: 20, color: text),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String image,
    required String name,
    required String sector,
  }) {
    return SizedBox(
      height: 172,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceStrong,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE5F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _sectorLabel(sector),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow({required String raised, required String stage}) {
    return Row(
      children: [
        Expanded(
          child: _metricItem('CAPTAÇÃO\nTOTAL', raised, valueColor: primary),
        ),
        Expanded(
          child: _metricItem(
            'TOKENS\nEMITIDOS',
            _tokenAmountByStage(stage),
            valueColor: primary,
          ),
        ),
        Expanded(
          child: _metricItem(
            'ESTÁGIO',
            _formatStageForMetric(stage),
            valueColor: primary,
          ),
        ),
      ],
    );
  }

  Widget _metricItem(String label, String value, {Color valueColor = text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: divider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: textLight,
              letterSpacing: 0.7,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(String name, String description) {
    return Text(
      _headlineFromStartup(name, description),
      style: const TextStyle(
        fontSize: 16,
        height: 1.28,
        fontWeight: FontWeight.w800,
        color: text,
      ),
    );
  }

  Widget _buildSummaryCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUMÁRIO EXECUTIVO',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _executiveSummary(description),
            style: const TextStyle(fontSize: 13, height: 1.6, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionKicker(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: textLight,
        letterSpacing: 1.3,
      ),
    );
  }

  Widget _buildFounderCard({
    required String name,
    required String role,
    required String percent,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ),
              Text(
                percent,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              height: 1.55,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAdvisorCard({required String name, required String role}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              fontSize: 9.5,
              height: 1.45,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard(String image) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.22),
              Colors.black.withOpacity(0.38),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const Positioned(
              left: 14,
              bottom: 22,
              child: Text(
                'Pitch Deck & Demo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 14,
              bottom: 10,
              child: Text(
                '05:43 min',
                style: TextStyle(fontSize: 9, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsHeader() {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'DÚVIDAS E PERGUNTAS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textLight,
              letterSpacing: 1.3,
            ),
          ),
        ),
        Text(
          '+ Perguntar',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPublicQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.public, size: 12, color: primary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'PÚBLICA',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Text(
                '12/10/2023',
                style: TextStyle(fontSize: 8.5, color: textLight),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Qual a projeção de dividendos para este ano?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Por investor1@gmail.com',
            style: TextStyle(fontSize: 9, color: textMuted),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F3FB),
              borderRadius: BorderRadius.circular(14),
              border: const Border(left: BorderSide(color: primary, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'RESPOSTA DA EQUIPE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: primary,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    Text(
                      '15/10/2023',
                      style: TextStyle(fontSize: 8.5, color: textLight),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Projetamos um yield de 4-6% com base no crescimento dos contratos atuais e na otimização da planta piloto.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.55,
                    color: textMuted,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Responder: team@startup.com',
                  style: TextStyle(fontSize: 8.5, color: textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_outline_rounded, size: 12, color: textMuted),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'PRIVADA',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: textMuted,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Text(
                '10/10/2023',
                style: TextStyle(fontSize: 8.5, color: textLight),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Conteúdo Restrito',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Por vip@personal.com',
            style: TextStyle(fontSize: 9, color: textMuted),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, size: 16, color: textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta pergunta e sua resposta são visíveis apenas para investidores.',
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.4,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, String name) {
    final String startupId = startup['id']?.toString() ?? '';
    return Positioned(
      left: 12,
      right: 12,
      bottom: 14,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF8),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Modular.to.pushNamed(AppRoutes.transactionPage, arguments: 
                      {
                        "type" :TransactionType.sell,
                        "id": startupId,
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFE9E1F3),
                    foregroundColor: text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Vender',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Modular.to.pushNamed(AppRoutes.transactionPage, arguments: 
                      {
                        "type" :TransactionType.buy,
                        "id": startupId,
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text(
                    'Comprar Tokens',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sectorLabel(String sector) {
    switch (sector.toLowerCase()) {
      case 'fintech':
        return 'Fintech';
      case 'agtech':
      case 'agrotech':
        return 'Agrotech';
      case 'healthtech':
      case 'health':
        return 'HealthTech';
      case 'edtech':
        return 'EdTech';
      default:
        return 'Startup';
    }
  }

  String _imageBySector(String sector) {
    switch (sector.toLowerCase()) {
      case 'fintech':
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=1200&auto=format&fit=crop';
      case 'agtech':
      case 'agrotech':
        return 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1200&auto=format&fit=crop';
      case 'healthtech':
      case 'health':
        return 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=1200&auto=format&fit=crop';
      case 'edtech':
        return 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1200&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1200&auto=format&fit=crop';
    }
  }

  String _formatRaised(String value) {
    if (value.trim().isEmpty) return 'R\$ 0';
    return value.contains('R\$') ? value : 'R\$ $value';
  }

  String _formatStageForMetric(String stage) {
    final lower = stage.toLowerCase();

    if (lower.contains('nova') || lower.contains('seed')) {
      return 'Nova';
    }
    if (lower.contains('operação') ||
        lower.contains('operacao') ||
        lower.contains('series a')) {
      return 'Em\nOperação';
    }
    if (lower.contains('expansão') ||
        lower.contains('expansao') ||
        lower.contains('series b')) {
      return 'Em\nExpansão';
    }
    return stage;
  }

  String _tokenAmountByStage(String stage) {
    final lower = stage.toLowerCase();

    if (lower.contains('nova') || lower.contains('seed')) {
      return '350.000';
    }
    if (lower.contains('operação') ||
        lower.contains('operacao') ||
        lower.contains('series a')) {
      return '1.250.000';
    }
    if (lower.contains('expansão') ||
        lower.contains('expansao') ||
        lower.contains('series b')) {
      return '2.400.000';
    }
    return '500.000';
  }

  String _headlineFromStartup(String name, String description) {
    final lower = description.toLowerCase();

    if (lower.contains('água') || lower.contains('agua')) {
      return 'Transformando desperdício em eficiência através da IA.';
    }
    if (lower.contains('agric') || lower.contains('monitoramento')) {
      return 'Tecnologia aplicada ao campo para escalar produtividade.';
    }
    if (lower.contains('hardware') || lower.contains('tempo real')) {
      return 'Infraestrutura inteligente para decisões em tempo real.';
    }
    return 'Construindo uma operação escalável com base tecnológica robusta.';
  }

  String _executiveSummary(String description) {
    return '$description\n\nCom uma modelagem de crescimento orientada por dados, a startup projeta ganho de eficiência, expansão operacional e novas frentes de monetização nos próximos 24 meses.';
  }
}
