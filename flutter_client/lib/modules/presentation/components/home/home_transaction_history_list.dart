import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/home/home_palette.dart';

class HomeTransactionHistoryList extends StatelessWidget {
  const HomeTransactionHistoryList({
    required this.transactions,
    required this.formatCurrencyAmount,
    super.key,
  });

  final List<Map<String, dynamic>> transactions;
  final String Function(double amount) formatCurrencyAmount;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const HomeEmptyHistoryCard();
    }

    return Column(
      children: transactions
          .map(
            (transaction) => HomeHistoryCard(
              transaction: transaction,
              formatCurrencyAmount: formatCurrencyAmount,
            ),
          )
          .toList(growable: false),
    );
  }
}

class HomeHistoryCard extends StatelessWidget {
  const HomeHistoryCard({
    required this.transaction,
    required this.formatCurrencyAmount,
    super.key,
  });

  final Map<String, dynamic> transaction;
  final String Function(double amount) formatCurrencyAmount;

  @override
  Widget build(BuildContext context) {
    final amount = _transactionAmount(transaction);
    final isPositive = amount >= 0;
    final amountLabel = _transactionAmountLabel(
      transaction,
      formatCurrencyAmount,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE9E0F7)),
            ),
            child: Icon(
              _transactionIcon(transaction),
              color: isPositive ? HomePalette.brandPink : HomePalette.deepText,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transactionTitle(transaction),
                  style: const TextStyle(
                    color: HomePalette.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _transactionSubtitle(transaction),
                  style: const TextStyle(
                    color: HomePalette.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amountLabel,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isPositive ? HomePalette.brandPink : HomePalette.deepText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeEmptyHistoryCard extends StatelessWidget {
  const HomeEmptyHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sem movimentacoes por enquanto',
            style: TextStyle(
              color: HomePalette.deepText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Os ultimos depositos, saques e investimentos vao aparecer aqui.',
            style: TextStyle(
              color: HomePalette.mutedText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _transactionIcon(Map<String, dynamic> transaction) {
  switch ((transaction['type'] ?? '').toString()) {
    case 'ADD_BALANCE':
      return Icons.add_circle_rounded;
    case 'WITHDRAW_BALANCE':
      return Icons.account_balance_wallet_outlined;
    case 'SELL':
      return Icons.trending_up_rounded;
    case 'BUY':
      return Icons.insert_chart_outlined_rounded;
    default:
      return Icons.wallet_giftcard_rounded;
  }
}

String _transactionTitle(Map<String, dynamic> transaction) {
  switch ((transaction['type'] ?? '').toString()) {
    case 'ADD_BALANCE':
      return 'Depósito';
    case 'WITHDRAW_BALANCE':
      return 'Saque';
    case 'SELL':
      return 'Venda de Ativos';
    case 'BUY':
      return 'Compra de Ativos';
    case 'CREATE_WALLET':
      return 'Carteira criada';
    default:
      return 'Movimentacao';
  }
}

String _transactionSubtitle(Map<String, dynamic> transaction) {
  final createdAt = DateTime.tryParse(
    (transaction['createdAt'] ?? '').toString(),
  );

  if (createdAt == null) {
    return 'Agora';
  }

  final now = DateTime.now();
  final months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];
  final hour = createdAt.hour.toString().padLeft(2, '0');
  final minute = createdAt.minute.toString().padLeft(2, '0');
  final isYesterday =
      now.difference(createdAt).inDays == 1 && now.day != createdAt.day;

  if (isYesterday) {
    return 'Ontem - $hour:$minute';
  }

  return '${createdAt.day} ${months[createdAt.month - 1]} - $hour:$minute';
}

double _transactionAmount(Map<String, dynamic> transaction) {
  final type = (transaction['type'] ?? '').toString();
  switch (type) {
    case 'ADD_BALANCE':
      return _asDouble(transaction['amount']);
    case 'WITHDRAW_BALANCE':
      return -_asDouble(transaction['amount']);
    case 'SELL':
      return _asDouble(transaction['total']);
    case 'BUY':
      return -_asDouble(transaction['total']);
    default:
      return 0;
  }
}

String _transactionAmountLabel(
  Map<String, dynamic> transaction,
  String Function(double amount) formatCurrencyAmount,
) {
  final amount = _transactionAmount(transaction);
  final formatted = formatCurrencyAmount(amount.abs());

  if (amount > 0) {
    return '+ $formatted';
  }

  if (amount < 0) {
    return '- $formatted';
  }

  return formatted;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}
