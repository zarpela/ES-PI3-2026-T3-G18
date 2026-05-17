import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/marketplace/buy_bottom_sheet.dart';
import 'package:flutter_client/modules/presentation/components/marketplace/offer_card_widget.dart';
import 'package:flutter_client/modules/presentation/pages/marketplace_page/marketplace_controller.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

final List<OfferCardModel> _mockOffers = [ //TODO: remover mock quando o back chegar
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

          Expanded(
            child: Observer(
              builder: (_) {
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
