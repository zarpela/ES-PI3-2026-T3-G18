import 'package:flutter/material.dart';

class StartupDetailsPage extends StatelessWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({
    super.key,
    required this.startup,
  });

  static const Color bg = Color(0xFFF7F3FA);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF2E2340);
  static const Color textMuted = Color(0xFF7D718F);
  static const Color primary = Color(0xFFC2187A);
  static const Color chipBg = Color(0xFFF3E8FF);

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: text,
        title: const Text(
          'Detalhes da startup',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(image),
            const SizedBox(height: 18),
            _buildHeader(name, sector),
            const SizedBox(height: 18),
            _buildInfoCards(
              stage: stage,
              raised: raised,
              roi: roi,
            ),
            const SizedBox(height: 18),
            _buildSectionTitle('Sobre a startup'),
            const SizedBox(height: 8),
            _buildTextCard(description),
            const SizedBox(height: 18),
            _buildSectionTitle('Resumo do investimento'),
            const SizedBox(height: 8),
            _buildInvestmentCard(
              raised: raised,
              stage: stage,
              roi: roi,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fluxo de investimento para $name em desenvolvimento.',
                      ),
                      backgroundColor: primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Investir agora',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(String image) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String sector) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            _sectorLabel(sector),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards({
    required String stage,
    required String raised,
    required String roi,
  }) {
    return Row(
      children: [
        Expanded(child: _infoCard('Estágio', stage)),
        const SizedBox(width: 10),
        Expanded(child: _infoCard('Captação', raised)),
        const SizedBox(width: 10),
        Expanded(child: _infoCard('Status', roi)),
      ],
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: text,
      ),
    );
  }

  Widget _buildTextCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: textMuted,
        ),
      ),
    );
  }

  Widget _buildInvestmentCard({
    required String raised,
    required String stage,
    required String roi,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações principais',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow('Total captado', raised),
          _detailRow('Estágio', stage),
          _detailRow('Status / ROI', roi),
          _detailRow('Ticket mínimo', _fakeTicketByStage(stage)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
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
        return 'Health';
      case 'edtech':
        return 'Edtech';
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

  String _fakeTicketByStage(String stage) {
    final lower = stage.toLowerCase();
    if (lower.contains('seed')) return 'R\$ 5.000';
    if (lower.contains('a')) return 'R\$ 25.000';
    if (lower.contains('b')) return 'R\$ 50.000';
    return 'R\$ 10.000';
  }
}