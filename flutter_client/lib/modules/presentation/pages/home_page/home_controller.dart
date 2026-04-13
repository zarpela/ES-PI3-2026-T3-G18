
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class StartupModel {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String sector;
  final String stage;
  final String raised;
  final int investors;
  final String roi;
  final List<String> tags;
  final String logoText;
  final Color logoBackground;
  final Color logoForeground;
  final Map<String, dynamic> raw;

  const StartupModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.sector,
    required this.stage,
    required this.raised,
    required this.investors,
    required this.roi,
    required this.tags,
    required this.logoText,
    required this.logoBackground,
    required this.logoForeground,
    required this.raw,
  });

  factory StartupModel.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    String pickString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = normalized[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return fallback;
    }

    int pickInt(List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final value = normalized[key];
        if (value is int) return value;
        if (value is double) return value.round();
        if (value != null) {
          final parsed = int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9-]'), ''));
          if (parsed != null) return parsed;
        }
      }
      return fallback;
    }

    List<String> pickTags(List<String> keys) {
      for (final key in keys) {
        final value = normalized[key];
        if (value is List) {
          return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
        }
        if (value is String && value.trim().isNotEmpty) {
          return value
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
      return const [];
    }

    String formatMoney(dynamic value) {
      if (value == null) return 'R\$ 0';
      if (value is num) {
        if (value >= 1000000) {
          final inMillions = value / 1000000;
          final clean = inMillions % 1 == 0 ? inMillions.toInt().toString() : inMillions.toStringAsFixed(1).replaceAll('.', ',');
          return 'R\$ ${clean}M';
        }
        if (value >= 1000) {
          final inThousands = value / 1000;
          final clean = inThousands % 1 == 0 ? inThousands.toInt().toString() : inThousands.toStringAsFixed(1).replaceAll('.', ',');
          return 'R\$ ${clean}K';
        }
        return 'R\$ ${value.toString()}';
      }
      final text = value.toString().trim();
      if (text.isEmpty) return 'R\$ 0';
      if (text.contains('R\$')) return text;
      return 'R\$ $text';
    }

    String formatPercent(dynamic value) {
      if (value == null) return '+0%';
      if (value is num) return '${value >= 0 ? '+' : ''}${value.toString()}%';
      final text = value.toString().trim();
      if (text.isEmpty) return '+0%';
      if (text.contains('%')) return text.startsWith('+') || text.startsWith('-') ? text : '+$text';
      return text.startsWith('+') || text.startsWith('-') ? '$text%' : '+$text%';
    }

    Color bgFromSector(String sector) {
      switch (sector) {
        case 'fintech': return const Color(0xFFFEF3C7);
        case 'healthtech': return const Color(0xFFDCFCE7);
        case 'agtech': return const Color(0xFFD1FAE5);
        case 'edtech': return const Color(0xFFDBEAFE);
        case 'logtech': return const Color(0xFFEDE9FE);
        default: return const Color(0xFFF3F4F6);
      }
    }

    Color fgFromSector(String sector) {
      switch (sector) {
        case 'fintech': return const Color(0xFFB45309);
        case 'healthtech': return const Color(0xFF166534);
        case 'agtech': return const Color(0xFF065F46);
        case 'edtech': return const Color(0xFF1E40AF);
        case 'logtech': return const Color(0xFF5B21B6);
        default: return const Color(0xFF374151);
      }
    }

    final name = pickString(['name', 'nome', 'startupName', 'titulo'], fallback: 'Startup sem nome');
    final tagline = pickString(['tagline', 'slogan', 'subtitulo', 'headline'], fallback: 'Startup do catálogo');
    final description = pickString(['description', 'descricao', 'about', 'resumo'], fallback: 'Sem descrição informada.');
    final sectorRaw = pickString(['sector', 'setor', 'category', 'categoria'], fallback: 'startup').toLowerCase();
    final sector = {
      'finanças': 'fintech',
      'finance': 'fintech',
      'saude': 'healthtech',
      'saúde': 'healthtech',
      'agro': 'agtech',
      'educacao': 'edtech',
      'educação': 'edtech',
      'logistica': 'logtech',
      'logística': 'logtech',
    }[sectorRaw] ?? sectorRaw;
    final stage = pickString(['stage', 'estagio', 'estágio', 'round'], fallback: 'Seed');
    final raised = formatMoney(normalized['raised'] ?? normalized['captado'] ?? normalized['funding'] ?? normalized['valuation']);
    final investors = pickInt(['investors', 'investidores', 'backers'], fallback: 0);
    final roi = formatPercent(normalized['roi'] ?? normalized['retorno'] ?? normalized['growth']);
    final tags = pickTags(['tags', 'categorias', 'labels']);
    final id = pickString(['id'], fallback: UniqueKey().toString());

    final initials = name
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.characters.first.toUpperCase())
        .join();

    return StartupModel(
      id: id,
      name: name,
      tagline: tagline,
      description: description,
      sector: sector,
      stage: stage,
      raised: raised,
      investors: investors,
      roi: roi,
      tags: tags,
      logoText: initials.isEmpty ? 'ST' : initials,
      logoBackground: bgFromSector(sector),
      logoForeground: fgFromSector(sector),
      raw: normalized,
    );
  }
}

class HomeController extends ChangeNotifier {
  HomeController(this._dio);

  final Dio _dio;
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String selectedFilter = 'all';
  String selectedSort = 'raised';
  bool listView = false;

  List<StartupModel> _allStartups = [];

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get('/getStartups');
      final data = response.data;

      if (data is List) {
        _allStartups = data
            .whereType<Map>()
            .map((item) => StartupModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        throw Exception('Formato inesperado da API');
      }
    } catch (e) {
      errorMessage = 'Não foi possível carregar o catálogo de startups.';
      _allStartups = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<StartupModel> get startups {
    var list = [..._allStartups];

    if (selectedFilter != 'all') {
      list = list.where((s) => s.sector == selectedFilter).toList();
    }

    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.tagline.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query) ||
            s.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    if (selectedSort == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSort == 'stage') {
      const order = {'Serie C': 0, 'Serie B': 1, 'Serie A': 2, 'Seed': 3};
      list.sort((a, b) => (order[a.stage] ?? 99).compareTo(order[b.stage] ?? 99));
    } else {
      list.sort((a, b) => _raisedValue(b.raised).compareTo(_raisedValue(a.raised)));
    }

    return list;
  }

  int get totalStartups => _allStartups.length;

  int get openRounds => _allStartups
      .where((s) => s.stage.toLowerCase().contains('seed') || s.stage.toLowerCase().contains('a'))
      .length;

  int get sectorsCount => _allStartups.map((e) => e.sector).toSet().length;

  int countBySector(String sector) =>
      _allStartups.where((s) => s.sector == sector).length;

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void setSort(String sort) {
    selectedSort = sort;
    notifyListeners();
  }

  void toggleView(bool isList) {
    listView = isList;
    notifyListeners();
  }

  void onSearchChanged(String _) {
    notifyListeners();
  }

  Future<void> refresh() async {
    await load();
  }

  void resetFilters() {
    selectedFilter = 'all';
    selectedSort = 'raised';
    searchController.clear();
    notifyListeners();
  }

  int _raisedValue(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
