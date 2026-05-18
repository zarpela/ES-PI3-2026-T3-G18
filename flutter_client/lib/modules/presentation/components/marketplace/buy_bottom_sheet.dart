//feito por marcelo
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/marketplace_page/marketplace_controller.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

void showBuyBottomSheet({
  required BuildContext context,
  required String offerId,
  required String assetTitle,
  required double pricePerToken,
  required int availableQuantity,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _BuyBottomSheetContent(
      offerId: offerId,
      assetTitle: assetTitle,
      pricePerToken: pricePerToken,
      availableQuantity: availableQuantity,
    ),
  );
}

class _BuyBottomSheetContent extends StatefulWidget {
  final String offerId;
  final String assetTitle;
  final double pricePerToken;
  final int availableQuantity;

  const _BuyBottomSheetContent({
    required this.offerId,
    required this.assetTitle,
    required this.pricePerToken,
    required this.availableQuantity,
  });

  @override
  State<_BuyBottomSheetContent> createState() => _BuyBottomSheetContentState();
}

class _BuyBottomSheetContentState extends State<_BuyBottomSheetContent> {
  final _controller = Modular.get<MarketplaceController>();
  int _quantity = 1;

  void _increment() {
    if (_quantity < widget.availableQuantity) {
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _handleBuy() async {
    try {
      final payload = {
        'orderId': widget.offerId,
        'quantity': _quantity,
      };

      await _controller.buySellOrder(payload);

      if (!mounted) return;
      
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra realizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Erro ao concluir a compra.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFD4147A);
    final totalValue = widget.pricePerToken * _quantity;

    final canDecrement = _quantity > 1;
    final canIncrement = _quantity < widget.availableQuantity;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comprar Tokens',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF170B58),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.assetTitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF584048),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantidade',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF170B58),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Disponível: ${widget.availableQuantity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF584048).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDFBEC7)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      color: canDecrement ? primaryColor : Colors.grey,
                      onPressed: canDecrement ? _decrement : null,
                    ),
                    Text(
                      '$_quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: canIncrement ? primaryColor : Colors.grey,
                      onPressed: canIncrement ? _increment : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFEAE5FF)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valor Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF584048),
                ),
              ),
              Text(
                'R\$ ${totalValue.toStringAsFixed(2).replaceAll('.', ',')}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),

          Observer(
            builder: (_) {
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _controller.isLoading ? null : _handleBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmar Compra',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}