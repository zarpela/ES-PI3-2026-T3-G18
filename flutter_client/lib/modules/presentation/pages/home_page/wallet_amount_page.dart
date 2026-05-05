import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/wallet/wallet_amount_form.dart';
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
  final TextEditingController _amountController = TextEditingController(
    text: '0,00',
  );

  double _amount = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isDeposit => widget.mode == WalletAmountPageMode.deposit;

  bool get _canSubmit {
    if (_isSubmitting || _amount <= 0) {
      return false;
    }

    if (!_isDeposit && _amount > widget.controller.availableBalance) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9FF),
      body: WalletAmountForm(
        title: _isDeposit ? 'Depositar' : 'Sacar',
        label: _isDeposit ? 'VALOR DO DEPOSITO' : 'VALOR DO SAQUE',
        amountController: _amountController,
        amountTextColor: const Color(0xFFE7C0DD),
        balanceLabel: widget.controller.formatCurrencyAmount(
          widget.controller.availableBalance,
        ),
        errorMessage: _errorMessage,
        isSubmitting: _isSubmitting,
        canSubmit: _canSubmit,
        submitLabel: _isDeposit ? 'Continuar' : 'Confirmar saque',
        onBack: () => Navigator.of(context).pop(),
        onAmountChanged: _handleAmountChanged,
        onSubmit: _submit,
      ),
    );
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
        setState(() => _isSubmitting = false);
      }
    }
  }
}
