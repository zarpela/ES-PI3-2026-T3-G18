// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MarketplaceController on _MarketplaceControllerBase, Store {
  late final _$searchQueryAtom = Atom(
    name: '_MarketplaceControllerBase.searchQuery',
    context: context,
  );

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$activeFilterAtom = Atom(
    name: '_MarketplaceControllerBase.activeFilter',
    context: context,
  );

  @override
  MarketplaceFilter get activeFilter {
    _$activeFilterAtom.reportRead();
    return super.activeFilter;
  }

  @override
  set activeFilter(MarketplaceFilter value) {
    _$activeFilterAtom.reportWrite(value, super.activeFilter, () {
      super.activeFilter = value;
    });
  }

  late final _$sellOrdersAtom = Atom(
    name: '_MarketplaceControllerBase.sellOrders',
    context: context,
  );

  @override
  ObservableList<Map<String, dynamic>> get sellOrders {
    _$sellOrdersAtom.reportRead();
    return super.sellOrders;
  }

  @override
  set sellOrders(ObservableList<Map<String, dynamic>> value) {
    _$sellOrdersAtom.reportWrite(value, super.sellOrders, () {
      super.sellOrders = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_MarketplaceControllerBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_MarketplaceControllerBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$fetchSellOrdersAsyncAction = AsyncAction(
    '_MarketplaceControllerBase.fetchSellOrders',
    context: context,
  );

  @override
  Future<void> fetchSellOrders() {
    return _$fetchSellOrdersAsyncAction.run(() => super.fetchSellOrders());
  }

  late final _$getStartupByIdAsyncAction = AsyncAction(
    '_MarketplaceControllerBase.getStartupById',
    context: context,
  );

  @override
  Future<Map<String, dynamic>> getStartupById(String startupId) {
    return _$getStartupByIdAsyncAction.run(
      () => super.getStartupById(startupId),
    );
  }

  late final _$buyTokensAsyncAction = AsyncAction(
    '_MarketplaceControllerBase.buyTokens',
    context: context,
  );

  @override
  Future<void> buyTokens({
    required String startupId,
    required int quantity,
    required double price,
  }) {
    return _$buyTokensAsyncAction.run(
      () => super.buyTokens(
        startupId: startupId,
        quantity: quantity,
        price: price,
      ),
    );
  }

  late final _$_MarketplaceControllerBaseActionController = ActionController(
    name: '_MarketplaceControllerBase',
    context: context,
  );

  @override
  void onSearchChanged(String value) {
    final _$actionInfo = _$_MarketplaceControllerBaseActionController
        .startAction(name: '_MarketplaceControllerBase.onSearchChanged');
    try {
      return super.onSearchChanged(value);
    } finally {
      _$_MarketplaceControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onFilterSelected(MarketplaceFilter filter) {
    final _$actionInfo = _$_MarketplaceControllerBaseActionController
        .startAction(name: '_MarketplaceControllerBase.onFilterSelected');
    try {
      return super.onFilterSelected(filter);
    } finally {
      _$_MarketplaceControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
searchQuery: ${searchQuery},
activeFilter: ${activeFilter},
sellOrders: ${sellOrders},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
