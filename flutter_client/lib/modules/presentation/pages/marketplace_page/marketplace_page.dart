//feito por marcelo
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/filter_chip.dart';
import 'package:flutter_client/modules/presentation/components/marketplace/buy_bottom_sheet.dart';
import 'package:flutter_client/modules/presentation/components/marketplace/offer_card_widget.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/marketplace_page/marketplace_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _controller = Modular.get<MarketplaceController>();

  static const _primaryColor = Color(0xFFD4147A);

  @override
  void initState() {
    super.initState();
    _controller.fetchSellOrders();
  }

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
                if (_controller.isLoading && _controller.sellOrders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  );
                }

                if (_controller.errorMessage != null &&
                    _controller.sellOrders.isEmpty) {
                  return Center(
                    child: Text(
                      _controller.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                final filtered = _controller.sellOrders.where((order) {
                  final q = _controller.searchQuery.toLowerCase();

                  final title = (order['startupName'] ?? order['title'] ?? '')
                      .toString()
                      .toLowerCase();
                  final sellerName = (order['sellerName'] ?? '')
                      .toString()
                      .toLowerCase();

                  return q.isEmpty ||
                      title.contains(q) ||
                      sellerName.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma oferta encontrada.',
                      style: TextStyle(
                        color: const Color(0xFF584048).withOpacity(0.7),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = filtered[index];

                    final offerId = (order['id'] ?? order['orderId'] ?? '')
                        .toString();
                    final offerTitle =
                        (order['startupName'] ?? order['title'] ?? 'Oferta')
                            .toString();
                    final offerSeller = (order['sellerName'] ?? 'Vendedor')
                        .toString();
                    final offerQuantity =
                        int.tryParse(order['quantity']?.toString() ?? '0') ?? 0;
                    final offerPrice =
                        double.tryParse(order['price']?.toString() ?? '0') ??
                        0.0;
                    final ownerId =
                        (order['ownerId'] ?? order['sellerId'] ?? '')
                            .toString();
                    final isOwnOffer =
                        ownerId.isNotEmpty &&
                        ownerId == _controller.currentUserId;

                    final offerModel = OfferCardModel(
                      id: offerId,
                      title: offerTitle,
                      sellerName: offerSeller,
                      quantity: offerQuantity,
                      unit: 'tokens',
                      pricePerUnit: offerPrice,
                      isOwnOffer: isOwnOffer,
                      icon: Icons.business_outlined,
                      iconBackgroundColor: const Color(0xFFF0EBFF),
                    );

                    return OfferCardWidget(
                      offer: offerModel,
                      onBuyTap: () => showBuyBottomSheet(
                        context: context,
                        offerId: offerModel.id,
                        assetTitle: offerModel.title,
                        pricePerToken: offerModel.pricePerUnit,
                        availableQuantity: offerQuantity,
                      ),
                      onEditTap: () => _showEditOfferDialog(order),
                      onCancelTap: () => _cancelOffer(offerId),
                      onDetailsTap: () async {
                        try {
                          final startupId =
                              order['startupId']?.toString() ?? '';

                          final startupDetails = await _controller
                              .getStartupById(startupId);

                          if (!context.mounted) return;
                          Modular.to.pushNamed(
                            AppRoutes.startupDetailsPage,
                            arguments: startupDetails,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _controller.errorMessage ??
                                    'Erro ao carregar detalhes',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
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

  Future<void> _cancelOffer(String offerId) async {
    try {
      await _controller.cancelOffer(offerId: offerId);
      await Modular.get<HomeController>().refreshWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oferta cancelada com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Erro ao cancelar oferta.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditOfferDialog(Map<String, dynamic> order) async {
    final offerId = (order['id'] ?? order['offerId'] ?? '').toString();
    final quantityController = TextEditingController(
      text: (order['quantity'] ?? 0).toString(),
    );
    final priceController = TextEditingController(
      text: ((double.tryParse(order['price']?.toString() ?? '0') ?? 0)
          .toStringAsFixed(2)
          .replaceAll('.', ',')),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Editar oferta',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Preço unitário'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text.trim());
              final price = double.tryParse(
                priceController.text
                    .replaceAll('.', '')
                    .replaceAll(',', '.')
                    .trim(),
              );

              if (quantity == null ||
                  quantity <= 0 ||
                  price == null ||
                  price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe quantidade e preço válidos.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await _controller.updateOffer(
                  offerId: offerId,
                  quantity: quantity,
                  price: price,
                );
                await Modular.get<HomeController>().refreshWallet();
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Oferta alterada com sucesso.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _controller.errorMessage ?? 'Erro ao alterar oferta.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Salvar', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );

    quantityController.dispose();
    priceController.dispose();
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
        hintStyle: TextStyle(color: const Color(0xFF584048).withOpacity(0.45)),
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
          borderSide: const BorderSide(color: Color(0xFFD4147A), width: 1.5),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final MarketplaceController controller;

  const _FilterChips({required this.controller});

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
                child: CustomFilterChip(
                  label: filter.label,
                  isActive: isActive,
                  onTap: () => controller.onFilterSelected(filter),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
