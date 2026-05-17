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
activeFilter: ${activeFilter}
    ''';
  }
}
