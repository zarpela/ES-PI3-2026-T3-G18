//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:flutter/material.dart';

class WalletAmountForm extends StatelessWidget {
  const WalletAmountForm({
    required this.title,
    required this.label,
    required this.amountController,
    required this.amountTextColor,
    required this.balanceLabel,
    required this.errorMessage,
    required this.isSubmitting,
    required this.canSubmit,
    required this.submitLabel,
    required this.onBack,
    required this.onAmountChanged,
    required this.onSubmit,
    super.key,
  });

  final String title;
  final String label;
  final TextEditingController amountController;
  final Color amountTextColor;
  final String balanceLabel;
  final String? errorMessage;
  final bool isSubmitting;
  final bool canSubmit;
  final String submitLabel;
  final VoidCallback onBack;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          14,
          22,
          28 + mediaQuery.padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: isSubmitting ? null : onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFFD4147A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF241B60),
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 42),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF756E93),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'R\$ ',
                  style: TextStyle(
                    color: Color(0xFFD4147A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: amountController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    onChanged: onAmountChanged,
                    style: TextStyle(
                      color: amountTextColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1ECFD),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFFD4147A),
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Saldo disponível:',
                    style: TextStyle(color: Color(0xFF756E93), fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    balanceLabel,
                    style: const TextStyle(
                      color: Color(0xFF241B60),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: canSubmit
                        ? const [Color(0xFFB40D68), Color(0xFFD4147A)]
                        : const [Color(0xFFDDB0C9), Color(0xFFE8BED5)],
                  ),
                  boxShadow: canSubmit
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFD4147A,
                            ).withValues(alpha: 0.24),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: canSubmit ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              submitLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
