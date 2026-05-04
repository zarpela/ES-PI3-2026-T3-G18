// feito por pedro henrique bonetto

import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_photo_storage.dart' as profile_photo_storage;

class HomeController extends ChangeNotifier {
  HomeController(this._dio, [FirebaseAuth? auth, ImagePicker? imagePicker])
    : _auth = auth,
      _imagePicker = imagePicker ?? ImagePicker();

  final Dio _dio;
  final FirebaseAuth? _auth;
  final ImagePicker _imagePicker;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> _allStartups = [];
  List<Map<String, dynamic>> startups = [];
  List<Map<String, dynamic>> walletTokens = [];
  List<Map<String, dynamic>> recentTransactions = [];

  Map<String, dynamic>? wallet;
  Uint8List? localProfilePhotoBytes;
  bool isBalanceVisible = true;
  bool isStartupsLoading = false;
  bool isWalletLoading = false;
  bool isProfilePhotoLoading = false;
  String? errorMessage;
  String? walletErrorMessage;
  String selectedFilter = 'all';
  String selectedSort = 'relevance';
  double? investedBalance;
  double? estimatedReturnPercent;

  bool get isLoading =>
      isStartupsLoading || isWalletLoading || isProfilePhotoLoading;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  int get totalStartups => _allStartups.length;

  int get openRounds => _allStartups.where((s) {
    final stage = (s['stage'] ?? '').toString().trim();
    return stage.isNotEmpty;
  }).length;

