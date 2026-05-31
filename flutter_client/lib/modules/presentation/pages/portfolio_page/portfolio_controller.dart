//feito por abdallah e marcelo
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mobx/mobx.dart';

part 'portfolio_controller.g.dart';

class PortfolioController = PortfolioControllerBase with _$PortfolioController;

abstract class PortfolioControllerBase with Store {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  final List<PortfolioPeriod> periods = const [
    PortfolioPeriod('DIA', 'daily'),
    PortfolioPeriod('SEM', 'weekly'),
    PortfolioPeriod('MÊS', 'monthly'),
    PortfolioPeriod('6M', '6months'),
    PortfolioPeriod('YTD', 'ytd'),
  ];

  @observable
  int selectedPeriod = 2;

  @observable
  bool isChartLoading = true;

  @observable
  String? chartError;

  @observable
  ObservableList<PortfolioPoint> points = ObservableList<PortfolioPoint>();

  @action
  void setPeriod(int index) {
    selectedPeriod = index;
    loadPortfolioHistory();
  }

  @action
  Future<void> loadPortfolioHistory() async {
    isChartLoading = true;
    chartError = null;

    try {
      final result = await _functions.httpsCallable('getPortfolioHistory').call(
        {'period': periods[selectedPeriod].value},
      );
      
      final raw = result.data;
      final data = raw is Map && raw['data'] is List
          ? raw['data'] as List
          : <dynamic>[];
          
      final newPoints = data
          .whereType<Map>()
          .map(
            (item) => PortfolioPoint.fromMap(Map<String, dynamic>.from(item)),
          )
    .toList();

      points.clear();
      points.addAll(newPoints);
      isChartLoading = false;
      
    } on FirebaseFunctionsException catch (e) {
      chartError = e.code == 'internal'
          ? 'Não foi possível carregar o gráfico agora.'
          : e.message ?? 'Não foi possível carregar o gráfico.';
      isChartLoading = false;
    } catch (e) {
      chartError = 'Erro inesperado ao carregar o gráfico.';
      isChartLoading = false;
    }
  }
}

class PortfolioPeriod {
  const PortfolioPeriod(this.label, this.value);

  final String label;
  final String value;
}

class PortfolioPoint {
  const PortfolioPoint({required this.timestamp, required this.totalValue});

  final DateTime timestamp;
  final double totalValue;

  String get shortDate =>
      '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';

  factory PortfolioPoint.fromMap(Map<String, dynamic> map) {
    return PortfolioPoint(
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      totalValue: map['totalValue'] is num
          ? (map['totalValue'] as num).toDouble()
          : double.tryParse(map['totalValue']?.toString() ?? '') ?? 0,
    );
  }
}