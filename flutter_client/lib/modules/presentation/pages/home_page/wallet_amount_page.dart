import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

enum WalletAmountPageMode { deposit, withdraw }

class WalletAmountPage extends StatefulWidget {
  const WalletAmountPage({
    required this.controller,
    required this.mode,
    super.key,
  });

  final HomeController controller;
  final WalletAmountPageMode mode;

  @override
  State<WalletAmountPage> createState() => _WalletAmountPageState();
}

class _WalletAmountPageState extends State<WalletAmountPage> {
  static const Color pageBackground = Color(0xFFFCF9FF);
  static const Color deepText = Color(0xFF241B60);
  static const Color mutedText = Color(0xFF756E93);
  static const Color brandPink = Color(0xFFD4147A);

  final TextEditingController _amountController = TextEditingController(
    text: '0,00',
  );

  double _amount = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isDeposit => widget.mode == WalletAmountPageMode.deposit;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 14, 22, 28 + mediaQuery.padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: brandPink),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isDeposit ? 'Depositar' : 'Sacar',
                    style: const TextStyle(
                      color: deepText,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              Text(
                _isDeposit ? 'VALOR DO DEPOSITO' : 'VALOR DO SAQUE',
                style: const TextStyle(
                  color: mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'R\$ ',
                    style: TextStyle(
                      color: brandPink,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: _handleAmountChanged,
                      style: const TextStyle(
                        color: Color(0xFFE7C0DD),
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
                      color: brandPink,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isDeposit ? 'Saldo atual:' : 'Saldo disponivel:',
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.controller.formatCurrencyAmount(
                        widget.controller.availableBalance,
                      ),
                      style: const TextStyle(
                        color: deepText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
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
                      colors: _canSubmit
                          ? const [Color(0xFFB40D68), Color(0xFFD4147A)]
                          : const [Color(0xFFDDB0C9), Color(0xFFE8BED5)],
                    ),
                    boxShadow: _canSubmit
                        ? [
                            BoxShadow(
                              color: brandPink.withValues(alpha: 0.24),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: _isSubmitting
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
                                _isDeposit ? 'Continuar' : 'Confirmar saque',
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
      ),
    );
  }

  bool get _canSubmit {
    if (_isSubmitting || _amount <= 0) {
      return false;
    }

    if (!_isDeposit && _amount > widget.controller.availableBalance) {
      return false;
    }

    return true;
  }

  void _handleAmountChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final cents = int.tryParse(digits) ?? 0;
    final parsedAmount = cents / 100;
    final formattedValue = _formatEditableAmount(parsedAmount);

    setState(() {
      _amount = parsedAmount;
      _errorMessage = null;
    });

    if (_amountController.text != formattedValue) {
      _amountController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  String _formatEditableAmount(double value) {
    final cents = (value * 100).round();
    final whole = cents ~/ 100;
    final decimal = (cents % 100).toString().padLeft(2, '0');
    final digits = whole.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()},$decimal';
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final message = _isDeposit
          ? await widget.controller.addBalance(_amount)
          : await widget.controller.withdrawBalance(_amount);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(message);
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
