import 'package:flutter/material.dart';

/// Bottom sheet de confirmação de compra.
///
/// Gerencia localmente a quantidade selecionada e calcula
/// o total reativamente na tela.
///
/// Uso:
/// ```dart
/// showBuyBottomSheet(
///   context: context,
///   assetTitle: 'Imóvel Solar Residencial',
///   pricePerToken: 150.00,
/// );
/// ```
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
    if (_quantity > widget.minQuantity) {
      setState(() => _quantity--);
    }
  }

  void _increment() {
    if (_quantity < widget.maxQuantity) {
      setState(() => _quantity++);
    }
  }

  double get _total => _quantity * widget.pricePerToken;

  String _formatCurrency(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+,)'),
            (m) => '${m[1]}.',
          )}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          // Drag handle
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

          // Header: título + botão fechar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quanto deseja comprar?',
                      style: theme.textTheme.titleMedium?.copyWith(
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
                          style: theme.textTheme.bodySmall?.copyWith(
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

          // Seletor de quantidade
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
                  // Botão subtrair
                  _QuantityButton(
                    onTap: _decrement,
                    icon: Icons.remove,
                    filled: false,
                  ),

                  // Valor central
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          '$_quantity',
                          style: TextStyle(
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

                  // Botão adicionar
                  _QuantityButton(
                    onTap: _increment,
                    icon: Icons.add,
                    filled: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Divisor
          Divider(color: const Color(0xFFE4DFFF), thickness: 1),

          const SizedBox(height: 16),

          // Resumo financeiro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preço por token',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _subtitleColor,
                ),
              ),
              Text(
                _formatCurrency(widget.pricePerToken),
                style: theme.textTheme.bodyMedium?.copyWith(
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
              Text(
                'Total a pagar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(_total),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Botão confirmar compra
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: disparar action de compra via controller
              },
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
        child: Icon(
          icon,
          color: filled ? Colors.white : _primaryColor,
          size: 24,
        ),
      ),
    );
  }
}