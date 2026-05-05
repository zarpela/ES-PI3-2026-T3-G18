import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';
import 'package:flutter_client/modules/presentation/components/home/home_transaction_history_list.dart';

class HomeHistorySheet extends StatelessWidget {
  const HomeHistorySheet({
    required this.transactions,
    required this.formatCurrencyAmount,
    super.key,
  });

  final List<Map<String, dynamic>> transactions;
  final String Function(double amount) formatCurrencyAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: const BoxDecoration(
        color: HomePalette.pageBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5CCE5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Extrato completo',
            style: TextStyle(
              color: HomePalette.deepText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: transactions.isEmpty
                ? const HomeEmptyHistoryCard()
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return HomeHistoryCard(
                        transaction: transactions[index],
                        formatCurrencyAmount: formatCurrencyAmount,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
