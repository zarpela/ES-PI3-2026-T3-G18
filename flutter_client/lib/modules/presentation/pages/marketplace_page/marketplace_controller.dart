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
  // ─────────────────────────────────────────────────────────────────────
  // Observables
  // ─────────────────────────────────────────────────────────────────────

  @observable
  String searchQuery = '';

  @observable
  MarketplaceFilter activeFilter = MarketplaceFilter.nova;

  // ─────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────

  @action
  void onSearchChanged(String value) => searchQuery = value;

  @action
  void onFilterSelected(MarketplaceFilter filter) => activeFilter = filter;
}