  int get totalSectors {
    final sectors = _allStartups
        .map((e) => (e['sector'] ?? '').toString().trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    return sectors.length;
  }

  Map<String, dynamic>? get featuredStartup =>
      startups.isNotEmpty ? startups.first : null;

  ImageProvider? get profileImage {
    if (localProfilePhotoBytes != null) {
      return MemoryImage(localProfilePhotoBytes!);
    }

    final photoUrl = currentUser?.photoURL?.trim() ?? '';
    if (photoUrl.isNotEmpty) {
      return NetworkImage(photoUrl);
    }

    return null;
  }

  String get userLabel {
    final displayName = currentUser?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final email = currentUser?.email?.trim() ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return 'Usuario';
  }

  String get userInitials {
    final parts = userLabel
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'MI';
    }

    if (parts.length == 1) {
      final first = parts.first.toUpperCase();
      return first.length >= 2 ? first.substring(0, 2) : first;
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  double get availableBalance => _asDouble(wallet?['balance']);

  String get balanceLabel {
    if (!isBalanceVisible) {
      return 'R\$ ******';
    }

    if (investedBalance == null) {
      return 'R\$ --';
    }

    return _formatCurrency(investedBalance!);
  }

  String get availableBalanceLabel {
    if (!isBalanceVisible) {
      return 'R\$ ******';
    }

    if (isWalletLoading && wallet == null) {
      return 'R\$ --';
    }

    return formatCurrencyAmount(availableBalance);
  }

  String get performanceLabel {
    if (estimatedReturnPercent != null) {
      return 'Retorno estimado ${_formatPercent(estimatedReturnPercent!)}';
    }

    if (wallet != null && (investedBalance ?? 0) <= 0) {
      return 'Carteira pronta para investir';
    }

    if (walletErrorMessage != null) {
      return 'Atualize para sincronizar';
    }

    if (currentUser == null) {
      return 'Explore novas oportunidades';
    }

    return 'Sincronizando carteira';
  }

  String get walletVariationLabel {
    if (isWalletLoading && wallet == null) {
      return 'Sincronizando carteira';
    }

    final value = estimatedReturnPercent ?? 0;
    final normalized = value.toStringAsFixed(1).replaceAll('.', ',');
    final sign = value >= 0 ? '+' : '';
    return '~ $sign$normalized% este mes';
  }

  List<Map<String, dynamic>> get recentTransactionsPreview {
    final source = recentTransactions.where((transaction) {
      if (transaction['type'] != 'CREATE_WALLET') {
        return true;
      }

      return recentTransactions.length == 1;
    });

    return source.take(4).toList();
  }

  String get featuredStartupName {
    final name = (featuredStartup?['name'] ?? '').toString().trim();
    return name.isEmpty ? 'Oportunidade em destaque' : name;
  }

  String get featuredStartupDescription {
    final description = (featuredStartup?['description'] ?? '')
        .toString()
        .trim();
    if (description.isNotEmpty) {
      return description;
    }

    final tagline = (featuredStartup?['tagline'] ?? '').toString().trim();
    if (tagline.isNotEmpty) {
      return tagline;
    }

    return 'Conheca a oportunidade em destaque disponivel na plataforma.';
  }

  void toggleBalanceVisibility() {
    isBalanceVisible = !isBalanceVisible;
    notifyListeners();
  }

  Future<void> load() async {
    errorMessage = null;
    walletErrorMessage = null;
    isProfilePhotoLoading = true;
    isStartupsLoading = true;
    isWalletLoading = true;
    notifyListeners();

    await Future.wait([
      _loadProfilePhoto(),
      _loadStartups(),
      _loadWallet(),
    ]);
  }

  Future<void> refresh() async {
    await load();
  }

  Future<bool> selectProfilePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 88,
      );

      if (pickedFile == null) {
        return false;
      }

      final bytes = await profile_photo_storage.saveProfilePhoto(
        _profilePhotoStorageKey,
        pickedFile,
      );
      localProfilePhotoBytes = bytes;

      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('HomeController photo error: $error');
      return false;
    }
  }

  Future<String> addBalance(double amount) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Usuario nao autenticado.');
    }

    try {
      final response = await _dio.post(
        'wallet/add-balance',
        data: {'userId': user.uid, 'amount': amount},
        options: await _authorizedOptions(),
      );

      _applyWalletData(response.data);
      await _loadWalletHistory();
      notifyListeners();
      return 'Deposito realizado com sucesso.';
    } on DioException catch (error) {
      throw Exception(_extractWalletError(error));
    }
  }

  Future<String> withdrawBalance(double amount) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Usuario nao autenticado.');
    }

    if (amount > availableBalance) {
      throw Exception('Saldo insuficiente para concluir o saque.');
    }

    try {
      final response = await _dio.post(
        'wallet/withdraw-balance',
        data: {'userId': user.uid, 'amount': amount},
        options: await _authorizedOptions(),
      );

      _applyWalletData(response.data);
      await _loadWalletHistory();
      notifyListeners();
      return 'Saque realizado com sucesso.';
    } on DioException catch (error) {
      throw Exception(_extractWalletError(error));
    }
  }

  void onSearchChanged(String _) {
    _applyFilters();
  }

  void setFilter(String value) {
    selectedFilter = value;
    _applyFilters();
  }

  void setSort(String value) {
    selectedSort = value;
    _applyFilters();
  }

  void resetFilters() {
    selectedFilter = 'all';
    selectedSort = 'relevance';
    searchController.clear();
    _applyFilters();
  }

  int sectorCount(String sector) {
    return _allStartups.where((s) {
      final current = (s['sector'] ?? '').toString().trim().toLowerCase();
      return current == sector;
    }).length;
  }

  String formatCurrencyAmount(double value) {
    return _formatCurrency(value);
  }

  Future<void> _loadProfilePhoto() async {
    final user = currentUser;
    if (user == null) {
      localProfilePhotoBytes = null;
      isProfilePhotoLoading = false;
      notifyListeners();
      return;
    }

    try {
      localProfilePhotoBytes = await profile_photo_storage.loadProfilePhoto(
        _profilePhotoStorageKey,
      );
    } catch (error) {
      debugPrint('HomeController photo load error: $error');
      localProfilePhotoBytes = null;
      await profile_photo_storage.clearProfilePhoto(_profilePhotoStorageKey);
    } finally {
      isProfilePhotoLoading = false;
      notifyListeners();
    }
  }

  String get _profilePhotoStorageKey => currentUser?.uid ?? 'guest';

  Future<void> _loadStartups() async {
    try {
      final callable = _functions.httpsCallable('getStartups');
      final result = await callable.call(<String, dynamic>{});
      final data = result.data;

      if (data is List) {
        _allStartups = data
            .map<Map<String, dynamic>>(
              (e) => _mapStartup(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      } else if (data is Map && data['data'] is List) {
        _allStartups = (data['data'] as List)
            .map<Map<String, dynamic>>(
              (e) => _mapStartup(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      } else {
        _allStartups = [];
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        'FirebaseFunctionsException: code=${e.code}, message=${e.message}, details=${e.details}',
      );
      errorMessage = 'Nao foi possivel carregar as startups.';
      _allStartups = [];
      startups = [];
    } catch (e) {
      debugPrint('HomeController startup error: $e');
      errorMessage = 'Erro inesperado ao carregar o catalogo.';
      _allStartups = [];
      startups = [];
    } finally {
      _applyFilters(notify: false);
      _syncPortfolioHighlights();
      isStartupsLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _mapStartup(Map<String, dynamic> item) {
    return {
      'id': item['id'],
      'name': item['name'] ?? item['nome_startup'] ?? '',
      'description':
          item['description'] ?? item['descricao'] ?? item['descricao'] ?? '',
      'tagline': item['tagline'] ?? '',
      'stage': item['stage'] ?? item['estagio'] ?? '',
      'sector': _normalizeSector(
        (item['sector'] ?? item['setor'] ?? '').toString(),
      ),
      'raised': _formatRaised(item['raised'] ?? item['capitalAportado']),
      'roi': (item['roi'] ?? item['status'] ?? '').toString(),
      'raw': item,
    };
  }

  Future<void> _loadWallet() async {
    try {
      final user = currentUser;
      if (user == null) {
        wallet = null;
        walletTokens = [];
        recentTransactions = [];
        investedBalance = null;
        estimatedReturnPercent = null;
        walletErrorMessage = null;
        return;
      }

      try {
        final response = await _dio.get(
          'wallet/${user.uid}',
          options: await _authorizedOptions(),
        );
        _applyWalletData(response.data);
        await _loadWalletHistory();
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          await _createWallet(user.uid);
          return;
        }

        debugPrint('HomeController wallet error: ${e.message}');
        walletErrorMessage = _extractWalletError(e);
      } catch (e) {
        debugPrint('HomeController unexpected wallet error: $e');
        walletErrorMessage = 'Nao foi possivel carregar a carteira.';
      }
    } finally {
      _syncPortfolioHighlights();
      isWalletLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createWallet(String userId) async {
    try {
      final response = await _dio.post(
        'wallet/create',
        data: {'userId': userId},
        options: await _authorizedOptions(),
      );
      _applyWalletData(response.data);
      await _loadWalletHistory();
    } on DioException catch (e) {
      debugPrint('HomeController wallet creation error: ${e.message}');
      walletErrorMessage = _extractWalletError(e);
    } catch (e) {
      debugPrint('HomeController unexpected wallet creation error: $e');
      walletErrorMessage = 'Nao foi possivel preparar a carteira.';
    }
  }

  Future<void> _loadWalletHistory() async {
    final user = currentUser;
    if (user == null) {
      recentTransactions = [];
      return;
    }

    try {
      final response = await _dio.get(
        'market/history/${user.uid}',
        options: await _authorizedOptions(),
      );
      final transactions = response.data is Map && response.data['transactions'] is List
          ? List<Map<String, dynamic>>.from(
              (response.data['transactions'] as List).map(
                (item) => Map<String, dynamic>.from(item as Map),
              ),
            )
          : <Map<String, dynamic>>[];

      transactions.sort((left, right) {
        final leftDate = DateTime.tryParse(
          (left['createdAt'] ?? '').toString(),
        );
        final rightDate = DateTime.tryParse(
          (right['createdAt'] ?? '').toString(),
        );

        if (leftDate == null && rightDate == null) {
          return 0;
        }
        if (leftDate == null) {
          return 1;
        }
        if (rightDate == null) {
          return -1;
        }

        return rightDate.compareTo(leftDate);
      });

      recentTransactions = transactions;
    } on DioException catch (e) {
      debugPrint('HomeController history error: ${e.message}');
      recentTransactions = [];
    } catch (e) {
      debugPrint('HomeController unexpected history error: $e');
      recentTransactions = [];
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = await currentUser?.getIdToken();

    return Options(
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
    );
  }

  void _applyWalletData(dynamic rawResponse) {
    final response = rawResponse is Map
        ? Map<String, dynamic>.from(rawResponse)
        : <String, dynamic>{};
    final walletData = response['wallet'];
    final normalizedWallet = walletData is Map
        ? Map<String, dynamic>.from(walletData)
        : <String, dynamic>{};

    wallet = normalizedWallet;
    walletTokens = ((normalizedWallet['tokens'] as List?) ?? [])
        .whereType<Map>()
        .map((token) => Map<String, dynamic>.from(token))
        .toList();
    investedBalance = walletTokens.fold<double>(
      0,
      (total, token) =>
          total +
          (_asDouble(token['quantity']) * _asDouble(token['averagePrice'])),
    );
    walletErrorMessage = null;
  }

  void _syncPortfolioHighlights() {
    estimatedReturnPercent = _calculateWeightedEstimatedReturn();
  }

  double? _calculateWeightedEstimatedReturn() {
    if (walletTokens.isEmpty || _allStartups.isEmpty) {
      return null;
    }

    double weightedTotal = 0;
    double totalWeight = 0;

    for (final token in walletTokens) {
      final weight =
          _asDouble(token['quantity']) * _asDouble(token['averagePrice']);
      if (weight <= 0) {
        continue;
      }

      final startup = _findStartupForToken(token);
      final roi = _parsePercentage(startup?['roi']);
      if (roi == null) {
        continue;
      }

      weightedTotal += roi * weight;
      totalWeight += weight;
    }

    if (totalWeight <= 0) {
      return null;
    }

    return weightedTotal / totalWeight;
  }

  Map<String, dynamic>? _findStartupForToken(Map<String, dynamic> token) {
    final startupId = (token['startupId'] ?? '').toString().trim();
    final startupName = (token['startupName'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    for (final startup in _allStartups) {
      final currentId = (startup['id'] ?? '').toString().trim();
      final currentName = (startup['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (startupId.isNotEmpty && startupId == currentId) {
        return startup;
      }

      if (startupName.isNotEmpty && startupName == currentName) {
        return startup;
      }
    }

    return null;
  }

  String _extractWalletError(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData is Map) {
      final message = responseData['message'] ?? responseData['error'];
      if (message != null) {
        return message.toString();
      }
    }

    return 'Nao foi possivel carregar a carteira.';
  }

  void _applyFilters({bool notify = true}) {
    final query = searchController.text.trim().toLowerCase();

    final result = _allStartups.where((startup) {
      final name = (startup['name'] ?? '').toString().toLowerCase();
      final description = (startup['description'] ?? '')
          .toString()
          .toLowerCase();
      final tagline = (startup['tagline'] ?? '').toString().toLowerCase();
      final sector = (startup['sector'] ?? '').toString().trim().toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          name.contains(query) ||
          description.contains(query) ||
          tagline.contains(query);

      final matchesFilter = selectedFilter == 'all' || sector == selectedFilter;

      return matchesQuery && matchesFilter;
    }).toList();

    switch (selectedSort) {
      case 'name':
        result.sort(
          (a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo(
            (b['name'] ?? '').toString().toLowerCase(),
          ),
        );
        break;
      case 'stage':
        result.sort(
          (a, b) => (a['stage'] ?? '').toString().toLowerCase().compareTo(
            (b['stage'] ?? '').toString().toLowerCase(),
          ),
        );
        break;
      case 'raised':
        result.sort(
          (a, b) => _parseMoney(
            (b['raised'] ?? '').toString(),
          ).compareTo(_parseMoney((a['raised'] ?? '').toString())),
        );
        break;
      case 'relevance':
      default:
        break;
    }

    startups = result;
    if (notify) {
      notifyListeners();
    }
  }

  String _normalizeSector(String value) {
    final lower = value.trim().toLowerCase();

    switch (lower) {
      case 'agrotech':
      case 'agtech':
        return 'agtech';
      case 'fintech':
        return 'fintech';
      case 'health':
      case 'healthtech':
        return 'healthtech';
      case 'edtech':
        return 'edtech';
      default:
        return lower;
    }
  }

  String _formatRaised(dynamic value) {
    if (value == null) {
      return 'R\$ 0';
    }

    final raw = value.toString();
    return raw.contains('R\$') ? raw : 'R\$ $raw';
  }

  String _formatCurrency(double value) {
    final cents = (value * 100).round();
    final absCents = cents.abs();
    final whole = absCents ~/ 100;
    final decimal = (absCents % 100).toString().padLeft(2, '0');
    final digits = whole.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    final prefix = cents < 0 ? '-R\$ ' : 'R\$ ';
    return '$prefix${buffer.toString()},$decimal';
  }

  String _formatPercent(double value) {
    final normalized = value.toStringAsFixed(1).replaceAll('.', ',');
    return '${value >= 0 ? '+' : ''}$normalized%';
  }

  double _parseMoney(String value) {
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.-]'), '');

    return double.tryParse(cleaned) ?? 0;
  }

  double? _parsePercentage(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    final match = RegExp(r'[-+]?\d+(?:[.,]\d+)?').firstMatch(text);
    if (match == null) {
      return null;
    }

    final normalized = match.group(0)!.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
