import 'dart:math';

import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/models/scan_result.dart';
import 'package:code_route_flutter/screens/dashcam/scan_result_overlay.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class DashcamLiveScanScreen extends StatefulWidget {
  const DashcamLiveScanScreen({Key? key}) : super(key: key);

  @override
  State<DashcamLiveScanScreen> createState() => _DashcamLiveScanScreenState();
}

class _DashcamLiveScanScreenState extends State<DashcamLiveScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final ObjectDetector _objectDetector;
  late final TextRecognizer _textRecognizer;
  final _random = Random();

  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _isCameraStarting = false;
  bool _isLiveScanEnabled = false;
  bool _canProcessFrame = true;
  bool _generatedMode = false;
  ScanResult? _lastResult;
  String _statusText = 'Pret a detecter panneaux, pietons et vehicules';

  @override
  void initState() {
    super.initState();
    _objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startCamera();
  }

  @override
  void dispose() {
    _canProcessFrame = false;
    _cameraController?.dispose();
    _objectDetector.close();
    _textRecognizer.close();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    setState(() {
      _isCameraStarting = true;
      _statusText = 'Demande acces camera...';
    });

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      setState(() {
        _isCameraStarting = false;
        _statusText = 'Camera refusee. Autorise acces camera pour scanner.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      await controller.startImageStream(_processCameraImage);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraStarting = false;
        _isLiveScanEnabled = true;
        _generatedMode = false;
        _statusText = 'Scan temps reel actif';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCameraStarting = false;
        _statusText = 'Camera indisponible. Utilise scene generee.';
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!_isLiveScanEnabled || _generatedMode || !_canProcessFrame) return;
    _canProcessFrame = false;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final objects = await _objectDetector.processImage(inputImage);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final detected = _mapDetections(
        objects,
        recognizedText,
        image.width,
        image.height,
      );

      if (!mounted || detected.isEmpty) return;
      setState(() {
        _lastResult = _buildRealtimeScenario(detected);
        _statusText =
            '${detected.length} objet(s) detecte(s): panneaux, pietons, vehicules';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _statusText = 'Lecture image camera en cours...');
      }
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      _canProcessFrame = true;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final controller = _cameraController;
    if (controller == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(
      controller.description.sensorOrientation,
    );
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null) return null;

    final bytes = WriteBuffer();
    for (final plane in image.planes) {
      bytes.putUint8List(plane.bytes);
    }

    return InputImage.fromBytes(
      bytes: bytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _generateScene() async {
    await _analyzeSituation(sourceLabel: 'Scene generee', generated: true);
  }

  Future<void> _analyzeSituation({
    required String sourceLabel,
    bool generated = false,
  }) async {
    setState(() {
      _isProcessing = true;
      _statusText = 'Analyse de la scene...';
    });

    await Future.delayed(const Duration(milliseconds: 900));
    final result = _buildTrainingScenario(sourceLabel, generated);

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _generatedMode = generated;
      _lastResult = result;
      _statusText = generated
          ? 'Scene generee: objets a reperer'
          : 'Situation analysee: question de priorite';
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScanResultOverlay(result: result),
    );
  }

  List<DetectedRoadObject> _mapDetections(
    List<DetectedObject> mlObjects,
    RecognizedText recognizedText,
    int imageWidth,
    int imageHeight,
  ) {
    final detected = <DetectedRoadObject>[];

    for (final block in recognizedText.blocks) {
      final sign = _objectFromRoadSignText(
        block.text.toUpperCase(),
        _normalizeRect(block.boundingBox, imageWidth, imageHeight),
      );
      if (sign != null) detected.add(sign);
    }

    for (final object in mlObjects) {
      final label = object.labels.isEmpty ? null : object.labels.first;
      final mapped = _objectFromMlLabel(
        label,
        _normalizeRect(object.boundingBox, imageWidth, imageHeight),
      );
      if (mapped != null) detected.add(mapped);
    }

    return _dedupeObjects(detected).take(5).toList();
  }

  Rect _normalizeRect(Rect source, int imageWidth, int imageHeight) {
    return Rect.fromLTRB(
      (source.left / imageWidth).clamp(0.0, 1.0),
      (source.top / imageHeight).clamp(0.0, 1.0),
      (source.right / imageWidth).clamp(0.0, 1.0),
      (source.bottom / imageHeight).clamp(0.0, 1.0),
    );
  }

  DetectedRoadObject? _objectFromRoadSignText(String text, Rect box) {
    if (text.contains('STOP')) {
      return DetectedRoadObject(
        label: 'STOP',
        category: 'Panneau',
        detail: 'Texte STOP lu par reconnaissance optique.',
        risk: 'Arret complet obligatoire avant ligne ou intersection.',
        icon: Icons.pan_tool_rounded,
        color: AppColors.error,
        boundingBox: box,
        confidence: 0.92,
      );
    }
    if (text.contains('30') || text.contains('50') || text.contains('70')) {
      return DetectedRoadObject(
        label: 'Limitation',
        category: 'Panneau',
        detail: 'Nombre de vitesse detecte sur panneau ou marquage.',
        risk: 'Adapter allure et distance de securite.',
        icon: Icons.speed_rounded,
        color: AppColors.accentBlue,
        boundingBox: box,
        confidence: 0.82,
      );
    }
    if (text.contains('CEDEZ') || text.contains('PASSAGE')) {
      return DetectedRoadObject(
        label: 'Cedez-le-passage',
        category: 'Panneau',
        detail: 'Indice textuel de priorite detecte.',
        risk: 'Ralentir et ceder aux usagers engages.',
        icon: Icons.change_history_rounded,
        color: AppColors.warning,
        boundingBox: box,
        confidence: 0.78,
      );
    }
    return null;
  }

  DetectedRoadObject? _objectFromMlLabel(dynamic label, Rect box) {
    final text = label?.text.toLowerCase() ?? '';
    final confidence = label?.confidence;

    if (text.contains('person') ||
        text.contains('pedestrian') ||
        text.contains('people')) {
      return DetectedRoadObject(
        label: 'Pieton',
        category: 'Usager vulnerable',
        detail: 'Silhouette humaine detectee dans la scene.',
        risk: 'Preparer freinage et ceder si engagement.',
        icon: Icons.directions_walk_rounded,
        color: AppColors.accentCyan,
        boundingBox: box,
        confidence: confidence,
      );
    }
    if (text.contains('vehicle') ||
        text.contains('car') ||
        text.contains('bus') ||
        text.contains('truck') ||
        text.contains('motorcycle')) {
      return DetectedRoadObject(
        label: 'Vehicule',
        category: 'Vehicule',
        detail: 'Vehicule detecte dans le champ camera.',
        risk: 'Evaluer distance, vitesse et priorite.',
        icon: Icons.directions_car_rounded,
        color: AppColors.warning,
        boundingBox: box,
        confidence: confidence,
      );
    }
    return null;
  }

  List<DetectedRoadObject> _dedupeObjects(List<DetectedRoadObject> objects) {
    final seen = <String>{};
    return [
      for (final object in objects)
        if (seen.add('${object.category}:${object.label}')) object,
    ];
  }

  List<PriorityQuestion> _buildObjectQuestions(
    List<DetectedRoadObject> detected,
  ) {
    final questions = <PriorityQuestion>[];
    final labels = detected.map((object) => object.label).toSet();

    if (labels.contains('STOP')) {
      questions.add(
        const PriorityQuestion(
          question: 'Quel controle apres immobilisation au STOP ?',
          answers: [
            'Regarder uniquement a gauche',
            'Controler gauche-droite-gauche, pietons et voie abordee',
            'Redemarrer des que la voiture est arretee',
          ],
          correctIndex: 1,
          correction:
              'Apres un STOP, l arret ne suffit pas. Tu dois reprendre toute l information: gauche, droite, gauche, passage pieton, vehicules prioritaires et zones masquees avant de t engager.',
          ruleExplanation:
              'Le STOP impose deux obligations: immobilisation complete du vehicule, puis cession de passage. La decision de repartir vient seulement apres controle complet de la route abordee et des usagers vulnerables.',
        ),
      );
    }

    if (labels.contains('Limitation')) {
      questions.add(
        const PriorityQuestion(
          question: 'Que change une limitation detectee ?',
          answers: [
            'Elle conseille seulement une vitesse',
            'Elle impose une vitesse maximale a ne pas depasser',
            'Elle autorise a garder la vitesse si la route est vide',
          ],
          correctIndex: 1,
          correction:
              'Une limitation est une vitesse maximale. Tu peux rouler moins vite si pietons, vehicules, pluie, nuit, virage ou visibilite reduite exigent plus de marge.',
          ruleExplanation:
              'La vitesse maximale autorisee ne remplace pas l adaptation aux circonstances. Le conducteur doit toujours rester maitre du vehicule et pouvoir s arreter dans la zone visible.',
        ),
      );
    }

    if (labels.contains('Cedez-le-passage')) {
      questions.add(
        const PriorityQuestion(
          question: 'Que faire au cedez-le-passage detecte ?',
          answers: [
            'Passer si tu es deja proche',
            'Ralentir, observer et ceder aux usagers engages ou proches',
            'S arreter toujours dix secondes',
          ],
          correctIndex: 1,
          correction:
              'Au cedez-le-passage, tu adaptes l allure pour pouvoir t arreter. Tu laisses passer tout usager engage ou assez proche pour creer un conflit.',
          ruleExplanation:
              'Le cedez-le-passage oblige a ralentir et a ne pas gener les usagers prioritaires. L arret n est pas systematique, mais tu dois etre capable de t arreter si un usager arrive.',
        ),
      );
    }

    if (labels.contains('Pieton')) {
      questions.add(
        const PriorityQuestion(
          question: 'Quel risque principal avec le pieton detecte ?',
          answers: [
            'Trajectoire toujours previsible',
            'Engagement soudain ou changement de direction',
            'Aucun risque hors passage pieton',
          ],
          correctIndex: 1,
          correction:
              'Un pieton reste vulnerable et parfois imprevisible. Tu reduis l allure, surveilles son regard et ses appuis, et tu te prepares a t arreter.',
          ruleExplanation:
              'Le conducteur doit proteger les usagers vulnerables. Pres d un passage pieton, d une zone masquee ou d un trottoir actif, l anticipation prime sur la priorite theorique.',
        ),
      );
    }

    if (labels.contains('Vehicule')) {
      questions.add(
        const PriorityQuestion(
          question: 'Quelle information lire sur le vehicule detecte ?',
          answers: [
            'Sa couleur',
            'Distance, vitesse, clignotants et trajectoire',
            'Seulement sa position actuelle',
          ],
          correctIndex: 1,
          correction:
              'Un vehicule se lit dans le mouvement: distance, vitesse, trajectoire, clignotants, roues et contexte de priorite. La position seule ne suffit pas.',
          ruleExplanation:
              'Les regles de priorite s appliquent avec l observation dynamique. Avant de t engager ou changer d allure, tu verifies que ton action ne force aucun autre usager a freiner ou devier.',
        ),
      );
    }

    if (questions.isEmpty &&
        detected.any((object) => object.category == 'Panneau')) {
      questions.add(
        const PriorityQuestion(
          question: 'Quelle est la premiere action face a un panneau detecte ?',
          answers: [
            'L ignorer si la voie semble libre',
            'Identifier la regle puis adapter allure et placement',
            'Freiner fort sans verifier derriere',
          ],
          correctIndex: 1,
          correction:
              'Un panneau donne une regle de priorite, vitesse, interdiction ou danger. Tu l identifies tot, controles autour de toi, puis adaptes allure et trajectoire.',
          ruleExplanation:
              'La signalisation verticale impose ou annonce une regle. Elle doit etre lue avant la zone d application pour laisser le temps de controler, ralentir et se placer correctement.',
        ),
      );
    }

    return questions.take(3).toList();
  }

  ScanResult _buildRealtimeScenario(List<DetectedRoadObject> detected) {
    final hasStop = detected.any((object) => object.label == 'STOP');
    final hasSign = detected.any((object) => object.category == 'Panneau');
    final hasPedestrian = detected.any((object) => object.label == 'Pieton');
    final hasVehicle = detected.any((object) => object.label == 'Vehicule');

    final hazards = <DetectedRoadObject>[
      if (hasPedestrian)
        const DetectedRoadObject(
          label: 'Pieton proche',
          category: 'Danger',
          detail: 'Un pieton peut changer de trajectoire rapidement.',
          risk: 'Lever le pied, couvrir le frein, chercher contact visuel.',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
        ),
      if (hasVehicle)
        const DetectedRoadObject(
          label: 'Vehicule mobile',
          category: 'Danger',
          detail: 'Trajectoire et vitesse a confirmer.',
          risk: 'Garder distance et verifier priorite.',
          icon: Icons.directions_car_filled_rounded,
          color: AppColors.warning,
        ),
      if (hasSign)
        const DetectedRoadObject(
          label: 'Regle imposee',
          category: 'Panneau',
          detail: 'Le panneau modifie ordre de passage ou vitesse.',
          risk: 'Lire panneau avant action.',
          icon: Icons.traffic_rounded,
          color: AppColors.accentCyan,
        ),
    ];

    return ScanResult(
      title: 'Detection camera temps reel',
      description:
          'La camera repere ${detected.map((object) => object.label).join(', ')} et transforme la scene en exercice de conduite.',
      dangerLevel: hasPedestrian || hasStop ? 'Eleve' : 'Modere',
      advice: hasStop
          ? 'STOP detecte: arret complet, controles, puis depart seulement si tous les usagers sont hors conflit.'
          : 'Analyse panneaux, pietons et vehicules avant de decider. Ralentis si information incomplete.',
      icon: hasPedestrian
          ? Icons.directions_walk_rounded
          : hasVehicle
              ? Icons.directions_car_rounded
              : Icons.traffic_rounded,
      iconColor: hasPedestrian || hasStop ? AppColors.error : AppColors.warning,
      detectedObjects: detected,
      hazards: hazards.isEmpty
          ? const [
              DetectedRoadObject(
                label: 'Information incomplete',
                category: 'Danger',
                detail: 'Tous les usagers ne sont pas toujours visibles.',
                risk: 'Continuer le balayage visuel.',
                icon: Icons.visibility_rounded,
                color: AppColors.warning,
              ),
            ]
          : hazards,
      priorityQuestion: PriorityQuestion(
        question: hasStop
            ? 'Que dois-tu faire au STOP detecte ?'
            : hasPedestrian
                ? 'Quelle action face au pieton detecte ?'
                : 'Quelle information verifier en premier ?',
        answers: hasStop
            ? const [
                'Ralentir sans immobiliser',
                'Marquer un arret complet puis ceder si besoin',
                'Passer si aucun vehicule ne klaxonne',
              ]
            : hasPedestrian
                ? const [
                    'Accelerer pour passer avant lui',
                    'Ralentir, couvrir le frein et lui ceder s il s engage',
                    'Se deporter sans controle',
                  ]
                : const [
                    'Regarder seulement devant',
                    'Lire panneaux, positions et priorites',
                    'Suivre le vehicule devant sans verifier',
                  ],
        correctIndex: 1,
        correction: hasStop
            ? 'Un STOP impose l immobilisation complete. Apres arret, tu controles gauche-droite-gauche, passage pieton et vehicules prioritaires avant de repartir.'
            : hasPedestrian
                ? 'Le pieton est un usager vulnerable. Tu anticipes son engagement, reduis l allure et restes pret a t arreter, surtout pres d un passage pieton ou d une zone masquee.'
                : 'La bonne decision part de l information: panneaux, feux, marquages, pietons, vehicules et angles morts. Sans information claire, tu ralentis.',
        ruleExplanation: hasStop
            ? 'Regle STOP: arret complet obligatoire, roues immobilisees, puis cession de passage aux usagers de la route abordee et aux pietons engages.'
            : hasPedestrian
                ? 'Regle pieton: tout pieton engage ou manifestant clairement son intention de traverser doit etre laisse passer. En doute, tu ralentis et prepares l arret.'
                : 'Regle generale d observation: la priorite se decide avec signalisation, feux, marquages et mouvements des usagers. Information incomplete = allure reduite.',
      ),
      followUpQuestions: _buildObjectQuestions(detected),
      scanChecklist: const [
        'Lire panneaux et marquages',
        'Chercher pietons sur trottoirs et passages',
        'Evaluer vehicules: distance, vitesse, priorite',
        'Ralentir si visibilite ou intention incertaine',
      ],
    );
  }

  ScanResult _buildTrainingScenario(String sourceLabel, bool generated) {
    final scenarios = [
      ScanResult(
        title: '$sourceLabel - Intersection avec STOP',
        description:
            'L app detecte un STOP, un passage pieton et un vehicule venant de droite.',
        dangerLevel: 'Eleve',
        advice:
            'Marque l arret complet, controle gauche-droite-gauche, puis avance seulement si la zone est libre.',
        icon: Icons.pan_tool_rounded,
        iconColor: AppColors.error,
        generatedScene: generated,
        detectedObjects: const [
          DetectedRoadObject(
            label: 'STOP',
            category: 'Panneau',
            detail: 'Arret obligatoire avant la ligne.',
            risk: 'Refus de priorite si l arret est glisse.',
            icon: Icons.pan_tool_rounded,
            color: AppColors.error,
          ),
          DetectedRoadObject(
            label: 'Passage pieton',
            category: 'Marquage',
            detail: 'Zone de traversee devant l intersection.',
            risk: 'Un pieton peut s engager rapidement.',
            icon: Icons.directions_walk_rounded,
            color: AppColors.accentCyan,
          ),
          DetectedRoadObject(
            label: 'Vehicule a droite',
            category: 'Usager',
            detail: 'Arrive sur l axe prioritaire.',
            risk: 'Priorite a respecter.',
            icon: Icons.directions_car_rounded,
            color: AppColors.warning,
          ),
        ],
        hazards: const [
          DetectedRoadObject(
            label: 'Angle mort a droite',
            category: 'Danger',
            detail: 'Une voiture stationnee masque la visibilite.',
            risk: 'Avancer doucement pour reprendre de l information.',
            icon: Icons.visibility_off_rounded,
            color: AppColors.warning,
          ),
        ],
        priorityQuestion: const PriorityQuestion(
          question: 'Qui a la priorite ici ?',
          answers: [
            'Moi, si je ralentis seulement',
            'Le vehicule venant de droite',
            'Le pieton seulement s il court',
          ],
          correctIndex: 1,
          correction:
              'Au STOP, tu dois t arreter completement et ceder le passage aux usagers de la route abordee. Le pieton reste prioritaire s il s engage.',
          ruleExplanation:
              'Le STOP n est pas un simple ralentissement. Il impose immobilisation complete, observation, puis depart seulement si aucun usager prioritaire n est gene.',
        ),
        followUpQuestions: const [
          PriorityQuestion(
            question: 'Pourquoi le passage pieton change ton observation ?',
            answers: [
              'Parce qu un pieton engage est prioritaire',
              'Parce qu il sert seulement de repere visuel',
              'Parce qu il annule le STOP',
            ],
            correctIndex: 0,
            correction:
                'Un passage pieton impose une recherche active des pietons. S ils sont engages ou manifestent l intention de traverser, tu dois leur ceder le passage.',
            ruleExplanation:
                'La regle protege le pieton: engage ou intention claire de traverser = arret ou ralentissement suffisant pour le laisser passer sans pression.',
          ),
          PriorityQuestion(
            question: 'Quel danger cree le vehicule venant de droite ?',
            answers: [
              'Aucun si tu as vu le STOP',
              'Un conflit de priorite si tu repars trop tot',
              'Seulement un risque de stationnement',
            ],
            correctIndex: 1,
            correction:
                'Au STOP, le vehicule de la route abordee peut etre prioritaire. Tu repars seulement quand distance, vitesse et trajectoire permettent de passer sans le gener.',
            ruleExplanation:
                'Ceder le passage signifie ne pas obliger l autre usager a modifier brusquement allure ou trajectoire. Si son approche cree un doute, tu attends.',
          ),
        ],
        scanChecklist: const [
          'Chercher le panneau avant la ligne',
          'Verifier le passage pieton',
          'Controler les deux cotes',
          'Reprendre de la visibilite lentement',
        ],
      ),
      ScanResult(
        title: '$sourceLabel - Cedez-le-passage et pieton',
        description:
            'La scene contient un cedez-le-passage, un pieton sur le trottoir et un cycliste proche.',
        dangerLevel: 'Modere',
        advice:
            'Anticipe le cycliste, prepare le freinage et cede le passage aux usagers engages.',
        icon: Icons.change_history_rounded,
        iconColor: AppColors.warning,
        generatedScene: generated,
        detectedObjects: const [
          DetectedRoadObject(
            label: 'Cedez-le-passage',
            category: 'Panneau',
            detail: 'Ralentir et ceder si un usager est engage.',
            risk: 'Mauvaise evaluation de vitesse laterale.',
            icon: Icons.change_history_rounded,
            color: AppColors.warning,
          ),
          DetectedRoadObject(
            label: 'Pieton trottoir',
            category: 'Usager vulnerable',
            detail: 'Le pieton regarde la chaussee.',
            risk: 'Il peut traverser.',
            icon: Icons.directions_walk_rounded,
            color: AppColors.accentCyan,
          ),
          DetectedRoadObject(
            label: 'Cycliste',
            category: 'Usager vulnerable',
            detail: 'Arrive dans la zone de conflit.',
            risk: 'Vitesse difficile a estimer.',
            icon: Icons.pedal_bike_rounded,
            color: AppColors.success,
          ),
        ],
        hazards: const [
          DetectedRoadObject(
            label: 'Pieton hesitant',
            category: 'Danger',
            detail: 'Position proche du bord du trottoir.',
            risk: 'Preparer l arret.',
            icon: Icons.report_problem_rounded,
            color: AppColors.error,
          ),
        ],
        priorityQuestion: const PriorityQuestion(
          question: 'Quelle est la bonne decision ?',
          answers: [
            'Passer vite avant le cycliste',
            'Ralentir, observer et ceder si l usager est engage',
            'Klaxonner pour liberer la voie',
          ],
          correctIndex: 1,
          correction:
              'Au cedez-le-passage, la bonne action est de ralentir, observer et laisser passer tout usager engage ou trop proche.',
          ruleExplanation:
              'Au cedez-le-passage, l objectif est de supprimer le conflit. Tu ajustes ton allure pour pouvoir t arreter et tu t engages seulement si insertion sans gene.',
        ),
        followUpQuestions: const [
          PriorityQuestion(
            question: 'Que surveiller chez le pieton sur le trottoir ?',
            answers: [
              'Regard, orientation du corps et position au bord',
              'Seulement ses vetements',
              'Rien tant qu il reste sur le trottoir',
            ],
            correctIndex: 0,
            correction:
                'Un pieton au bord du trottoir peut s engager. Tu lis son regard, ses appuis, son orientation et tu gardes une marge d arret.',
            ruleExplanation:
                'Pres d un pieton, anticipation obligatoire: la marge d arret doit couvrir un changement soudain de direction, surtout en ville et pres des passages.',
          ),
          PriorityQuestion(
            question: 'Pourquoi le cycliste demande plus d anticipation ?',
            answers: [
              'Parce qu il ne peut jamais tourner',
              'Parce que sa vitesse et son ecart peuvent etre mal estimes',
              'Parce qu il perd toujours sa priorite',
            ],
            correctIndex: 1,
            correction:
                'Un cycliste est vulnerable et parfois rapide. Sa trajectoire peut changer pour eviter un obstacle; tu gardes de l espace et tu n imposes pas ton passage.',
            ruleExplanation:
                'Le depassement ou croisement d un cycliste exige distance laterale et vitesse adaptee. Tu dois eviter toute manoeuvre qui le serre ou le surprend.',
          ),
        ],
        scanChecklist: const [
          'Lire le panneau',
          'Evaluer la vitesse du cycliste',
          'Surveiller le pieton',
          'Garder une marge de freinage',
        ],
      ),
      ScanResult(
        title: '$sourceLabel - Rue residentielle',
        description:
            'L app ajoute un enfant proche du trottoir, une voiture stationnee et une limitation de vitesse.',
        dangerLevel: 'Critique',
        advice:
            'Reduis fortement l allure. Un enfant peut surgir entre deux vehicules stationnes.',
        icon: Icons.child_care_rounded,
        iconColor: AppColors.error,
        generatedScene: generated,
        detectedObjects: const [
          DetectedRoadObject(
            label: 'Limitation 30',
            category: 'Panneau',
            detail: 'Zone residentielle a vitesse reduite.',
            risk: 'Distance d arret courte necessaire.',
            icon: Icons.speed_rounded,
            color: AppColors.accentBlue,
          ),
          DetectedRoadObject(
            label: 'Enfant',
            category: 'Usager vulnerable',
            detail: 'Proche du bord du trottoir.',
            risk: 'Trajectoire imprevisible.',
            icon: Icons.child_care_rounded,
            color: AppColors.error,
          ),
          DetectedRoadObject(
            label: 'Vehicule stationne',
            category: 'Obstacle',
            detail: 'Masque une partie du trottoir.',
            risk: 'Debouchage masque.',
            icon: Icons.local_parking_rounded,
            color: AppColors.textSecondary,
          ),
        ],
        hazards: const [
          DetectedRoadObject(
            label: 'Enfant masque',
            category: 'Danger immediat',
            detail: 'Risque d entree soudaine sur la chaussee.',
            risk: 'Pied au frein, vitesse tres basse.',
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
        ],
        priorityQuestion: const PriorityQuestion(
          question: 'Quel comportement adopter ?',
          answers: [
            'Maintenir l allure si la voie est libre',
            'Ralentir fortement et elargir la surveillance',
            'Se deporter sans controler',
          ],
          correctIndex: 1,
          correction:
              'La presence d un enfant et de vehicules masquants impose une allure tres reduite et une recherche active des dangers.',
          ruleExplanation:
              'Face a un danger potentiel masque, la regle pratique est prevention: ralentir avant la zone, augmenter l observation laterale et garder capacite d arret immediat.',
        ),
        followUpQuestions: const [
          PriorityQuestion(
            question: 'Pourquoi le vehicule stationne augmente le risque ?',
            answers: [
              'Il masque trottoir et debouches',
              'Il donne toujours la priorite',
              'Il rend la limitation inutile',
            ],
            correctIndex: 0,
            correction:
                'Un vehicule stationne cache parfois un enfant, un pieton, une portiere ou un vehicule qui sort. Tu ralentis avant la zone masquee.',
            ruleExplanation:
                'Une zone masquee retire de l information. Quand tu ne peux pas voir, tu compenses par une vitesse plus basse et une trajectoire laissant de la marge.',
          ),
          PriorityQuestion(
            question: 'Quelle marge garder face a l enfant detecte ?',
            answers: [
              'Vitesse basse et pied pret a freiner',
              'Klaxon continu',
              'Acceleration pour liberer vite la zone',
            ],
            correctIndex: 0,
            correction:
                'Un enfant est imprevisible. Tu reduis fortement l allure, elargis ton balayage visuel et gardes le pied pret au frein.',
            ruleExplanation:
                'Les enfants sont usagers tres vulnerables. Leur comportement peut etre soudain; le conducteur doit anticiper au lieu de reagir tard.',
          ),
        ],
        scanChecklist: const [
          'Scanner trottoirs et zones masquees',
          'Identifier les enfants et animaux',
          'Adapter l allure avant le danger',
          'Garder le pied pret a freiner',
        ],
      ),
    ];

    return scenarios[_random.nextInt(scenarios.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: Column(
                  children: [
                    _buildTrainingViewport(),
                    const SizedBox(height: 14),
                    _buildModeSwitch(),
                    const SizedBox(height: 14),
                    _buildLiveScanToggle(),
                    const SizedBox(height: 14),
                    _buildLastAnalysis(),
                    const SizedBox(height: 14),
                    _buildControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 18, 0),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashcam Coach',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Priorites, panneaux et dangers reels',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingViewport() {
    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07111F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _buildRoadScene()),
            _buildScanLine(),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _buildDetectedChips(),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _buildStatusPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadScene() {
    final objects = _lastResult?.detectedObjects ?? const [];
    final controller = _cameraController;
    return CustomPaint(
      painter: _RoadScenePainter(generatedMode: _generatedMode),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (!_generatedMode &&
                  controller != null &&
                  controller.value.isInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CameraPreview(controller),
                ),
              for (var i = 0; i < objects.length; i++)
                _PositionedObjectMarker(
                  object: objects[i],
                  fallbackIndex: i,
                  parentSize: constraints.biggest,
                ),
              if (objects.isEmpty)
                Center(
                  child: Icon(
                    _isCameraStarting
                        ? Icons.hourglass_top_rounded
                        : Icons.videocam_rounded,
                    color: Colors.white.withValues(alpha: 0.14),
                    size: 82,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.08 +
              (MediaQuery.of(context).size.height *
                  0.42 *
                  _scanController.value),
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.7),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.accentCyan,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetectedChips() {
    final count = _lastResult?.detectedObjects.length ?? 0;
    final hazards = _lastResult?.hazards.length ?? 0;
    return Row(
      children: [
        _MiniStat(label: 'Objets', value: '$count'),
        const SizedBox(width: 8),
        _MiniStat(label: 'Dangers', value: '$hazards'),
        const Spacer(),
        _MiniStat(label: 'Mode', value: _generatedMode ? 'Scene' : 'Reel'),
      ],
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.accentCyan,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.center_focus_strong_rounded,
                  color: AppColors.accentCyan,
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              selected: !_generatedMode,
              icon: Icons.videocam_rounded,
              label: 'Situation reelle',
              onTap: () => setState(() {
                _generatedMode = false;
                _isLiveScanEnabled = _cameraController != null;
              }),
            ),
          ),
          Expanded(
            child: _ModeButton(
              selected: _generatedMode,
              icon: Icons.auto_awesome_rounded,
              label: 'Scene generee',
              onTap: () => setState(() {
                _generatedMode = true;
                _isLiveScanEnabled = false;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScanToggle() {
    final enabled = _isLiveScanEnabled && !_generatedMode;
    return SwitchListTile(
      value: enabled,
      onChanged: _cameraController == null
          ? null
          : (value) {
              setState(() {
                _generatedMode = false;
                _isLiveScanEnabled = value;
                _statusText = value
                    ? 'Scan temps reel actif'
                    : 'Scan temps reel en pause';
              });
            },
      secondary: Icon(
        enabled ? Icons.center_focus_strong_rounded : Icons.pause_rounded,
        color: enabled ? AppColors.accentCyan : AppColors.textMuted,
      ),
      title: const Text(
        'Detection camera temps reel',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: const Text(
        'Panneaux par texte, pietons et vehicules par ML Kit',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      activeThumbColor: AppColors.accentCyan,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      tileColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
    );
  }

  Widget _buildLastAnalysis() {
    final result = _lastResult;
    if (result == null) {
      return const _InfoPanel(
        icon: Icons.visibility_rounded,
        title: 'Objectif de l exercice',
        text:
            'Filme une rue ou genere une scene. L app te demande ensuite qui a la priorite, corrige immediatement et t apprend a reperer les dangers.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(result.icon, color: result.iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final object in result.detectedObjects)
                _ObjectChip(object: object),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        if (_generatedMode)
          _PrimaryScanButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Generer une scene',
            disabled: _isProcessing,
            onTap: _generateScene,
          )
        else
          _PrimaryScanButton(
            icon: _cameraController == null
                ? Icons.refresh_rounded
                : Icons.center_focus_strong_rounded,
            label: _cameraController == null
                ? 'Relancer la camera'
                : 'Poser une question sur le flux',
            disabled: _isProcessing || _isCameraStarting,
            onTap: _cameraController == null
                ? _startCamera
                : () async {
                    final liveResult = _lastResult;
                    if (liveResult != null &&
                        liveResult.title == 'Detection camera temps reel') {
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => ScanResultOverlay(result: liveResult),
                      );
                      return;
                    }
                    await _analyzeSituation(sourceLabel: 'Flux camera');
                  },
          ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _lastResult == null || _isProcessing
              ? null
              : () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ScanResultOverlay(result: _lastResult!),
                  ),
          icon: const Icon(Icons.quiz_rounded),
          label: const Text('Revoir la correction'),
        ),
      ],
    );
  }
}

class _RoadScenePainter extends CustomPainter {
  final bool generatedMode;

  const _RoadScenePainter({required this.generatedMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    paint.color = const Color(0xFF0B1B2D);
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = const Color(0xFF111827);
    final road = Path()
      ..moveTo(size.width * 0.34, 0)
      ..lineTo(size.width * 0.66, 0)
      ..lineTo(size.width * 0.88, size.height)
      ..lineTo(size.width * 0.12, size.height)
      ..close();
    canvas.drawPath(road, paint);

    paint.color = Colors.white.withValues(alpha: 0.22);
    paint.strokeWidth = 3;
    for (var y = 42.0; y < size.height; y += 90) {
      canvas.drawLine(
        Offset(size.width * 0.5, y),
        Offset(size.width * 0.5, y + 38),
        paint,
      );
    }

    paint.color = generatedMode
        ? AppColors.accentCyan.withValues(alpha: 0.12)
        : AppColors.success.withValues(alpha: 0.10);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.18), 54, paint);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.7), 70, paint);
  }

  @override
  bool shouldRepaint(covariant _RoadScenePainter oldDelegate) {
    return oldDelegate.generatedMode != generatedMode;
  }
}

class _PositionedObjectMarker extends StatelessWidget {
  final DetectedRoadObject object;
  final int fallbackIndex;
  final Size parentSize;

  const _PositionedObjectMarker({
    required this.object,
    required this.fallbackIndex,
    required this.parentSize,
  });

  @override
  Widget build(BuildContext context) {
    final box = object.boundingBox;
    if (box == null) {
      return Positioned(
        left: fallbackIndex == 0 ? 32 : null,
        right: fallbackIndex == 1 ? 34 : null,
        top: 110.0 + (fallbackIndex * 88),
        child: _SceneObjectMarker(object: object),
      );
    }

    final left = box.left * parentSize.width;
    final top = box.top * parentSize.height;
    final width = (box.width * parentSize.width).clamp(82.0, 180.0);
    final height = (box.height * parentSize.height).clamp(54.0, 150.0);

    return Positioned(
      left: left.clamp(8.0, parentSize.width - width - 8),
      top: top.clamp(54.0, parentSize.height - height - 86),
      width: width,
      height: height,
      child: _DetectionBox(object: object),
    );
  }
}

class _DetectionBox extends StatelessWidget {
  final DetectedRoadObject object;

  const _DetectionBox({required this.object});

  @override
  Widget build(BuildContext context) {
    final confidence = object.confidence == null
        ? null
        : '${(object.confidence! * 100).clamp(0, 99).round()}%';

    return Container(
      decoration: BoxDecoration(
        color: object.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: object.color, width: 2),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(object.icon, color: object.color, size: 14),
              const SizedBox(width: 4),
              Text(
                confidence == null
                    ? object.label
                    : '${object.label} $confidence',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneObjectMarker extends StatelessWidget {
  final DetectedRoadObject object;

  const _SceneObjectMarker({required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: object.color.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          Icon(object.icon, color: object.color, size: 24),
          const SizedBox(height: 4),
          Text(
            object.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accentCyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: selected ? AppColors.accentCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.backgroundDeep : AppColors.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color:
                    selected ? AppColors.backgroundDeep : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentCyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectChip extends StatelessWidget {
  final DetectedRoadObject object;

  const _ObjectChip({required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: object.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: object.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(object.icon, color: object.color, size: 14),
          const SizedBox(width: 5),
          Text(
            object.label,
            style: TextStyle(
              color: object.color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool disabled;
  final VoidCallback onTap;

  const _PrimaryScanButton({
    required this.icon,
    required this.label,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
