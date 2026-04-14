// feito por pedro henrique bonetto

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  final Dio _dio;

  HomeController(this._dio);

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> _allStartups = [];
  List<Map<String, dynamic>> startups = [];

  bool isLoading = false;
  String? errorMessage;
  String selectedFilter = 'all';
  String selectedSort = 'relevance';

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

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/api/get-startups');
      final data = response.data;

      if (data is List) {
        _allStartups = data.map((e) {
    final item = Map<String, dynamic>.from(e as Map);

    return {
      'id': item['id'],
      'name': item['nome_startup'] ?? '',
      'description': item['descricao'] ?? item['descrição'] ?? '',
      'stage': item['estagio'] ?? '',
      'sector': (item['setor'] ?? '').toString().toLowerCase(),
      'raised': 'R\$ ${item['capitalAportado'] ?? 0}',
      'roi': item['status'] ?? '',
      'raw': item,
    };
  }).toList();
} else {
  _allStartups = [];
}

_applyFilters();
    } on DioException {
      errorMessage = 'Não foi possível carregar as startups.';
      _allStartups = [];
      startups = [];
    } catch (_) {
      errorMessage = 'Erro inesperado ao carregar o catálogo.';
      _allStartups = [];
      startups = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
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

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    final result = _allStartups.where((startup) {
      final name = (startup['name'] ?? '').toString().toLowerCase();
      final description = (startup['description'] ?? '').toString().toLowerCase();
      final tagline = (startup['tagline'] ?? '').toString().toLowerCase();
      final sector = (startup['sector'] ?? '').toString().trim().toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          description.contains(query) ||
          tagline.contains(query);

      final matchesFilter =
          selectedFilter == 'all' || sector == selectedFilter;

      return matchesQuery && matchesFilter;
    }).toList();

    switch (selectedSort) {
      case 'name':
        result.sort(
          (a, b) => (a['name'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['name'] ?? '').toString().toLowerCase()),
        );
        break;
      case 'stage':
        result.sort(
          (a, b) => (a['stage'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['stage'] ?? '').toString().toLowerCase()),
        );
        break;
      case 'raised':
        result.sort(
          (a, b) => _parseMoney((b['raised'] ?? '').toString())
              .compareTo(_parseMoney((a['raised'] ?? '').toString())),
        );
        break;
      case 'relevance':
      default:
        break;
    }

    startups = result;
    notifyListeners();
  }

  double _parseMoney(String value) {
    final cleaned = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');

    return double.tryParse(cleaned) ?? 0;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}