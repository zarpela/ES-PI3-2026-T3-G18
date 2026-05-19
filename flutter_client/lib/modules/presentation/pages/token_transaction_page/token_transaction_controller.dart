//feito por marcelo
import 'package:mobx/mobx.dart';

part 'token_transaction_controller.g.dart';

enum TransactionType { buy, sell }

class TokenTransactionController = _TokenTransactionControllerBase with _$TokenTransactionController;

abstract class _TokenTransactionControllerBase with Store {
  final TransactionType transactionType;

  _TokenTransactionControllerBase({required this.transactionType});

  @observable
  bool isLoading = true;

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

  @computed
  double get totalValue => quantity * pricePerToken;

  @action
  Future<void> loadAssetData(String assetId) async { //TODO: trocar a funcao inteira, puxar do  backend
    isLoading = true;

    try {
      await Future.delayed(const Duration(seconds: 1)); 

      assetName = 'Imóvel Solar Residencial'; 
      availableFiatBalance = 4250.00;
      availableTokenBalance = 125;
      

      pricePerToken = transactionType == TransactionType.buy ? 100.00 : 150.00;
      quantity = transactionType == TransactionType.buy ? 15 : 10;

    } catch (e) {

    } finally {
      isLoading = false;
    }
  }

  @action
  void incrementQuantity() {
    if (transactionType == TransactionType.sell && quantity >= availableTokenBalance) return;
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
}