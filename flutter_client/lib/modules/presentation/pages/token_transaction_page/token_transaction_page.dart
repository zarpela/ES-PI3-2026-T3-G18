//feito por Marcelo Zarpelon - RA: 25015323
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'token_transaction_controller.dart';

class TokenTransactionPage extends StatefulWidget {
  final TransactionType type;
  final String id;
  final String? startupName;
  final double? unitPrice;
  final int? tokensDisponiveis;
  final String? logoUrl;

  const TokenTransactionPage({
    super.key,
    required this.type,
    required this.id,
    this.startupName,
    this.unitPrice,
    this.tokensDisponiveis,
    this.logoUrl,
  });

  @override
  State<TokenTransactionPage> createState() => _TokenTransactionPageState();
}

class _TokenTransactionPageState extends State<TokenTransactionPage> {
  late final TokenTransactionController _controller;
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  static const Color primaryPink = Color(0xFFD4147A);
  static const Color darkText = Color(0xFF170B58);
  static const Color mutedText = Color(0xFF584048);
  static const Color bgColor = Color(0xFFFCF8FF);
  static const Color cardBgColor = Color(0xFFF6F1FF);

  @override
  void initState() {
    super.initState();
    _controller = TokenTransactionController(transactionType: widget.type);
    _controller
        .loadAssetData(
          widget.id,
          initialStartupName: widget.startupName,
          initialPricePerToken: widget.unitPrice,
        )
        .then((_) {
          if (mounted) {
            _syncQuantityInput();
          }
        });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  bool get isBuy => widget.type == TransactionType.buy;

  String _formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(2);
    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];

    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += '.';
      }
      formattedInteger += integerPart[i];
    }

    return 'R\$ $formattedInteger,$decimalPart';
  }

  void _showEditPriceDialog(BuildContext context) {
    final TextEditingController priceController = TextEditingController(
      text: _controller.pricePerToken.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Definir preço',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryPink),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: mutedText)),
          ),
          TextButton(
            onPressed: () {
              final newPrice = double.tryParse(
                priceController.text.replaceAll(',', '.'),
              );
              if (newPrice != null && newPrice > 0) {
                _controller.updatePricePerToken(newPrice);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Salvar',
              style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _syncQuantityInput() {
    final text = '${_controller.quantity}';
    if (_quantityController.text == text) {
      return;
    }

    _quantityController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _updateQuantityFromInput(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return;
    }

    _controller.updateQuantity(parsed);
    _syncQuantityInput();
  }

  void _decrementQuantity() {
    _controller.decrementQuantity();
    _syncQuantityInput();
  }

  void _incrementQuantity() {
    _controller.incrementQuantity();
    _syncQuantityInput();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryPink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isBuy ? 'Comprar Tokens' : 'Vender Tokens',
          style: const TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy
                        ? 'Quanto deseja comprar?'
                        : 'Quanto você deseja vender?',
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBuy
                        ? 'Defina a quantidade de tokens para compra.'
                        : 'Defina a quantidade de tokens para retirada.',
                    style: TextStyle(
                      color: mutedText.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Asset Info Card
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: primaryPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hexagon_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Observer(
                              builder: (_) => Text(
                                _controller.assetName.isNotEmpty
                                    ? _controller.assetName
                                    : 'Ativo',
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Observer(
                              builder: (_) => Text(
                                isBuy
                                    ? 'Saldo disponível: ${_formatCurrency(_controller.availableFiatBalance)}'
                                    : 'Disponível: ${_controller.availableTokenBalance} Tokens',
                                style: TextStyle(
                                  color: mutedText.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Counter & Total Value Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCounterButton(
                              icon: Icons.remove,
                              onTap: _decrementQuantity,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 112,
                                  child: TextField(
                                    controller: _quantityController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: _updateQuantityFromInput,
                                    onEditingComplete: () {
                                      if (_quantityController.text.isEmpty) {
                                        _controller.updateQuantity(1);
                                        _syncQuantityInput();
                                      }
                                      FocusScope.of(context).unfocus();
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'TOKENS',
                                  style: TextStyle(
                                    color: mutedText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            _buildCounterButton(
                              icon: Icons.add,
                              isPrimary: true,
                              onTap: _incrementQuantity,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Valor Total',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Observer(
                          builder: (_) => Text(
                            _formatCurrency(_controller.totalValue),
                            style: const TextStyle(
                              color: primaryPink,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summary Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Preço por token',
                              style: TextStyle(color: mutedText, fontSize: 14),
                            ),
                            Observer(
                              builder: (_) {
                                final priceText = _formatCurrency(
                                  _controller.pricePerToken,
                                );
                                if (isBuy) {
                                  return Text(
                                    priceText,
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  // Editable Price for Sell
                                  return GestureDetector(
                                    onTap: () => _showEditPriceDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryPink.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            priceText,
                                            style: const TextStyle(
                                              color: darkText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: primaryPink,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Taxa de serviço',
                              style: TextStyle(color: mutedText, fontSize: 14),
                            ),
                            Text(
                              'GRÁTIS',
                              style: TextStyle(
                                color: primaryPink,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.black12, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBuy ? 'Total a pagar' : 'Total a receber',
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Observer(
                              builder: (_) => Text(
                                _formatCurrency(_controller.totalValue),
                                style: const TextStyle(
                                  color: primaryPink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms text
                  Center(
                    child: Text(
                      isBuy
                          ? 'Ao confirmar, você concorda com os Termos de Investimento\ne a Cessão de Direitos do ativo Imóvel Solar Residencial.'
                          : 'Ao confirmar, você concorda com os Termos de Venda e a\nCessão de Direitos do ativo Imóvel Solar Residencial.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mutedText.withValues(alpha: 0.6),
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.9),
                  blurRadius: 20,
                  offset: const Offset(0, -20),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Observer(
                builder: (_) {
                  return ElevatedButton(
                    onPressed:
                        (_controller.isLoading || _controller.isSubmitting)
                        ? null
                        : () async {
                            final ok = await _controller.submit(widget.id);

                            if (!context.mounted) return;

                            if (ok) {
                              await Modular.get<HomeController>()
                                  .refreshWallet();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBuy
                                        ? 'Compra realizada com sucesso!'
                                        : 'Oferta de venda criada com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).maybePop();
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _controller.errorMessage ??
                                      'Não foi possível completar a operação.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isBuy ? 'Confirmar Compra' : 'Confirmar Venda',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? primaryPink : Colors.transparent,
            border: isPrimary
                ? null
                : Border.all(
                    color: primaryPink.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
          ),
          child: Icon(icon, color: isPrimary ? Colors.white : primaryPink),
        ),
      ),
    );
  }
}
