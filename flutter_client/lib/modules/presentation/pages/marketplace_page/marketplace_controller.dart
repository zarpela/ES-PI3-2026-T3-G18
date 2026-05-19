//feito por marcelo
// integracao com backend feita por Abdallah

import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/core/app_settings.dart';
import 'package:mobx/mobx.dart';

part 'marketplace_controller.g.dart';

enum MarketplaceFilter { nova, emOperacao, emExpansao }

extension MarketplaceFilterLabel on MarketplaceFilter {
  String get label {
    switch (this) {
      case MarketplaceFilter.nova:
        return 'Nova';
      case MarketplaceFilter.emOperacao:
        return 'Em operação';
      case MarketplaceFilter.emExpansao:
        return 'Em expansão';
    }
  }

  String get stageValue {
    switch (this) {
      case MarketplaceFilter.nova:
        return 'nova';
      case MarketplaceFilter.emOperacao:
        return 'em_operacao';
      case MarketplaceFilter.emExpansao:
        return 'em_expansao';
    }
  }
}

// ignore: library_private_types_in_public_api
class MarketplaceController = _MarketplaceControllerBase
    with _$MarketplaceController;

abstract class _MarketplaceControllerBase with Store {
  _MarketplaceControllerBase() {
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFunctions _functions;
  late final Dio _dio;

  @observable
  String searchQuery = '';

  @observable
  MarketplaceFilter activeFilter = MarketplaceFilter.nova;

  @observable
  ObservableList<Map<String, dynamic>> sellOrders =
      ObservableList<Map<String, dynamic>>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  void onSearchChanged(String value) => searchQuery = value;

  @action
  void onFilterSelected(MarketplaceFilter filter) {
    activeFilter = filter;
    fetchSellOrders();
  }

  @action
  Future<void> fetchSellOrders() async {
    isLoading = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      final idToken = await user?.getIdToken();

      final callable = _functions.httpsCallable('getStartups');
      final result = await callable.call(<String, dynamic>{
        'stage': activeFilter.stageValue,
      });

      final raw = result.data;
      final items = raw is Map && raw['data'] is List
          ? (raw['data'] as List)
          : raw is List
              ? raw
              : <dynamic>[];

      final ownedByStartupId = <String, int>{};
      if (user != null && idToken != null) {
        try {
          final walletTokensResponse = await _dio.get(
            'wallet/${user.uid}/tokens',
            options: Options(
              headers: {'Authorization': 'Bearer $idToken'},
            ),
          );

          final tokens = walletTokensResponse.data is Map &&
                  walletTokensResponse.data['tokens'] is List
              ? List<Map<String, dynamic>>.from(
                  (walletTokensResponse.data['tokens'] as List).map(
                    (item) => Map<String, dynamic>.from(item as Map),
                  ),
                )
              : <Map<String, dynamic>>[];

          for (final token in tokens) {
            final startupId = (token['startupId'] ?? '').toString().trim();
            if (startupId.isEmpty) continue;
            ownedByStartupId[startupId] = _asInt(token['quantity']);
          }
        } catch (e) {
          debugPrint('MarketplaceController wallet tokens fetch error: $e');
        }
      }

      sellOrders.clear();

      sellOrders.addAll(
        items.whereType<Map>().map((item) {
          final startup = Map<String, dynamic>.from(item);
          final startupId = (startup['id'] ?? '').toString();
          final startupName = (startup['name'] ?? startupId).toString();

          final price = _calculateTokenPrice(startup);
          final ownedQuantity = ownedByStartupId[startupId] ?? 0;

          return <String, dynamic>{
            'id': startupId,
            'startupId': startupId,
            'startupName': startupName,
            'title': startupName,
            'sellerName': 'MesclaInvest',
            'quantity': ownedQuantity,
            'price': price,
          };
        }),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        'FirebaseFunctionsException (getStartups): code=${e.code}, message=${e.message}',
      );
      errorMessage = 'Não foi possível carregar as ofertas.';
    } catch (e) {
      debugPrint('MarketplaceController fetch error: $e');
      errorMessage = 'Erro inesperado ao carregar o marketplace.';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Map<String, dynamic>> getStartupById(String startupId) async {
    isLoading = true;
    errorMessage = null;

    try {
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
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        'FirebaseFunctionsException (getStartupById): code=${e.code}, message=${e.message}',
      );
      errorMessage = 'Não foi possível carregar os detalhes da startup.';
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('MarketplaceController getStartupById error: $e');
      errorMessage = 'Erro inesperado ao buscar os detalhes da startup.';
      throw Exception(errorMessage);
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> buyTokens({
    required String startupId,
    required int quantity,
    required double price,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }

      final token = await user.getIdToken();

      await _dio.post(
        'market/buy',
        data: {
          'startupId': startupId,
          'quantity': quantity,
          'price': price,
        },
        options: Options(
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      debugPrint('MarketplaceController buyTokens Dio error: ${e.message}');
      errorMessage = _extractDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('MarketplaceController buyTokens error: $e');
      errorMessage = 'Erro inesperado ao processar a compra.';
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  double _calculateTokenPrice(Map<String, dynamic> startup) {
    final emittedTokens = _asDouble(startup['totalEmittedTokens']);
    final targetCapital = _asDouble(startup['targetCapital']);

    if (emittedTokens > 0 && targetCapital > 0) {
      final price = targetCapital / emittedTokens;
      if (price.isFinite && price > 0) {
        return price;
      }
    }

    return 1.0;
  }

  // Mantido aqui para uso futuro caso o marketplace volte a exibir
  // quantidade disponível por startup (emissão primária).
  int _calculateAvailableQuantity(Map<String, dynamic> startup, double price) {
    final emittedTokens = _asInt(startup['totalEmittedTokens']);
    final raisedCapital = _asDouble(startup['raisedCapital']);

    if (emittedTokens <= 0) {
      return 0;
    }

    if (price <= 0 || raisedCapital <= 0) {
      return emittedTokens;
    }

    final sold = (raisedCapital / price).floor();
    return max(0, emittedTokens - sold);
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

    return 'Não foi possível completar a operação.';
  }
}
