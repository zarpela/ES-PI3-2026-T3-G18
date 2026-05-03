// feito por pedro henrique bonetto

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  HomeController();

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'southamerica-east1');

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
      final callable = _functions.httpsCallable('getStartups');

      final result = await callable.call(<String, dynamic>{});
      final data = result.data;

      debugPrint('getStartups result type: ${data.runtimeType}');
      debugPrint('getStartups result: $data');

      if (data is List) {
        _allStartups = data.map<Map<String, dynamic>>((e) {
          final item = Map<String, dynamic>.from(e as Map);

          return {
            'id': item['id'],
            'name': item['name'] ?? item['nome_startup'] ?? '',
            'description':
                item['description'] ?? item['descricao'] ?? item['descrição'] ?? '',
            'tagline': item['tagline'] ?? '',
            'stage': item['stage'] ?? item['estagio'] ?? '',
            'sector': _normalizeSector(
              (item['sector'] ?? item['setor'] ?? '').toString(),
            ),
            'raised': _formatRaised(item['raised'] ?? item['capitalAportado']),
            'roi': (item['roi'] ?? item['status'] ?? '').toString(),
            'raw': item,
          };
        }).toList();
      } else if (data is Map && data['data'] is List) {
        _allStartups = (data['data'] as List).map<Map<String, dynamic>>((e) {
          final item = Map<String, dynamic>.from(e as Map);

          return {
            'id': item['id'],
            'name': item['name'] ?? item['nome_startup'] ?? '',
            'description':
                item['description'] ?? item['descricao'] ?? item['descrição'] ?? '',
            'tagline': item['tagline'] ?? '',
            'stage': item['stage'] ?? item['estagio'] ?? '',
            'sector': _normalizeSector(
              (item['sector'] ?? item['setor'] ?? '').toString(),
            ),
            'raised': _formatRaised(item['raised'] ?? item['capitalAportado']),
            'roi': (item['roi'] ?? item['status'] ?? '').toString(),
            'raw': item,
          };
        }).toList();
      } else {
        _allStartups = [];
      }

      _applyFilters();
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        'FirebaseFunctionsException: code=${e.code}, message=${e.message}, details=${e.details}',
      );
      errorMessage = 'Não foi possível carregar as startups.';
      _allStartups = [];
      startups = [];
    } catch (e) {
      debugPrint('HomeController error: $e');
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
    if (value == null) return 'R\$ 0';
    final raw = value.toString();
    return raw.contains('R\$') ? raw : 'R\$ $raw';
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