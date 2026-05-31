//feito por marcelo
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/core/app_settings.dart';
import 'package:mobx/mobx.dart';

part 'marketplace_controller.g.dart';

enum MarketplaceFilter { todos, nova, emOperacao, emExpansao }

extension MarketplaceFilterLabel on MarketplaceFilter {
  String get label {
    switch (this) {
      case MarketplaceFilter.todos:
        return 'Todas';
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
      case MarketplaceFilter.todos:
        return '';
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
  MarketplaceFilter activeFilter = MarketplaceFilter.todos;

  @observable
  ObservableList<Map<String, dynamic>> sellOrders =
      ObservableList<Map<String, dynamic>>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  String get currentUserId => _auth.currentUser?.uid ?? '';

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
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final idToken = await user.getIdToken();
      final response = await _dio.get(
        'market/offers',
        queryParameters: {
          if (activeFilter.stageValue.isNotEmpty)
            'stage': activeFilter.stageValue,
        },
        options: Options(
          headers: idToken == null
              ? null
              : {'Authorization': 'Bearer $idToken'},
        ),
      );

      final raw = response.data;
      final items = raw is Map && raw['offers'] is List
          ? (raw['offers'] as List)
          : raw is Map && raw['data'] is List
          ? (raw['data'] as List)
          : raw is List
          ? raw
          : <dynamic>[];

      sellOrders.clear();
      sellOrders.addAll(
        items.whereType<Map>().map((item) {
          final offer = Map<String, dynamic>.from(item);
          final offerId = (offer['id'] ?? offer['offerId'] ?? '').toString();
          final startupId = (offer['startupId'] ?? '').toString();
          final startupName =
              (offer['startupName'] ?? offer['title'] ?? startupId).toString();
          final price = _asDouble(
            offer['unitPrice'] ?? offer['pricePerToken'] ?? offer['price'],
          );
          final remainingQuantity = _asInt(
            offer['remainingQuantity'] ?? offer['quantity'] ?? offer['amount'],
          );

          return <String, dynamic>{
            'id': offerId,
            'offerId': offerId,
            'ownerId': offer['ownerId'] ?? offer['sellerId'] ?? '',
            'sellerId': offer['sellerId'] ?? offer['ownerId'] ?? '',
            'startupId': startupId,
            'startupName': startupName,
            'title': startupName,
            'sellerName': offer['sellerName'] ?? 'Investidor',
            'quantity': remainingQuantity,
            'price': price,
            'unitPrice': price,
            'status': offer['status'] ?? 'open',
          };
        }),
      );
    } on DioException catch (e) {
      debugPrint('MarketplaceController fetch Dio error: ${e.message}');
      errorMessage = _extractDioError(e);
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
  Future<void> buyOffer({
    required String offerId,
    required int quantity,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final token = await user.getIdToken();

      await _dio.post(
        'market/offers/$offerId/buy',
        data: {'quantity': quantity},
        options: Options(
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );

      await fetchSellOrders();
    } on DioException catch (e) {
      debugPrint('MarketplaceController buyOffer Dio error: ${e.message}');
      errorMessage = _extractDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('MarketplaceController buyOffer error: $e');
      errorMessage = 'Erro inesperado ao processar a compra.';
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> cancelOffer({required String offerId}) async {
    isLoading = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final token = await user.getIdToken();

      await _dio.delete(
        'market/offers/$offerId',
        options: Options(
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );

      await fetchSellOrders();
    } on DioException catch (e) {
      debugPrint('MarketplaceController cancelOffer Dio error: ${e.message}');
      errorMessage = _extractDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('MarketplaceController cancelOffer error: $e');
      errorMessage = 'Erro inesperado ao cancelar a oferta.';
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateOffer({
    required String offerId,
    required int quantity,
    required double price,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final token = await user.getIdToken();

      await _dio.patch(
        'market/offers/$offerId',
        data: {'quantity': quantity, 'price': price},
        options: Options(
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );

      await fetchSellOrders();
    } on DioException catch (e) {
      debugPrint('MarketplaceController updateOffer Dio error: ${e.message}');
      errorMessage = _extractDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('MarketplaceController updateOffer error: $e');
      errorMessage = 'Erro inesperado ao alterar a oferta.';
      rethrow;
    } finally {
      isLoading = false;
    }
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
