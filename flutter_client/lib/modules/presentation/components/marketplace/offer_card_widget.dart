import 'package:flutter/material.dart';

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

  const OfferCardWidget({
    super.key,
    required this.offer,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFA1005B);
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
          // Header: ícone + título + subtítulo
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

          // Bloco de dados: quantidade e preço
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

          // Botão Comprar
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