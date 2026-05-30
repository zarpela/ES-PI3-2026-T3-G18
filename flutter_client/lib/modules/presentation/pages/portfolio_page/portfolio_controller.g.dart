// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PortfolioController on PortfolioControllerBase, Store {
  late final _$selectedPeriodAtom = Atom(
    name: 'PortfolioControllerBase.selectedPeriod',
    context: context,
  );

  @override
  int get selectedPeriod {
    _$selectedPeriodAtom.reportRead();
    return super.selectedPeriod;
  }

  @override
  set selectedPeriod(int value) {
    _$selectedPeriodAtom.reportWrite(value, super.selectedPeriod, () {
      super.selectedPeriod = value;
    });
  }

  late final _$isChartLoadingAtom = Atom(
    name: 'PortfolioControllerBase.isChartLoading',
    context: context,
  );

  @override
  bool get isChartLoading {
    _$isChartLoadingAtom.reportRead();
    return super.isChartLoading;
  }

  @override
  set isChartLoading(bool value) {
    _$isChartLoadingAtom.reportWrite(value, super.isChartLoading, () {
      super.isChartLoading = value;
    });
  }

  late final _$chartErrorAtom = Atom(
    name: 'PortfolioControllerBase.chartError',
    context: context,
  );

  @override
  String? get chartError {
    _$chartErrorAtom.reportRead();
    return super.chartError;
  }

  @override
  set chartError(String? value) {
    _$chartErrorAtom.reportWrite(value, super.chartError, () {
      super.chartError = value;
    });
  }

  late final _$pointsAtom = Atom(
    name: 'PortfolioControllerBase.points',
    context: context,
  );

  @override
  ObservableList<PortfolioPoint> get points {
    _$pointsAtom.reportRead();
    return super.points;
  }

  @override
  set points(ObservableList<PortfolioPoint> value) {
    _$pointsAtom.reportWrite(value, super.points, () {
      super.points = value;
    });
  }

  late final _$loadPortfolioHistoryAsyncAction = AsyncAction(
    'PortfolioControllerBase.loadPortfolioHistory',
    context: context,
  );

  @override
  Future<void> loadPortfolioHistory() {
    return _$loadPortfolioHistoryAsyncAction.run(
      () => super.loadPortfolioHistory(),
    );
  }

  late final _$PortfolioControllerBaseActionController = ActionController(
    name: 'PortfolioControllerBase',
    context: context,
  );

  @override
  void setPeriod(int index) {
    final _$actionInfo = _$PortfolioControllerBaseActionController.startAction(
      name: 'PortfolioControllerBase.setPeriod',
    );
    try {
      return super.setPeriod(index);
    } finally {
      _$PortfolioControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedPeriod: ${selectedPeriod},
isChartLoading: ${isChartLoading},
chartError: ${chartError},
points: ${points}
    ''';
  }
}
