// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_transaction_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TokenTransactionController on _TokenTransactionControllerBase, Store {
  Computed<double>? _$totalValueComputed;

  @override
  double get totalValue => (_$totalValueComputed ??= Computed<double>(
    () => super.totalValue,
    name: '_TokenTransactionControllerBase.totalValue',
  )).value;

  late final _$isLoadingAtom = Atom(
    name: '_TokenTransactionControllerBase.isLoading',
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

  late final _$assetNameAtom = Atom(
    name: '_TokenTransactionControllerBase.assetName',
    context: context,
  );

  @override
  String get assetName {
    _$assetNameAtom.reportRead();
    return super.assetName;
  }

  @override
  set assetName(String value) {
    _$assetNameAtom.reportWrite(value, super.assetName, () {
      super.assetName = value;
    });
  }

  late final _$quantityAtom = Atom(
    name: '_TokenTransactionControllerBase.quantity',
    context: context,
  );

  @override
  int get quantity {
    _$quantityAtom.reportRead();
    return super.quantity;
  }

  @override
  set quantity(int value) {
    _$quantityAtom.reportWrite(value, super.quantity, () {
      super.quantity = value;
    });
  }

  late final _$pricePerTokenAtom = Atom(
    name: '_TokenTransactionControllerBase.pricePerToken',
    context: context,
  );

  @override
  double get pricePerToken {
    _$pricePerTokenAtom.reportRead();
    return super.pricePerToken;
  }

  @override
  set pricePerToken(double value) {
    _$pricePerTokenAtom.reportWrite(value, super.pricePerToken, () {
      super.pricePerToken = value;
    });
  }

  late final _$availableFiatBalanceAtom = Atom(
    name: '_TokenTransactionControllerBase.availableFiatBalance',
    context: context,
  );

  @override
  double get availableFiatBalance {
    _$availableFiatBalanceAtom.reportRead();
    return super.availableFiatBalance;
  }

  @override
  set availableFiatBalance(double value) {
    _$availableFiatBalanceAtom.reportWrite(
      value,
      super.availableFiatBalance,
      () {
        super.availableFiatBalance = value;
      },
    );
  }

  late final _$availableTokenBalanceAtom = Atom(
    name: '_TokenTransactionControllerBase.availableTokenBalance',
    context: context,
  );

  @override
  int get availableTokenBalance {
    _$availableTokenBalanceAtom.reportRead();
    return super.availableTokenBalance;
  }

  @override
  set availableTokenBalance(int value) {
    _$availableTokenBalanceAtom.reportWrite(
      value,
      super.availableTokenBalance,
      () {
        super.availableTokenBalance = value;
      },
    );
  }

  late final _$loadAssetDataAsyncAction = AsyncAction(
    '_TokenTransactionControllerBase.loadAssetData',
    context: context,
  );

  @override
  Future<void> loadAssetData(String assetId) {
    return _$loadAssetDataAsyncAction.run(() => super.loadAssetData(assetId));
  }

  late final _$_TokenTransactionControllerBaseActionController =
      ActionController(
        name: '_TokenTransactionControllerBase',
        context: context,
      );

  @override
  void incrementQuantity() {
    final _$actionInfo = _$_TokenTransactionControllerBaseActionController
        .startAction(name: '_TokenTransactionControllerBase.incrementQuantity');
    try {
      return super.incrementQuantity();
    } finally {
      _$_TokenTransactionControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrementQuantity() {
    final _$actionInfo = _$_TokenTransactionControllerBaseActionController
        .startAction(name: '_TokenTransactionControllerBase.decrementQuantity');
    try {
      return super.decrementQuantity();
    } finally {
      _$_TokenTransactionControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updatePricePerToken(double newPrice) {
    final _$actionInfo = _$_TokenTransactionControllerBaseActionController
        .startAction(
          name: '_TokenTransactionControllerBase.updatePricePerToken',
        );
    try {
      return super.updatePricePerToken(newPrice);
    } finally {
      _$_TokenTransactionControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
assetName: ${assetName},
quantity: ${quantity},
pricePerToken: ${pricePerToken},
availableFiatBalance: ${availableFiatBalance},
availableTokenBalance: ${availableTokenBalance},
totalValue: ${totalValue}
    ''';
  }
}
