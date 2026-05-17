import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/marketplace_page/marketplace_controller.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

// Importe os arquivos do seu projeto conforme os paths reais:
// import 'marketplace_controller.dart';
// import 'offer_card_widget.dart';
// import 'buy_bottom_sheet.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ATENÇÃO: Os imports abaixo são relativos ao projeto MesclaInvest.
// Ajuste os caminhos conforme a estrutura real do seu módulo.
//
// Exemplo de estrutura sugerida:
//   lib/modules/presentation/pages/marketplace_page/
//     marketplace_page.dart          ← este arquivo
//     marketplace_controller.dart
//   lib/modules/presentation/components/
//     offer_card_widget.dart
//     buy_bottom_sheet.dart
// ──────────────────────────────────────────────────────────────────────────────


final List<OfferCardModel> _mockOffers = [
  OfferCardModel(
    title: 'Imóvel Solar Residencial',
    sellerName: 'joao.silva',
    quantity: 125,
    unit: 'tokens',
    pricePerUnit: 150.00,
    icon: Icons.home_outlined,
    iconBackgroundColor: const Color(0xFFF0EBFF),
  ),
  OfferCardModel(
    title: 'Painel Solar Industrial',
    sellerName: 'energia.verde',
    quantity: 300,
    unit: 'tokens',
    pricePerUnit: 89.90,
    icon: Icons.solar_power_outlined,
    iconBackgroundColor: const Color(0xFFFFF9E4),
  ),
  OfferCardModel(
    title: 'Startup AgriTech',
    sellerName: 'agro.invest',
    quantity: 50,
    unit: 'tokens',
    pricePerUnit: 420.00,
    icon: Icons.eco_outlined,
    iconBackgroundColor: const Color(0xFFE8F5E9),
  ),
];

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _controller = Modular.get<MarketplaceController>();


  static const _primaryColor = Color(0xFFA1005B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF8FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF584048)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da página
                Text(
                  'Marketplace',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF170B58),
                      ),
                ),
                const SizedBox(height: 16),

                _SearchBar(controller: _controller),

                const SizedBox(height: 16),

                _FilterChips(controller: _controller),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // Lista de cards
          Expanded(
            child: Observer(
              builder: (_) {
                // Filtragem local simples — substitua por lógica do repositório.
                final filtered = _mockOffers.where((o) {
                  final q = _controller.searchQuery.toLowerCase();
                  return q.isEmpty ||
                      o.title.toLowerCase().contains(q) ||
                      o.sellerName.toLowerCase().contains(q);
                }).toList();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final offer = filtered[index];
                    return OfferCardWidget(
                      offer: offer,
                      onBuyTap: () => showBuyBottomSheet(
                        context: context,
                        assetTitle: offer.title,
                        pricePerToken: offer.pricePerUnit,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final MarketplaceController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar ofertas...',
        hintStyle: TextStyle(
          color: const Color(0xFF584048).withOpacity(0.45),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: const Color(0xFF584048).withOpacity(0.6),
        ),
        filled: true,
        fillColor: const Color(0xFFF6F1FF),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFA1005B),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final MarketplaceController controller;

  const _FilterChips({required this.controller});

  static const _primaryColor = Color(0xFFA1005B);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MarketplaceFilter.values.map((filter) {
              final isActive = controller.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.onFilterSelected(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primaryColor
                          : const Color(0xFFEAE5FF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      filter.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF584048),
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// STUB: copie as classes abaixo dos arquivos gerados ou importe-as.
// ---------------------------------------------------------------------------

// ── OfferCardModel & OfferCardWidget (offer_card_widget.dart) ─────────────
class OfferCardModel {
  final String title;
  final String sellerName;
  final int quantity;
  final String unit;
  final double pricePerUnit;
  final IconData icon;
  final Color iconBackgroundColor;

  const OfferCardModel({
    required this.title,
    required this.sellerName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFF0EBFF),
  });
}

class OfferCardWidget extends StatelessWidget {
  final OfferCardModel offer;
  final VoidCallback onBuyTap;

  const OfferCardWidget({super.key, required this.offer, required this.onBuyTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFFA1005B);
    final currencyFormatted =
        'R\$ ${offer.pricePerUnit.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: offer.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(offer.icon, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF170B58),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vendedor: ${offer.sellerName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF584048).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUANTIDADE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF584048).withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${offer.quantity} ${offer.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF170B58),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFDFBEC7).withOpacity(0.4),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREÇO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF584048).withOpacity(0.6),
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatted,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBuyTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── showBuyBottomSheet (buy_bottom_sheet.dart) ────────────────────────────
void showBuyBottomSheet({
  required BuildContext context,
  required String assetTitle,
  required double pricePerToken,
  int initialQuantity = 10,
  int minQuantity = 1,
  int maxQuantity = 999,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BuyBottomSheetContent(
      assetTitle: assetTitle,
      pricePerToken: pricePerToken,
      initialQuantity: initialQuantity,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
    ),
  );
}

class _BuyBottomSheetContent extends StatefulWidget {
  final String assetTitle;
  final double pricePerToken;
  final int initialQuantity;
  final int minQuantity;
  final int maxQuantity;

  const _BuyBottomSheetContent({
    required this.assetTitle,
    required this.pricePerToken,
    required this.initialQuantity,
    required this.minQuantity,
    required this.maxQuantity,
  });

  @override
  State<_BuyBottomSheetContent> createState() =>
      _BuyBottomSheetContentState();
}

class _BuyBottomSheetContentState extends State<_BuyBottomSheetContent> {
  late int _quantity;

  static const _primaryColor = Color(0xFFA1005B);
  static const _titleColor = Color(0xFF170B58);
  static const _subtitleColor = Color(0xFF584048);

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _decrement() {
    if (_quantity > widget.minQuantity) setState(() => _quantity--);
  }

  void _increment() {
    if (_quantity < widget.maxQuantity) setState(() => _quantity++);
  }

  double get _total => _quantity * widget.pricePerToken;

  String _formatCurrency(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+,)'),
            (m) => '${m[1]}.',
          )}';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDFBEC7).withOpacity(0.5),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quanto deseja comprar?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _titleColor,
                        fontSize: 18,
                      ),
                    ),
                    if (widget.assetTitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.assetTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: _subtitleColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: _subtitleColor,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F1FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF6C65D9).withOpacity(0.35),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityButton(onTap: _decrement, icon: Icons.remove, filled: false),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        Text(
                          'TOKENS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor.withOpacity(0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _QuantityButton(onTap: _increment, icon: Icons.add, filled: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Divider(color: const Color(0xFFE4DFFF), thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preço por token',
                style: TextStyle(color: _subtitleColor),
              ),
              Text(
                _formatCurrency(widget.pricePerToken),
                style: const TextStyle(
                  color: _subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  color: _titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(_total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text(
                'Confirmar Compra',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool filled;

  const _QuantityButton({
    required this.onTap,
    required this.icon,
    required this.filled,
  });

  static const _primaryColor = Color(0xFFA1005B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 72,
        decoration: BoxDecoration(
          color: filled ? _primaryColor : Colors.transparent,
          borderRadius: filled
              ? const BorderRadius.horizontal(right: Radius.circular(14))
              : const BorderRadius.horizontal(left: Radius.circular(14)),
        ),
        child: Icon(icon, color: filled ? Colors.white : _primaryColor, size: 24),
      ),
    );
  }
}