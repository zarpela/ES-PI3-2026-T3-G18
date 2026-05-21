//feito por marcelo
// integracao com backend feita por Abdallah

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/core/app_settings.dart';
import 'package:mobx/mobx.dart';

part 'token_transaction_controller.g.dart';

enum TransactionType { buy, sell }

class TokenTransactionController = _TokenTransactionControllerBase
    with _$TokenTransactionController;

abstract class _TokenTransactionControllerBase with Store {
  _TokenTransactionControllerBase({required this.transactionType}) {
    _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
    _dio = Dio(
      BaseOptions(
        baseUrl: AppSettings.baseUrl,
        sendTimeout: Duration(milliseconds: AppSettings.timeout),
        connectTimeout: Duration(milliseconds: AppSettings.timeout),
        receiveTimeout: Duration(milliseconds: AppSettings.timeout),
      ),
    );
  }

  final TransactionType transactionType;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFunctions _functions;
  late final Dio _dio;

  @observable
  bool isLoading = true;

  @observable
  bool isSubmitting = false;

  @observable
  String assetName = '';

  @observable
  int quantity = 1;

  @observable
  double pricePerToken = 0.0;

  @observable
  double availableFiatBalance = 0.0;

  @observable
  int availableTokenBalance = 0;

  @observable
  String? errorMessage;

  @computed
  double get totalValue => quantity * pricePerToken;

  @action
  Future<void> loadAssetData(String startupId) async {
    isLoading = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }

      final token = await user.getIdToken();

      final walletResponse = await _dio.get(
        'wallet/${user.uid}',
        options: Options(
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );

      final wallet =
          walletResponse.data is Map && walletResponse.data['wallet'] is Map
              ? Map<String, dynamic>.from(walletResponse.data['wallet'] as Map)
              : <String, dynamic>{};

      availableFiatBalance = _asDouble(wallet['balance']);

      final walletTokens = (wallet['tokens'] is List)
          ? (wallet['tokens'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      final ownedToken = walletTokens.firstWhere(
        (token) => (token['startupId'] ?? '').toString().trim() == startupId,
        orElse: () => <String, dynamic>{},
      );

      availableTokenBalance = _asInt(ownedToken['quantity']);
      final averagePrice = _asDouble(ownedToken['averagePrice']);

      final startup = await _fetchStartupById(startupId);
      assetName =
          (startup['name'] ?? startup['startupName'] ?? startupId).toString();

      final tokenPrice =
          _calculateTokenPrice(startup, fallback: averagePrice);

      pricePerToken = transactionType == TransactionType.sell
          ? (averagePrice > 0 ? averagePrice : tokenPrice)
          : tokenPrice;

      quantity = 1;
    } catch (e) {
      debugPrint('TokenTransactionController loadAssetData error: $e');
      errorMessage = 'Nao foi possivel carregar os dados do ativo.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> submit(String startupId) async {
    isSubmitting = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'Usuario nao autenticado.';
        return false;
      }

      if (quantity <= 0) {
        errorMessage = 'Quantidade invalida.';
        return false;
      }

      if (transactionType == TransactionType.sell &&
          quantity > availableTokenBalance) {
        errorMessage = 'Quantidade de tokens insuficiente para venda.';
        return false;
      }

      final token = await user.getIdToken();
      final endpoint =
          transactionType == TransactionType.buy ? 'market/buy' : 'market/sell';

      final response = await _dio.post(
        endpoint,
        data: {
          'startupId': startupId,
          'quantity': quantity,
          'price': pricePerToken,
        },
        options: Options(
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );

      final wallet = response.data is Map && response.data['wallet'] is Map
          ? Map<String, dynamic>.from(response.data['wallet'] as Map)
          : null;

      if (wallet != null) {
        availableFiatBalance = _asDouble(wallet['balance']);

        final walletTokens = (wallet['tokens'] is List)
            ? (wallet['tokens'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];

        final ownedToken = walletTokens.firstWhere(
          (token) => (token['startupId'] ?? '').toString().trim() == startupId,
          orElse: () => <String, dynamic>{},
        );

        availableTokenBalance = _asInt(ownedToken['quantity']);
      }

      return true;
    } on DioException catch (e) {
      debugPrint('TokenTransactionController submit Dio error: ${e.message}');
      errorMessage = _extractDioError(e);
      return false;
    } catch (e) {
      debugPrint('TokenTransactionController submit error: $e');
      errorMessage = 'Erro inesperado ao processar a transacao.';
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  @action
  void incrementQuantity() {
    if (transactionType == TransactionType.sell &&
        quantity >= availableTokenBalance) {
      return;
    }
    quantity++;
  }

  @action
  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  @action
  void updatePricePerToken(double newPrice) {
    if (transactionType == TransactionType.sell) {
      pricePerToken = newPrice;
    }
  }

  Future<Map<String, dynamic>> _fetchStartupById(String startupId) async {
    final callable = _functions.httpsCallable('getStartupById');
    final result = await callable.call(<String, dynamic>{
      'id': startupId,
      'startupId': startupId,
    });

    final data = result.data;

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Formato de dados inesperado retornado pelo servidor.');
  }

  double _calculateTokenPrice(
    Map<String, dynamic> startup, {
    required double fallback,
  }) {
    final emittedTokens = _asDouble(startup['totalEmittedTokens']);
    final targetCapital = _asDouble(startup['targetCapital']);

    if (emittedTokens > 0 && targetCapital > 0) {
      final price = targetCapital / emittedTokens;
      if (price.isFinite && price > 0) {
        return price;
      }
    }

    if (fallback > 0) {
      return fallback;
    }

    return 1.0;
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _extractDioError(DioException exception) {
    final responseData = exception.response?.data;

    if (responseData is Map) {
      final message = responseData['message'] ?? responseData['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    return 'Nao foi possivel completar a operacao.';
  }
}
