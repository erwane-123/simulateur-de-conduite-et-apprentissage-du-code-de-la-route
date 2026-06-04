import 'package:code_route_flutter/core/constants/app_colors.dart';
import 'package:code_route_flutter/data/models/theme_cours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final ThemeCours theme;

  const PdfViewerScreen({Key? key, required this.theme}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final FlutterTts _flutterTts = FlutterTts();

  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isReading = false;
  bool _isDrawingMode = false;
  String? _errorMessage;
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadPdfFromAssets();
  }

  void _initTts() {
    _flutterTts.setLanguage('fr-FR');
    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isReading = false;
      });
    });
  }

  Future<void> _loadPdfFromAssets() async {
    try {
      final assetData = await rootBundle.load(widget.theme.pdfPath);
      if (!mounted) return;
      setState(() {
        _pdfBytes = assetData.buffer.asUint8List();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger le PDF de ce chapitre.';
      });
    }
  }

  void _downloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Le PDF est deja embarque dans l application. Le telechargement local sera ajoute plus tard.',
        ),
      ),
    );
  }

  Future<void> _toggleAudio() async {
    if (_isReading) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() {
        _isReading = false;
      });
      return;
    }

    await _flutterTts.speak(
      'Lecture du ${widget.theme.title}. Le texte detaille du PDF n est pas encore extrait automatiquement.',
    );
    if (!mounted) return;
    setState(() {
      _isReading = true;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          widget.theme.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: Icon(
              _isDrawingMode ? Icons.edit_off : Icons.edit,
              color: _isDrawingMode ? Colors.red : AppColors.primaryPurple,
            ),
            tooltip: 'Dessiner sur le PDF',
            onPressed: () {
              setState(() {
                _isDrawingMode = !_isDrawingMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primaryPurple),
            tooltip: 'Telecharger le PDF',
            onPressed: _downloadPdf,
          ),
          IconButton(
            icon: Icon(
              _isReading ? Icons.volume_up : Icons.volume_off,
              color: _isReading ? Colors.green : AppColors.primaryPurple,
            ),
            tooltip: 'Lecture vocale',
            onPressed: _toggleAudio,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isDrawingMode
          ? FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              icon: const Icon(Icons.clear, color: Colors.white),
              label: const Text(
                'Effacer le dessin',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  _strokes.clear();
                });
              },
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryPurple),
            SizedBox(height: 16),
            Text('Chargement du cours en PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        SfPdfViewer.memory(
          _pdfBytes!,
          controller: _pdfViewerController,
          pageLayoutMode: PdfPageLayoutMode.single,
          scrollDirection: PdfScrollDirection.vertical,
          canShowScrollHead: false,
          enableDoubleTapZooming: !_isDrawingMode,
        ),
        if (_isDrawingMode)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                setState(() {
                  _currentStroke = [details.localPosition];
                  _strokes.add(_currentStroke);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentStroke.add(details.localPosition);
                });
              },
              onPanEnd: (_) {
                _currentStroke = [];
              },
              child: CustomPaint(
                painter: DrawingPainter(strokes: _strokes),
                size: Size.infinite,
              ),
            ),
          ),
      ],
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
