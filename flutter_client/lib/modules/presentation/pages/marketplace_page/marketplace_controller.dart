//feito por marcelo
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
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
}

// ignore: library_private_types_in_public_api
class MarketplaceController = _MarketplaceControllerBase
    with _$MarketplaceController;

abstract class _MarketplaceControllerBase with Store {
  _MarketplaceControllerBase() {
    _functions = FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    );
  }

  late final FirebaseFunctions _functions;

  @observable
  String searchQuery = '';

  @observable
  MarketplaceFilter activeFilter = MarketplaceFilter.nova;

  @observable
  ObservableList<Map<String, dynamic>> sellOrders = ObservableList<Map<String, dynamic>>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  void onSearchChanged(String value) => searchQuery = value;

  @action
  void onFilterSelected(MarketplaceFilter filter) => activeFilter = filter;


  @action
  Future<void> fetchSellOrders() async {
    try {
      isLoading = true;
      errorMessage = null;
      final callable = _functions.httpsCallable('getSellOrdersHandler');
      final result = await callable.call(<String, dynamic>{});
      final data = result.data;

      sellOrders.clear();

      if (data is List) {
        sellOrders.addAll(
          data.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      } else if (data is Map && data['data'] is List) {
        sellOrders.addAll(
          (data['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException (getSellOrdersHandler): code=${e.code}, message=${e.message}');
      errorMessage = 'Não foi possível carregar as ordens de venda.';
    } catch (e) {
      debugPrint('MarketplaceController fetch error: $e');
      errorMessage = 'Erro inesperado ao carregar o balcão de vendas.';
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
        'startupId': startupId, 
      });

      final data = result.data;

      if (data is Map) {
        if (data.containsKey('data') && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        
        return Map<String, dynamic>.from(data);
      }

      throw Exception('Formato de dados inesperado retornado pelo servidor.');

    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException (getStartupById): code=${e.code}, message=${e.message}');
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
  Future<void> buySellOrder(Map<String, dynamic> payload) async {
    isLoading = true;
    errorMessage = null;

    try {
      final callable = _functions.httpsCallable('buySellOrderHandler');
      await callable.call(payload);
      
      await fetchSellOrders();
      
    } on FirebaseFunctionsException catch (e) {
      debugPrint('FirebaseFunctionsException (buySellOrderHandler): code=${e.code}, message=${e.message}');
      errorMessage = 'Não foi possível concluir a compra da ordem.';
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('MarketplaceController buy error: $e');
      errorMessage = 'Erro inesperado ao processar a compra.';
      throw Exception(errorMessage);
    } finally {
      isLoading = false;
    }
  }
}