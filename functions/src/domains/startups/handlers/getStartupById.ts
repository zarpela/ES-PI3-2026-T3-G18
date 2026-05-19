import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StartupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> startup;

  const StartupDetailsPage({super.key, required this.startup});

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage> {
  static const Color bg = Color(0xFFF7F3FA);
  static const Color surface = Color(0xFFF2ECF8);
  static const Color surfaceStrong = Colors.white;
  static const Color text = Color(0xFF2E2340);
  static const Color textMuted = Color(0xFF7D718F);
  static const Color textLight = Color(0xFF9B90AA);
  static const Color primary = Color(0xFFC2187A);
  static const Color divider = Color(0xFFE7DFF0);

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  Map<String, dynamic>? _fullStartup;
  String? _resolvedVideoUrl;
  String? _resolvedImageUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStartupDetails();
  }

  Future<void> _loadStartupDetails() async {
    try {
      debugPrint('========== STARTUP DETAILS ==========');
      debugPrint('startup keys: ${widget.startup.keys.toList()}');
      debugPrint('startup raw object: ${widget.startup}');

      final startupId =
          '${widget.startup['id'] ?? widget.startup['docId'] ?? widget.startup['startupId'] ?? ''}'
              .trim();

      debugPrint('startupId detectado: $startupId');

      Map<String, dynamic> startupData = Map<String, dynamic>.from(widget.startup);

      if (startupId.isNotEmpty) {
        final callable = _functions.httpsCallable('getStartupById');

        debugPrint('Chamando function getStartupById em southamerica-east1');

        final result = await callable.call(<String, dynamic>{
          'id': startupId,
        });

        final data = result.data;

        debugPrint('getStartupById runtimeType: ${data.runtimeType}');
        debugPrint('getStartupById result: $data');

        if (data is Map && data['data'] is Map) {
          startupData = Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map && data['startup'] is Map) {
          startupData = Map<String, dynamic>.from(data['startup'] as Map);
        } else if (data is Map && data['doc'] is Map) {
          startupData = Map<String, dynamic>.from(data['doc'] as Map);
        } else if (data is Map) {
          startupData = Map<String, dynamic>.from(data);
        } else if (data is List && data.isNotEmpty && data.first is Map) {
          startupData = Map<String, dynamic>.from(data.first as Map);
        }
      } else {
        debugPrint('Nenhum ID encontrado. Usando apenas os dados locais da listagem.');
      }

      debugPrint('startupData final: $startupData');

      final resolvedImage = await _resolveImageFromStartup(startupData);
      final resolvedVideo = await _resolveVideoFromStartup(startupData);

      debugPrint('resolvedImage: $resolvedImage');
      debugPrint('resolvedVideo: $resolvedVideo');
      debugPrint('=====================================');

      if (!mounted) return;

      setState(() {
        _fullStartup = startupData;
        _resolvedImageUrl = resolvedImage;
        _resolvedVideoUrl = resolvedVideo;
        _errorMessage = null;
        _isLoading = false;
      });
    } on FirebaseFunctionsException catch (e) {
      debugPrint('=========== FUNCTION ERROR ===========');
      debugPrint('function: getStartupById');
      debugPrint('region: southamerica-east1');
      debugPrint('startup payload: ${widget.startup}');
      debugPrint('exception code: ${e.code}');
      debugPrint('exception message: ${e.message}');
      debugPrint('exception details: ${e.details}');
      debugPrint('======================================');

      final fallbackData = Map<String, dynamic>.from(widget.startup);
      final resolvedImage = await _resolveImageFromStartup(fallbackData);
      final resolvedVideo = await _resolveVideoFromStartup(fallbackData);

      if (!mounted) return;

      setState(() {
        _fullStartup = fallbackData;
        _resolvedImageUrl = resolvedImage;
        _resolvedVideoUrl = resolvedVideo;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('======== GENERIC DETAILS ERROR ========');
      debugPrint('error: $e');
      debugPrint('startup payload: ${widget.startup}');
      debugPrint('=======================================');

      final fallbackData = Map<String, dynamic>.from(widget.startup);
      final resolvedImage = await _resolveImageFromStartup(fallbackData);
      final resolvedVideo = await _resolveVideoFromStartup(fallbackData);

      if (!mounted) return;

      setState(() {
        _fullStartup = fallbackData;
        _resolvedImageUrl = resolvedImage;
        _resolvedVideoUrl = resolvedVideo;
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  Future<String?> _resolveImageFromStartup(Map<String, dynamic> data) async {
    final sector = _readFirst(data, ['sector', 'setor']);

    final rawImage = _readFirst(data, [
      'image',
      'thumbnail',
      'coverImage',
      'banner',
      'logoUrl',
      'imagem',
    ]);

    final resolved = await _resolveStorageUrl(rawImage);
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    return _imageBySector(sector ?? '');
  }

  Future<String?> _resolveVideoFromStartup(Map<String, dynamic> data) async {
    final directVideo = _readFirst(data, [
      'videoUrl',
      'video',
      'demoVideo',
      'pitchVideo',
      'video_pitch',
      'videoUrlDemo',
      'video_url',
      'midiaVideo',
      'arquivoVideo',
      'startupVideo',
    ]);

    debugPrint('Campo de video encontrado no doc: $directVideo');

    final directResolved = await _resolveStorageUrl(directVideo);
    if (directResolved != null && directResolved.isNotEmpty) {
      return directResolved;
    }

    final startupName = _readFirst(data, ['name', 'nome_startup']) ?? '';
    debugPrint('Tentando video por pasta da startup: $startupName');

    final byFolder = await _findVideoInStartupFolder(startupName);
    if (byFolder != null && byFolder.isNotEmpty) {
      return byFolder;
    }

    return null;
  }

  Future<String?> _resolveStorageUrl(String? rawValue) async {
    final value = (rawValue ?? '').trim();
    if (value.isEmpty || value == 'null') {
      return null;
    }

    try {
      if (value.startsWith('http://') || value.startsWith('https://')) {
        return value;
      }

      if (value.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(value);
        return await ref.getDownloadURL();
      }

      final normalized = value.startsWith('/') ? value.substring(1) : value;
      final ref = FirebaseStorage.instance.ref(normalized);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erro resolvendo URL de storage para "$value": $e');
      return null;
    }
  }

  Future<String?> _findVideoInStartupFolder(String startupName) async {
    final trimmed = startupName.trim();
    if (trimmed.isEmpty) return null;

    final folders = [
      'startupsVisual/$trimmed',
      'startupsVisual/${trimmed.toLowerCase()}',
    ];

    for (final folder in folders) {
      try {
        debugPrint('Listando pasta do storage: $folder');
        final result = await FirebaseStorage.instance.ref(folder).listAll();

        for (final item in result.items) {
          final lower = item.name.toLowerCase();
          debugPrint('Arquivo encontrado na pasta: ${item.fullPath}');

          if (lower.endsWith('.mp4') ||
              lower.endsWith('.mov') ||
              lower.endsWith('.m4v') ||
              lower.endsWith('.webm')) {
            final url = await item.getDownloadURL();
            debugPrint('Video encontrado na pasta: $url');
            return url;
          }
        }
      } catch (e) {
        debugPrint('Erro listando pasta "$folder": $e');
      }
    }

    return null;
  }

  String? _readFirst(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = '${data[key] ?? ''}'.trim();
      if (value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractListOfMaps(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final candidate = data[key];
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  @override
  Widget build(BuildContext context) {
    final startup = _fullStartup ?? widget.startup;

    final sector =
        _readFirst(startup, ['sector', 'setor']) ??
        '${widget.startup['sector'] ?? ''}';
    final image = _resolvedImageUrl ?? _imageBySector(sector);
    final name =
        _readFirst(startup, ['name', 'nome_startup']) ??
        '${widget.startup['name'] ?? 'Startup'}';
    final description =
        _readFirst(startup, ['description', 'descricao']) ??
        '${widget.startup['description'] ?? 'Sem descrição'}';
    final stage =
        _readFirst(startup, ['stage', 'estagio']) ??
        '${widget.startup['stage'] ?? 'Não informado'}';
    final raised = _formatRaised(
      _readFirst(startup, ['raised', 'capitalAportado']) ??
          '${widget.startup['raised'] ?? ''}',
    );

    final founders = _extractListOfMaps(startup, [
      'founders',
      'fundadores',
      'socios',
      'sociosFundadores',
    ]);

    final advisors = _extractListOfMaps(startup, [
      'advisors',
      'conselho',
      'board',
      'conselhoConsultivo',
    ]);

    final faq = _extractListOfMaps(startup, [
      'faq',
      'perguntas',
      'questions',
      'duvidas',
    ]);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 14),
                _buildHeroCard(image: image, name: name, sector: sector),
                const SizedBox(height: 18),
                _buildMetricsRow(raised: raised, stage: stage),
                const SizedBox(height: 22),
                _buildHeadline(name, description),
                const SizedBox(height: 18),
                _buildSummaryCard(description),
                const SizedBox(height: 24),
                _buildSectionKicker('SÓCIOS E FUNDADORES'),
                const SizedBox(height: 10),
                if (founders.isEmpty)
                  _buildFounderCard(
                    name: 'Equipe não informada',
                    role: 'Fundadores',
                    percent: '--',
                    description:
                        'Os dados dos fundadores ainda não foram enviados pelo backend.',
                  )
                else
                  ...founders.map(
                    (founder) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildFounderCard(
                        name:
                            _readFirst(founder, ['name', 'nome']) ??
                            'Nome não informado',
                        role:
                            _readFirst(founder, ['role', 'cargo']) ??
                            'Cargo não informado',
                        percent:
                            _readFirst(founder, [
                              'percent',
                              'participation',
                              'equity',
                              'participacao',
                            ]) ??
                            '--',
                        description:
                            _readFirst(founder, [
                              'description',
                              'bio',
                              'descricao',
                            ]) ??
                            'Sem descrição disponível.',
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                _buildSectionKicker('CONSELHO CONSULTIVO'),
                const SizedBox(height: 10),
                if (advisors.isEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniAdvisorCard(
                          name: 'Conselho não informado',
                          role: 'Aguardando dados',
                        ),
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: advisors
                        .map(
                          (advisor) => SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 22,
                            child: _buildMiniAdvisorCard(
                              name:
                                  _readFirst(advisor, ['name', 'nome']) ??
                                  'Nome não informado',
                              role:
                                  _readFirst(advisor, [
                                    'role',
                                    'cargo',
                                    'description',
                                    'descricao',
                                  ]) ??
                                  'Função não informada',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 22),
                _buildSectionKicker('DEMONSTRAÇÃO DA TECNOLOGIA'),
                const SizedBox(height: 10),
                _buildDemoCard(imageUrl: image, videoUrl: _resolvedVideoUrl),
                const SizedBox(height: 22),
                _buildQuestionsHeader(),
                const SizedBox(height: 10),
                if (faq.isEmpty)
                  _buildEmptyFaqCard()
                else
                  ...faq.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDynamicQuestionCard(item),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
            _buildBottomBar(context, name),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: text,
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            'MesclaInvest',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.share_outlined, size: 18, color: text),
          const SizedBox(width: 14),
          const Icon(Icons.notifications_none_rounded, size: 20, color: text),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String image,
    required String name,
    required String sector,
  }) {
    return SizedBox(
      height: 172,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceStrong,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE5F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _sectorLabel(sector),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow({required String raised, required String stage}) {
    return Row(
      children: [
        Expanded(
          child: _metricItem('CAPTAÇÃO\nTOTAL', raised, valueColor: primary),
        ),
        Expanded(
          child: _metricItem(
            'TOKENS\nEMITIDOS',
            _tokenAmountByStage(stage),
            valueColor: primary,
          ),
        ),
        Expanded(
          child: _metricItem(
            'ESTÁGIO',
            _formatStageForMetric(stage),
            valueColor: primary,
          ),
        ),
      ],
    );
  }

  Widget _metricItem(String label, String value, {Color valueColor = text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: divider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: textLight,
              letterSpacing: 0.7,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(String name, String description) {
    return Text(
      _headlineFromStartup(name, description),
      style: const TextStyle(
        fontSize: 16,
        height: 1.28,
        fontWeight: FontWeight.w800,
        color: text,
      ),
    );
  }

  Widget _buildSummaryCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUMÁRIO EXECUTIVO',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _executiveSummary(description),
            style: const TextStyle(fontSize: 13, height: 1.6, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionKicker(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: textLight,
        letterSpacing: 1.3,
      ),
    );
  }

  Widget _buildFounderCard({
    required String name,
    required String role,
    required String percent,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ),
              Text(
                percent,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              height: 1.55,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAdvisorCard({required String name, required String role}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              fontSize: 9.5,
              height: 1.45,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard({
    required String imageUrl,
    required String? videoUrl,
  }) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.22),
              Colors.black.withOpacity(0.38),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const Positioned(
              left: 14,
              bottom: 22,
              child: Text(
                'Pitch Deck & Demo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 10,
              child: Text(
                videoUrl == null || videoUrl.isEmpty
                    ? 'Vídeo não encontrado'
                    : 'Vídeo carregado do documento completo',
                style: const TextStyle(fontSize: 9, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsHeader() {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'DÚVIDAS E PERGUNTAS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textLight,
              letterSpacing: 1.3,
            ),
          ),
        ),
        Text(
          '+ Perguntar',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicQuestionCard(Map<String, dynamic> item) {
    final isPrivate =
        '${item['type'] ?? item['visibility'] ?? item['tipo'] ?? ''}'
            .toLowerCase()
            .contains('priv');

    final question =
        _readFirst(item, ['question', 'pergunta', 'title']) ??
        'Pergunta não informada';
    final author =
        _readFirst(item, ['author', 'user', 'email', 'autor']) ??
        'Usuário não informado';
    final date =
        _readFirst(item, ['date', 'createdAt', 'data']) ?? '--/--/----';
    final answer = _readFirst(item, ['answer', 'resposta']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPrivate ? Icons.lock_outline_rounded : Icons.public,
                size: 12,
                color: isPrivate ? textMuted : primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isPrivate ? 'PRIVADA' : 'PÚBLICA',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: isPrivate ? textMuted : primary,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 8.5, color: textLight),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Por $author',
            style: const TextStyle(fontSize: 9, color: textMuted),
          ),
          if (answer != null && answer.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F3FB),
                borderRadius: BorderRadius.circular(14),
                border: const Border(
                  left: BorderSide(color: primary, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESPOSTA DA EQUIPE',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.55,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyFaqCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Nenhuma pergunta foi enviada para esta startup até o momento.',
        style: TextStyle(fontSize: 11, height: 1.5, color: textMuted),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, String name) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 14,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF8),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFE9E1F3),
                    foregroundColor: text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Vender',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text(
                    'Comprar Tokens',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sectorLabel(String sector) {
    switch (sector.toLowerCase()) {
      case 'fintech':
        return 'Fintech';
      case 'agtech':
      case 'agrotech':
        return 'Agrotech';
      case 'healthtech':
      case 'health':
        return 'HealthTech';
      case 'edtech':
        return 'EdTech';
      default:
        return 'Startup';
    }
  }

  String _imageBySector(String sector) {
    switch (sector.toLowerCase()) {
      case 'fintech':
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=1200&auto=format&fit=crop';
      case 'agtech':
      case 'agrotech':
        return 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1200&auto=format&fit=crop';
      case 'healthtech':
      case 'health':
        return 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=1200&auto=format&fit=crop';
      case 'edtech':
        return 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=1200&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1200&auto=format&fit=crop';
    }
  }

  String _formatRaised(String value) {
    if (value.trim().isEmpty) return 'R\$ 0';
    return value.contains('R\$') ? value : 'R\$ $value';
  }

  String _formatStageForMetric(String stage) {
    final lower = stage.toLowerCase();

    if (lower.contains('nova') ||
        lower.contains('novo') ||
        lower.contains('seed')) {
      return 'Novo';
    }
    if (lower.contains('operação') ||
        lower.contains('operacao') ||
        lower.contains('series a')) {
      return 'Em\nOperação';
    }
    if (lower.contains('expansão') ||
        lower.contains('expansao') ||
        lower.contains('series b')) {
      return 'Em\nExpansão';
    }
    return stage;
  }

  String _tokenAmountByStage(String stage) {
    final lower = stage.toLowerCase();

    if (lower.contains('nova') ||
        lower.contains('novo') ||
        lower.contains('seed')) {
      return '350.000';
    }
    if (lower.contains('operação') ||
        lower.contains('operacao') ||
        lower.contains('series a')) {
      return '1.250.000';
    }
    if (lower.contains('expansão') ||
        lower.contains('expansao') ||
        lower.contains('series b')) {
      return '2.400.000';
    }
    return '500.000';
  }

  String _headlineFromStartup(String name, String description) {
    final lower = description.toLowerCase();

    if (lower.contains('água') || lower.contains('agua')) {
      return 'Transformando desperdício em eficiência através da IA.';
    }
    if (lower.contains('agric') || lower.contains('monitoramento')) {
      return 'Tecnologia aplicada ao campo para escalar produtividade.';
    }
    if (lower.contains('hardware') || lower.contains('tempo real')) {
      return 'Infraestrutura inteligente para decisões em tempo real.';
    }
    return 'Construindo uma operação escalável com base tecnológica robusta.';
  }

  String _executiveSummary(String description) {
    return '$description\n\nCom uma modelagem de crescimento orientada por dados, a startup projeta ganho de eficiência, expansão operacional e novas frentes de monetização nos próximos 24 meses.';
  }
}