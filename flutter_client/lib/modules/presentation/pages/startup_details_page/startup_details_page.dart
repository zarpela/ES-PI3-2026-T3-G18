import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

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

  final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  Map<String, dynamic>? fullStartup;
  String? resolvedVideoUrl;
  String? resolvedImageUrl;
  String? resolvedLogoUrl;

  VideoPlayerController? videoController;
  bool isVideoReady = false;
  bool isLoading = true;
  String? errorMessage;

  bool isQuestionsLoading = true;
  bool isInvestor = false;
  List<Map<String, dynamic>> publicQuestions = [];
  List<Map<String, dynamic>> privateQuestions = [];
  List<Map<String, dynamic>> allQuestions = [];

  final TextEditingController questionController = TextEditingController();
  bool isSubmittingQuestion = false;
  String selectedQuestionVisibility = 'publica';

  @override
  void initState() {
    super.initState();
    loadStartupDetails();
    loadQuestions();
  }

  @override
  void dispose() {
    questionController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  Future<void> loadStartupDetails() async {
    try {
      debugPrint('========== STARTUP DETAILS ==========');
      debugPrint('startup keys: ${widget.startup.keys.toList()}');
      debugPrint('startup raw object: ${widget.startup}');

      final startupId =
          '${widget.startup['id'] ?? widget.startup['docId'] ?? widget.startup['startupId'] ?? ''}'
              .trim();

      debugPrint('startupId detectado: $startupId');

      Map<String, dynamic> startupData = Map<String, dynamic>.from(
        widget.startup,
      );

      if (startupId.isNotEmpty) {
        final callable = functions.httpsCallable('getStartupById');
        debugPrint('Chamando function getStartupById em southamerica-east1');

        final result = await callable.call({'id': startupId});

        final data = result.data;
        debugPrint('getStartupById runtimeType: ${data.runtimeType}');
        debugPrint('getStartupById result: $data');

        if (data is Map && data['data'] is Map) {
          startupData = Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map) {
          startupData = Map<String, dynamic>.from(data);
        }
      } else {
        debugPrint(
          'Nenhum ID encontrado. Usando apenas os dados locais da listagem.',
        );
      }

      debugPrint('startupData final: $startupData');

      final resolvedImage = await resolveImageFromStartup(startupData);
      final resolvedLogo = await resolveLogoFromStartup(startupData);
      final resolvedVideo = await resolveVideoFromStartup(startupData);

      debugPrint('resolvedImage: $resolvedImage');
      debugPrint('resolvedLogo: $resolvedLogo');
      debugPrint('resolvedVideo: $resolvedVideo');
      debugPrint('=====================================');

      await setupVideoPlayer(resolvedVideo);

      if (!mounted) return;

      setState(() {
        fullStartup = startupData;
        resolvedImageUrl = resolvedImage;
        resolvedLogoUrl = resolvedLogo;
        resolvedVideoUrl = resolvedVideo;
        errorMessage = null;
        isLoading = false;
      });
    } on FirebaseFunctionsException catch (e) {
      debugPrint('========== FUNCTION ERROR ==========');
      debugPrint('function: getStartupById');
      debugPrint('region: southamerica-east1');
      debugPrint('startup payload: ${widget.startup}');
      debugPrint('exception code: ${e.code}');
      debugPrint('exception message: ${e.message}');
      debugPrint('exception details: ${e.details}');
      debugPrint('===================================');

      final fallbackData = Map<String, dynamic>.from(widget.startup);
      final resolvedImage = await resolveImageFromStartup(fallbackData);
      final resolvedLogo = await resolveLogoFromStartup(fallbackData);
      final resolvedVideo = await resolveVideoFromStartup(fallbackData);

      await setupVideoPlayer(resolvedVideo);

      if (!mounted) return;

      setState(() {
        fullStartup = fallbackData;
        resolvedImageUrl = resolvedImage;
        resolvedLogoUrl = resolvedLogo;
        resolvedVideoUrl = resolvedVideo;
        errorMessage = null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('========== GENERIC DETAILS ERROR ==========');
      debugPrint('error: $e');
      debugPrint('startup payload: ${widget.startup}');
      debugPrint('===========================================');

      final fallbackData = Map<String, dynamic>.from(widget.startup);
      final resolvedImage = await resolveImageFromStartup(fallbackData);
      final resolvedLogo = await resolveLogoFromStartup(fallbackData);
      final resolvedVideo = await resolveVideoFromStartup(fallbackData);

      await setupVideoPlayer(resolvedVideo);

      if (!mounted) return;

      setState(() {
        fullStartup = fallbackData;
        resolvedImageUrl = resolvedImage;
        resolvedLogoUrl = resolvedLogo;
        resolvedVideoUrl = resolvedVideo;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> submitQuestion() async {
    final text = questionController.text.trim();
    final startupId =
        (widget.startup['id'] ??
                widget.startup['docId'] ??
                widget.startup['startupId'] ??
                '')
            .toString()
            .trim();

    if (text.isEmpty || startupId.isEmpty) return;

    try {
      setState(() => isSubmittingQuestion = true);

      await functions.httpsCallable('createStartupQuestion').call({
        'startupId': startupId,
        'text': text,
        // Abdallah El-Khatib
        'visibility': isInvestor ? selectedQuestionVisibility : 'publica',
      });

      await loadQuestions();

      questionController.clear();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erro ao enviar pergunta: $e');
    } finally {
      if (!mounted) return;
      setState(() => isSubmittingQuestion = false);
    }
  }

  Future<void> loadQuestions() async {
    try {
      setState(() => isQuestionsLoading = true);

      final startupId =
          (widget.startup['id'] ??
                  widget.startup['docId'] ??
                  widget.startup['startupId'] ??
                  '')
              .toString()
              .trim();

      if (startupId.isEmpty) {
        if (!mounted) return;
        setState(() {
          publicQuestions = [];
          privateQuestions = [];
          allQuestions = [];
          isQuestionsLoading = false;
        });
        return;
      }

      final pubResult = await functions
          .httpsCallable('getStartupQuestions')
          .call({'startupId': startupId});

      final pubData = pubResult.data;
      List<Map<String, dynamic>> pub = [];

      if (pubData is Map && pubData['data'] is List) {
        pub = (pubData['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      List<Map<String, dynamic>> priv = [];
      var canUsePrivateQuestions = false;

      try {
        // Abdallah El-Khatib
        final privResult = await functions
            .httpsCallable('getStartupPrivateQuestions')
            .call({'startupId': startupId});

        final privData = privResult.data;
        if (privData is Map && privData['data'] is List) {
          priv = (privData['data'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        canUsePrivateQuestions = true;
      } catch (e) {
        debugPrint('Erro ao buscar privadas: $e');
      }

      if (!mounted) return;
      setState(() {
        isInvestor = canUsePrivateQuestions;
        if (!isInvestor && selectedQuestionVisibility == 'privada') {
          selectedQuestionVisibility = 'publica';
        }
        publicQuestions = pub;
        privateQuestions = priv;
        allQuestions = [...pub, ...priv];
        isQuestionsLoading = false;
      });
    } catch (e) {
      debugPrint('Erro loadQuestions: $e');
      if (!mounted) return;
      setState(() {
        publicQuestions = [];
        privateQuestions = [];
        allQuestions = [];
        isQuestionsLoading = false;
      });
    }
  }

  Future<void> setupVideoPlayer(String? url) async {
    videoController?.dispose();
    videoController = null;
    isVideoReady = false;

    if (url == null || url.isEmpty) return;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      await controller.setLooping(true);
      videoController = controller;

      if (!mounted) return;
      setState(() {
        isVideoReady = true;
      });
    } catch (e) {
      debugPrint('Erro inicializando video: $e');
    }
  }

  Future<String?> resolveImageFromStartup(Map<String, dynamic> data) async {
    final sector = readFirst(data, ['sector', 'setor']);

    final rawImage =
        readFirst(data, [
          'backgroundImage',
          'background',
          'image',
          'thumbnail',
          'coverImage',
          'banner',
          'imagem',
        ]) ??
        readFirst(Map<String, dynamic>.from((data['raw'] ?? {}) as Map), [
          'backgroundImage',
          'background',
          'image',
          'thumbnail',
          'coverImage',
          'banner',
          'imagem',
        ]);

    final resolved = await resolveMediaUrl(rawImage);
    if (resolved != null && resolved.isNotEmpty) return resolved;

    return imageBySector(sector ?? '');
  }

  Future<String?> resolveLogoFromStartup(Map<String, dynamic> data) async {
    final rawLogo =
        readFirst(data, ['logo', 'logoUrl', 'brandLogo', 'icon']) ??
        readFirst(Map<String, dynamic>.from((data['raw'] ?? {}) as Map), [
          'logo',
          'logoUrl',
          'brandLogo',
          'icon',
        ]);

    final resolved = await resolveMediaUrl(rawLogo);
    if (resolved != null && resolved.isNotEmpty) return resolved;

    return null;
  }

  Future<String?> resolveVideoFromStartup(Map<String, dynamic> data) async {
    final rawVideo = readFirst(data, [
      'videoUrl',
      'video',
      'demoVideo',
      'pitchVideo',
      'videopitch',
      'videourl',
    ]);

    debugPrint('Campo de video encontrado no doc: $rawVideo');

    final resolved = await resolveMediaUrl(rawVideo);
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    return null;
  }

  Future<String?> resolveMediaUrl(String? rawValue) async {
    final value = (rawValue ?? '').trim();
    final lower = value.toLowerCase();

    if (value.isEmpty || value == 'null' || lower == 'link') return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return null;
  }

  String? readFirst(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final parsed = value.toString().trim();
      if (parsed.isNotEmpty && parsed.toLowerCase() != 'null') return parsed;
    }
    return null;
  }

  List<Map<String, dynamic>> extractListOfMaps(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final candidate = data[key];
      if (candidate is List) {
        return candidate
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final startup = fullStartup ?? widget.startup;

    final sector =
        readFirst(startup, ['sector', 'setor']) ??
        '${widget.startup['sector'] ?? ''}';

    final image = resolvedImageUrl ?? imageBySector(sector);
    final name =
        readFirst(startup, ['name', 'nomeStartup']) ??
        '${widget.startup['name'] ?? 'Startup'}';
    final description =
        readFirst(startup, ['description', 'descricao']) ??
        '${widget.startup['description'] ?? 'Sem descrição.'}';

    final executiveSummary =
        readFirst(startup, [
          'executiveSummary',
          'summary',
          'resumoExecutivo',
        ]) ??
        executiveSummaryFromDescription(description);

    final stage =
        readFirst(startup, ['stage', 'estagio']) ??
        '${widget.startup['stage'] ?? 'Não informado'}';

    final raised = formatRaised(
      readFirst(startup, ['raised', 'raisedCapital', 'capitalAportado']) ??
          '${widget.startup['raised'] ?? ''}',
    );

    final totalTokens =
        readFirst(startup, [
          'totalEmittedTokens',
          'tokens',
          'tokensEmitidos',
        ]) ??
        tokenAmountByStage(stage);

    final founders = extractListOfMaps(startup, [
      'founders',
      'fundadores',
      'shareholders',
      'socios',
      'sociosFundadores',
    ]);

    final advisors = extractListOfMaps(startup, [
      'advisors',
      'externalMembers',
      'conselho',
      'board',
      'conselhoConsultivo',
    ]);

    final faq = extractListOfMaps(startup, [
      'faq',
      'perguntas',
      'questions',
      'duvidas',
    ]);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: bg,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
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
                buildTopBar(context),
                const SizedBox(height: 14),
                buildHeroCard(
                  image: image,
                  logo: resolvedLogoUrl,
                  name: name,
                  sector: sector,
                ),
                const SizedBox(height: 18),
                buildMetricsRow(
                  raised: raised,
                  stage: stage,
                  totalTokens: totalTokens,
                ),
                const SizedBox(height: 22),
                buildHeadline(name, description),
                const SizedBox(height: 18),
                buildSummaryCard(executiveSummary),
                const SizedBox(height: 24),
                buildSectionKicker('SÓCIOS E FUNDADORES'),
                const SizedBox(height: 10),
                if (founders.isEmpty)
                  buildFounderCard(
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
                      child: buildFounderCard(
                        name:
                            readFirst(founder, ['name', 'nome']) ??
                            'Nome não informado',
                        role:
                            readFirst(founder, ['role', 'cargo']) ??
                            'Cargo não informado',
                        percent:
                            readFirst(founder, [
                              'percent',
                              'equityInterest',
                              'participation',
                              'equity',
                              'participacao',
                            ]) ??
                            '--',
                        description:
                            readFirst(founder, [
                              'description',
                              'bio',
                              'descricao',
                            ]) ??
                            'Sem descrição disponível.',
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                buildSectionKicker('CONSELHO CONSULTIVO'),
                const SizedBox(height: 10),
                if (advisors.isEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: buildMiniAdvisorCard(
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
                            child: buildMiniAdvisorCard(
                              name:
                                  readFirst(advisor, ['name', 'nome']) ??
                                  'Nome não informado',
                              role:
                                  readFirst(advisor, [
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
                buildSectionKicker('DEMONSTRAÇÃO DA TECNOLOGIA'),
                const SizedBox(height: 10),
                buildDemoCard(imageUrl: image),
                const SizedBox(height: 22),
                buildQuestionsHeader(),
                const SizedBox(height: 10),
                buildQuestionsSection(),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 11, color: textMuted),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
            buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar(BuildContext context) {
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

  Widget buildHeroCard({
    required String image,
    required String? logo,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              image,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFFE9E1F3),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: textMuted,
                  ),
                );
              },
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
                    clipBehavior: Clip.antiAlias,
                    child: logo != null
                        ? Image.network(
                            logo,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.eco_outlined,
                                color: primary,
                                size: 24,
                              );
                            },
                          )
                        : const Icon(
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
                          sectorLabel(sector),
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

  Widget buildMetricsRow({
    required String raised,
    required String stage,
    required String totalTokens,
  }) {
    return Row(
      children: [
        Expanded(child: metricItem('CAPTAÇÃO', raised, valueColor: primary)),
        Expanded(child: metricItem('TOKENS', totalTokens, valueColor: primary)),
        Expanded(
          child: metricItem(
            'ESTÁGIO',
            formatStageForMetric(stage),
            valueColor: primary,
          ),
        ),
      ],
    );
  }

  Widget metricItem(String label, String value, {Color valueColor = text}) {
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

  Widget buildHeadline(String name, String description) {
    return Text(
      headlineFromStartup(name, description),
      style: const TextStyle(
        fontSize: 16,
        height: 1.28,
        fontWeight: FontWeight.w800,
        color: text,
      ),
    );
  }

  Widget buildSummaryCard(String description) {
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
            description,
            style: const TextStyle(fontSize: 13, height: 1.6, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget buildSectionKicker(String label) {
    return const Text('', style: TextStyle()).copyWithText(label);
  }

  Widget buildFounderCard({
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

  Widget buildMiniAdvisorCard({required String name, required String role}) {
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

  Widget buildDemoCard({required String imageUrl}) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: isVideoReady && videoController != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoController!.value.size.width,
                      height: videoController!.value.size.height,
                      child: VideoPlayer(videoController!),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (videoController!.value.isPlaying) {
                              videoController!.pause();
                            } else {
                              videoController!.play();
                            }
                          });
                        },
                        icon: Icon(
                          videoController!.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, __, ___) {
                    return Container(color: Colors.black12);
                  },
                ),
                Container(color: Colors.black.withOpacity(0.35)),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
                const Positioned(
                  left: 14,
                  bottom: 22,
                  child: Text(
                    'Pitch Deck Demo',
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
                    resolvedVideoUrl == null || resolvedVideoUrl!.isEmpty
                        ? 'Vídeo indisponível'
                        : 'Toque para reproduzir',
                    style: const TextStyle(fontSize: 9, color: Colors.white70),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildQuestionsHeader() {
    return Row(
      children: [
        const Expanded(
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
        TextButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fazer pergunta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isInvestor) ...[
                            // Abdallah El-Khatib
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'publica',
                                  label: Text('Publica'),
                                  icon: Icon(Icons.public, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'privada',
                                  label: Text('Privada'),
                                  icon: Icon(Icons.lock_outline, size: 16),
                                ),
                              ],
                              selected: {selectedQuestionVisibility},
                              onSelectionChanged: (selection) {
                                final value = selection.first;
                                setModalState(() {
                                  selectedQuestionVisibility = value;
                                });
                                setState(() {
                                  selectedQuestionVisibility = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: questionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Digite sua pergunta...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSubmittingQuestion
                                  ? null
                                  : submitQuestion,
                              child: isSubmittingQuestion
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Enviar'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          child: const Text(
            'Perguntar',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildQuestionsSection() {
    if (isQuestionsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (allQuestions.isEmpty) {
      return buildEmptyFaqCard();
    }

    return Column(
      children: allQuestions
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildDynamicQuestionCard(item),
            ),
          )
          .toList(),
    );
  }

  Widget buildDynamicQuestionCard(Map<String, dynamic> item) {
    final isPrivate = '${item['visibility'] ?? ''}'.toLowerCase().contains(
      'priv',
    );

    // Abdallah El-Khatib
    final question =
        (item['question'] ?? item['text'])?.toString() ??
        'Pergunta nao informada';
    final author =
        (item['authorName'] ?? item['authorUid'] ?? item['authorId'])
            ?.toString() ??
        'Usuario nao informado';
    final date = item['createdAt']?.toString() ?? '--/--/----';

    final answerMap = item['answer'];
    final answer = answerMap is Map ? answerMap['text']?.toString() : null;

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

  Widget buildEmptyFaqCard() {
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

  Widget buildBottomBar(BuildContext context) {
    final startupData = fullStartup ?? widget.startup;
    final String startupId =
        '${startupData['id'] ?? startupData['docId'] ?? startupData['startupId'] ?? ''}'
            .trim();
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
                  onPressed: () {
                    Modular.to.pushNamed(
                      AppRoutes.transactionPage,
                      arguments: {
                        "type": TransactionType.sell,
                        "id": startupId,
                      },
                    );
                  },
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
                  onPressed: () {
                    Modular.to.pushNamed(
                      AppRoutes.transactionPage,
                      arguments: {"type": TransactionType.buy, "id": startupId},
                    );
                  },
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
}

extension on Text {
  Widget copyWithText(String value) {
    return Text(
      value,
      style: (this.style ?? const TextStyle()).copyWith(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF9B90AA),
        letterSpacing: 1.3,
      ),
    );
  }
}

String sectorLabel(String sector) {
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
    case 'productivitytech':
      return 'ProductivityTech';
    default:
      return sector.isEmpty ? 'Startup' : sector;
  }
}

String imageBySector(String sector) {
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

String formatRaised(String value) {
  if (value.trim().isEmpty) return 'R\$ 0';
  final clean = value.trim();
  if (clean.contains('R\$')) return clean;
  return 'R\$ $clean';
}

String formatStageForMetric(String stage) {
  final lower = stage.toLowerCase();

  if (lower.contains('nova') ||
      lower.contains('novo') ||
      lower.contains('seed')) {
    return 'Novo';
  }
  if (lower.contains('operação') ||
      lower.contains('operacao') ||
      lower.contains('em_operacao') ||
      lower.contains('series a')) {
    return 'Em op.';
  }
  if (lower.contains('expansão') ||
      lower.contains('expansao') ||
      lower.contains('em_expansao') ||
      lower.contains('series b')) {
    return 'Em exp.';
  }
  return stage;
}

String tokenAmountByStage(String stage) {
  final lower = stage.toLowerCase();

  if (lower.contains('nova') ||
      lower.contains('novo') ||
      lower.contains('seed')) {
    return '350.000';
  }
  if (lower.contains('operação') ||
      lower.contains('operacao') ||
      lower.contains('em_operacao') ||
      lower.contains('series a')) {
    return '1.250.000';
  }
  if (lower.contains('expansão') ||
      lower.contains('expansao') ||
      lower.contains('em_expansao') ||
      lower.contains('series b')) {
    return '2.400.000';
  }
  return '500.000';
}

String headlineFromStartup(String name, String description) {
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
  if (lower.contains('foco') ||
      lower.contains('distrações') ||
      lower.contains('distracoes')) {
    return 'IA aplicada à produtividade para reduzir distrações em tempo real.';
  }
  return 'Construindo uma operação escalável com base tecnológica robusta.';
}

String executiveSummaryFromDescription(String description) {
  return '$description Com uma modelagem de crescimento orientada por dados, a startup projeta ganho de eficiência, expansão operacional e novas frentes de monetização nos próximos 24 meses.';
}
