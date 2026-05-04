// feito por pedro henrique bonetto

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic>? wallet;
  Uint8List? localProfilePhotoBytes;
  bool isBalanceVisible = true;
  bool isLoading = false;
  String? errorMessage;
  String? walletErrorMessage;
  String selectedFilter = 'all';
  String selectedSort = 'relevance';
  double? investedBalance;
  double? estimatedReturnPercent;

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

  String get balanceLabel {
    if (!isBalanceVisible) {
      return 'R\$ ******';
    }

    if (investedBalance == null) {
      return 'R\$ --';
    }

    return _formatCurrency(investedBalance!);
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
    isLoading = true;
    errorMessage = null;
    walletErrorMessage = null;
    notifyListeners();

    try {
      await _loadProfilePhoto();
      await _loadStartups();
      await _loadWallet();
      _applyFilters(notify: false);
      _syncPortfolioHighlights();
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

      final bytes = await pickedFile.readAsBytes();
      localProfilePhotoBytes = bytes;

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_profilePhotoKey, base64Encode(bytes));

      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('HomeController photo error: $error');
      return false;
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

  Future<void> _loadProfilePhoto() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedPhoto = preferences.getString(_profilePhotoKey);

    if (encodedPhoto == null || encodedPhoto.isEmpty) {
      localProfilePhotoBytes = null;
      return;
    }

    try {
      localProfilePhotoBytes = base64Decode(encodedPhoto);
    } catch (_) {
      localProfilePhotoBytes = null;
      await preferences.remove(_profilePhotoKey);
    }
  }

  String get _profilePhotoKey =>
      'home_profile_photo_${currentUser?.uid ?? 'guest'}';

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
    }
  }

  Map<String, dynamic> _mapStartup(Map<String, dynamic> item) {
    return {
      'id': item['id'],
      'name': item['name'] ?? item['nome_startup'] ?? '',
      'description':
          item['description'] ?? item['descricao'] ?? item['descriÃ§Ã£o'] ?? '',
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
    wallet = null;
    walletTokens = [];
    investedBalance = null;
    estimatedReturnPercent = null;

    final user = currentUser;
    if (user == null) {
      walletErrorMessage = null;
      return;
    }

    try {
      final response = await _dio.get(
        'wallet/${user.uid}',
        options: await _authorizedOptions(),
      );
      _applyWalletData(response.data);
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
  }

  Future<void> _createWallet(String userId) async {
    try {
      final response = await _dio.post(
        'wallet/create',
        data: {'userId': userId},
        options: await _authorizedOptions(),
      );
      _applyWalletData(response.data);
    } on DioException catch (e) {
      debugPrint('HomeController wallet creation error: ${e.message}');
      walletErrorMessage = _extractWalletError(e);
    } catch (e) {
      debugPrint('HomeController unexpected wallet creation error: $e');
      walletErrorMessage = 'Nao foi possivel preparar a carteira.';
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = await currentUser?.getIdToken(true);

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
