//feito por Marcelo
import 'package:flutter/material.dart';

class PasswordValidationCard extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUpperAndLower;
  final bool hasNumberOrSymbol;

  const PasswordValidationCard({
    super.key,
    required this.hasMinLength,
    required this.hasUpperAndLower,
    required this.hasNumberOrSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1FF),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sua senha deve conter:',
            style: TextStyle(
              color: Color(0xFF170B58),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleRow('Pelo menos 8 caracteres', hasMinLength),
          _buildRuleRow('Letras maiúsculas e minúsculas', hasUpperAndLower),
          _buildRuleRow('Pelo menos um número ou símbolo', hasNumberOrSymbol),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isValid ? const Color(0xFFC71E74) : const Color(0xFF584048).withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? const Color(0xFF584048) : const Color(0xFF584048).withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}