
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isReady = false;
  bool isCapturing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await controller!.initialize();
      if (mounted) {
        setState(() => isReady = true);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        setState(() => isReady = true);
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> pickFromGallery() async {
    if (isCapturing) return;

    setState(() => isCapturing = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(imagePath: image.path),
          ),
        ).then((_) {
          if (mounted) {
            setState(() => isCapturing = false);
          }
        });
      } else {
        if (mounted) {
          setState(() => isCapturing = false);
        }
      }
    } catch (e) {
      debugPrint("Gallery error: $e");
      if (mounted) {
        setState(() => isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> captureImage() async {
    if (isCapturing) return;
    if (controller == null || !controller!.value.isInitialized) return;

    setState(() => isCapturing = true);

    try {
      final image = await controller!.takePicture();
      
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: image.path),
        ),
      ).then((_) {
        if (mounted) {
          setState(() => isCapturing = false);
        }
      });
    } catch (e) {
      debugPrint("Capture error: $e");
      if (mounted) {
        setState(() => isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                "Initializing camera...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Skin Image"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Camera preview
              Expanded(
                child: controller != null && controller!.value.isInitialized
                    ? ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width *
                                  controller!.value.aspectRatio,
                              child: CameraPreview(controller!),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 80,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Camera not available",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red[400],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Bottom controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Upload button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.photo_library,
                            color: isCapturing
                                ? Colors.grey
                                : Colors.orange,
                          ),
                          label: Text(
                            "Upload",
                            style: TextStyle(
                              color: isCapturing
                                  ? Colors.grey
                                  : Colors.orange,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                            side: BorderSide(
                              color: isCapturing
                                  ? Colors.grey
                                  : Colors.orange,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          onPressed: isCapturing ? null : pickFromGallery,
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Capture button
                      GestureDetector(
                        onTap: isCapturing ? null : captureImage,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCapturing
                                ? Colors.orange.withOpacity(0.5)
                                : Colors.orange,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: isCapturing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 32,
                                ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Spacer for balance
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ✅ Green loading bar at top when capturing/uploading
          if (isCapturing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.black.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.green,
                ),
                minHeight: 4,
              ),
            ),

          // Instructions overlay
          if (!isCapturing && controller != null && controller!.value.isInitialized)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "📸 Position the affected skin area in the frame",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}