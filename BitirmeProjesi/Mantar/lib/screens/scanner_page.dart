import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Global variable to store available cameras
List<CameraDescription> cameras = [];

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // Animation Controllers
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Track if camera is actually available
  bool _isCameraAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startAnimation();
  }

  Future<void> _initializeCamera() async {
    // 1. Try to find cameras if list is empty
    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras().timeout(
          const Duration(seconds: 3),
          onTimeout: () => [],
        );
      } catch (e) {
        print("Error fetching cameras: $e");
      }
    }

    // 2. CRITICAL CHECK: If still no camera (Emulator or broken hardware)
    if (cameras.isEmpty) {
      setState(() {
        _isCameraAvailable = false;
      });
      return; // Stop here, don't try to access .first
    }

    // 3. Select the first camera (usually back camera)
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false, // No microphone permission needed
    );

    _initializeControllerFuture = _controller!.initialize();

    if (mounted) {
      setState(() {
        _isCameraAvailable = true;
      });
    }
  }

  void _startAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SCENARIO 1: No Camera Found (Emulator or Error)
    if (!_isCameraAvailable && cameras.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_photography, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No Camera Found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "Please use a real device.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // SCENARIO 2: Camera Loading or Ready
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // Camera Ready -> Show UI
          return Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: Camera Preview
              CameraPreview(_controller!),

              // Layer 2: Scanning Animation
              _buildScanningAnimation(),

              // Layer 3: UI Controls
              _buildUIControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final height = MediaQuery.of(context).size.height;
        final topPosition = height * _animation.value;

        return Stack(
          children: [
            // Green Tint Overlay
            Container(color: Colors.green.withOpacity(0.05)),

            // Moving Line
            Positioned(
              top: topPosition,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUIControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Info Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Frame the mushroom & Scan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 30),

          // Shutter Button
          GestureDetector(
            onTap: _takePicture,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF2E7D32),
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();

      if (!mounted) return;

      // Show processing dialog
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                "AI Analiz Ediyor...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Görüntü işleniyor ve eşleştiriliyor.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      // Show Result
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildResultSheet(),
      );
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Widget _buildResultSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                const Text(
                  "Tarama Sonucu",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Text(
                  "Kanlıca Mantarı",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Chip(
                      label: Text("Yenilebilir"),
                      backgroundColor: Colors.greenAccent,
                    ),
                    SizedBox(width: 10),
                    Chip(
                      label: Text("%98 Eşleşme"),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1597349803159-d8916d820461?q=80&w=2070&auto=format&fit=crop",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Açıklama",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Kanlıca mantarı (Lactarius deliciosus), çam ormanlarında yetişen ve oldukça lezzetli olan bir türdür. Kesildiğinde turuncu renkli bir süt salgılar.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text("Koleksiyonuma Ekle"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
