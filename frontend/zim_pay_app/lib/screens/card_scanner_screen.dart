import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  bool _isFlashOn = false; // <-- ADDED: Flashlight state

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFocusMode(FocusMode.auto);

    // Ensure flash is off when we start
    await _cameraController!.setFlashMode(FlashMode.off);

    if (mounted) setState(() {});
  }

  // <-- ADDED: Flashlight toggle method
  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() => _isFlashOn = !_isFlashOn);
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _scanImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final XFile file = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(file.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String? scannedCardNumber;
      String? scannedExpiry;

      // 1. Combine ALL text into one giant string.
      // This prevents ML Kit from failing if it splits "1234 5678" into two blocks.
      String allText = recognizedText.blocks.map((b) => b.text).join(' ');

      // 2. SMARTER REGEX: Look for ANY 15 to 19 digits, ignoring spaces and dashes in between.
      final cardRegex = RegExp(r'(?:\d[\s-]*){15,19}');
      final matches = cardRegex.allMatches(allText);

      for (final match in matches) {
        // Strip everything except the raw numbers
        String cleanMatch = match.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');

        // Standard credit cards are 15 digits (Amex) or 16 digits (Visa/MC)
        if (cleanMatch.length == 15 || cleanMatch.length == 16) {
          scannedCardNumber = cleanMatch;
          break; // We found the card number! Stop looking.
        }
      }

      // 3. Expiry Hunt: Look for MM/YY or MM/YYYY
      final expiryRegex = RegExp(r'(0[1-9]|1[0-2])\s*/\s*([0-9]{2}|[0-9]{4})');
      if (expiryRegex.hasMatch(allText)) {
        scannedExpiry = expiryRegex.stringMatch(allText)!.replaceAll(' ', '');
      }

      if (scannedCardNumber != null) {
        // Turn off flash before leaving screen
        if (_isFlashOn) await _toggleFlash();

        if (mounted) {
          Navigator.pop(context, {
            'cardNumber': scannedCardNumber,
            'expiryDate': scannedExpiry ?? '',
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read card clearly. Try turning on the flashlight or reducing glare.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error scanning card: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Position Card in Frame', style: TextStyle(color: Colors.white)),
        actions: [
          // <-- ADDED: Flashlight Icon Button in AppBar
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.amber),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Camera Feed
          Positioned.fill(
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: 1 / _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),

          // Viewfinder Overlay
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: (MediaQuery.of(context).size.width * 0.9) / 1.586,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : FloatingActionButton.extended(
              onPressed: _scanImage,
              backgroundColor: const Color(0xFF0058BA), // ZimPay Primary
              foregroundColor: Colors.white,
              icon: const Icon(Icons.document_scanner),
              label: const Text('Read Card'),
            ),
          ),
        ],
      ),
    );
  }
}