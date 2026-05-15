import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mantar/services/api_service.dart';
import 'package:mantar/models/mushroom.dart';
import 'package:mantar/providers/mushroom_provider.dart';
import 'package:mantar/theme/mush_theme.dart';

// Global variable to store available cameras
List<CameraDescription> cameras = [];

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isCameraAvailable = false;
  bool _isAnalyzing = false;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    // Tarama animasyonu için kontrolcü (Yukarı-Aşağı hareket)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras();
      } catch (e) {
        print("Error fetching cameras: $e");
      }
    }

    if (cameras.isEmpty) {
      setState(() { _isCameraAvailable = false; });
      return;
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();

    if (mounted) {
      setState(() { _isCameraAvailable = true; });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraAvailable && cameras.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text("Kamera Bulunamadı", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: MushTheme.primaryGreen));
          }

          final size = MediaQuery.of(context).size;
          // Tarama çerçevesinin boyutu
          final double scanAreaSize = size.width * 0.75;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Kamera Görüntüsü
              CameraPreview(_controller!),
              
              // 2. Karartılmış Arkaplan ve Ortası Delik Çerçeve
              ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut),
                    ),
                    Center(
                      child: Container(
                        width: scanAreaSize,
                        height: scanAreaSize,
                        decoration: BoxDecoration(
                          color: Colors.red, // srcOut blend mode bu rengi şeffaf yapar
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Tarama Animasyonu (Aşağı Yukarı Giden Çizgi)
              Center(
                child: SizedBox(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            top: _animationController.value * (scanAreaSize - 4), // 4px çizgi kalınlığı
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: MushTheme.primaryGreen.withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                      color: MushTheme.primaryGreen.withOpacity(0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              // 4. Köşe Çizgileri
              CustomPaint(painter: ScannerCornerPainter(scanAreaSize), size: Size.infinite),

              // 5. Üst Bar (Geri ve Flaş)
              Positioned(
                top: 50, left: 20, right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(
                          (_controller == null || !_controller!.value.isInitialized || _controller!.value.flashMode == FlashMode.off) 
                            ? Icons.flash_off 
                            : Icons.flash_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          if (_controller == null || !_controller!.value.isInitialized) return;
                          _controller!.setFlashMode(
                            _controller!.value.flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Alt Bar (Deklanşör ve Galeri)
              Positioned(
                bottom: 40, left: 0, right: 0,
                child: Column(
                  children: [
                    const Text("Mantarı çerçevenin içine hizalayın", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Galeri Butonu
                          GestureDetector(
                            onTap: _isAnalyzing ? null : _pickFromGallery,
                            child: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 2)),
                              child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
                            ),
                          ),
                          
                          // Deklanşör
                          GestureDetector(
                            onTap: _isAnalyzing ? null : () => _processImage(fromCamera: true),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                              child: Container(
                                width: 75, height: 75,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: _isAnalyzing 
                                  ? const CircularProgressIndicator(color: MushTheme.primaryGreen) 
                                  : const Icon(Icons.camera_alt, color: MushTheme.primaryGreen, size: 35),
                              ),
                            ),
                          ),
                          
                          // Simetri için boşluk
                          const SizedBox(width: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _processImage(fromCamera: false, imagePath: image.path);
    }
  }

  Future<void> _processImage({required bool fromCamera, String? imagePath}) async {
    setState(() { _isAnalyzing = true; });

    try {
      String finalPath;
      if (fromCamera) {
        if (_controller == null || !_controller!.value.isInitialized) return;
        final XFile photo = await _controller!.takePicture();
        finalPath = photo.path;
      } else {
        if (imagePath == null) return;
        finalPath = imagePath;
      }

      if (!mounted) return;

      // API Call
      final response = await _apiService.predictMushroom(finalPath);

      if (!mounted) return;
      setState(() { _isAnalyzing = false; });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final String prediction = response.data['prediction'];
        final double confidence = response.data['confidence'];
        final Mushroom? details = response.data['details'] != null
            ? Mushroom.fromJson(response.data['details'])
            : null;

        // Show Result
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildResultSheet(prediction, confidence, details, response.data['image_url']),
        );

        // Profil bilgilerini ve geçmişi hemen tazele
        context.read<MushroomProvider>().fetchUserProfile();
        context.read<MushroomProvider>().fetchHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${response.data['error'] ?? 'Bilinmeyen hata'}")),
        );
      }
    } catch (e) {
      print("Error processing picture: $e");
      if (mounted) {
        setState(() { _isAnalyzing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bağlantı Hatası: $e")),
        );
      }
    }
  }

  Widget _buildResultSheet(String prediction, double confidence, Mushroom? details, String uploadedImageUrl) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text("Tarama Sonucu", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  prediction,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: MushTheme.primaryGreen),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (details != null)
                      Chip(
                        label: Text(details.toxicity),
                        backgroundColor: details.toxicity == "Yenen" ? Colors.green.shade100 : Colors.red.shade100,
                      ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text("%$confidence Eşleşme"),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(uploadedImageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                const Text("Açıklama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  details?.description ?? "Bu tür hakkında detaylı bilgi bulunamadı.",
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MushTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Tamam"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Yeni Tasarım: Köşe Çizgileri Ressamı
class ScannerCornerPainter extends CustomPainter {
  final double scanAreaSize;
  ScannerCornerPainter(this.scanAreaSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final double l = 30; // Köşe çizgi uzunluğu
    
    // Ortadaki karenin koordinatları
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;
    
    // Sol üst köşe
    canvas.drawPath(Path()..moveTo(left, top + l)..lineTo(left, top)..lineTo(left + l, top), paint);
    // Sağ üst köşe
    canvas.drawPath(Path()..moveTo(right - l, top)..lineTo(right, top)..lineTo(right, top + l), paint);
    // Sol alt köşe
    canvas.drawPath(Path()..moveTo(left, bottom - l)..lineTo(left, bottom)..lineTo(left + l, bottom), paint);
    // Sağ alt köşe
    canvas.drawPath(Path()..moveTo(right - l, bottom)..lineTo(right, bottom)..lineTo(right, bottom - l), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
