import 'package:adventurize/models/user_model.dart';
import 'package:adventurize/models/challenge_model.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:adventurize/utils/navigation_utils.dart';
import 'package:adventurize/components/capture_button.dart';

class CameraPage extends StatefulWidget {
  final User user;
  final Challenge? challenge; // Added a nullable Challenge field

  const CameraPage({required this.user, this.challenge, super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0], // Access the first camera (rear)
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        _isFlashOn = !_isFlashOn;
        await _controller!
            .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
        setState(() {});
      } catch (e) {
        print("Error toggling flash: $e");
      }
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final image = await _controller!.takePicture();

        if (_isFlashOn) {
          await _controller!.setFlashMode(FlashMode.off);
          setState(() {
            _isFlashOn = false;
          });
        }

        // Pass the challenge (if any) to the PostMemoryPage
        NavigationUtils.navigateToPostMemory(
          context,
          File(image.path),
          widget.user,
          widget.challenge, // Passing the nullable challenge
        );
      } catch (e) {
        print("Error capturing image: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Get the aspect ratio of the camera preview
    final aspectRatio = _controller!.value.aspectRatio;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildFlashToggle() {
    return Positioned(
      top: 20,
      left: 20,
      child: IconButton(
        icon: Icon(
          _isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
        ),
        onPressed: _toggleFlash,
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) => Positioned(
        top: 20,
        right: 20,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 30,
          ),
        ),
      );

  Widget _buildCaptureButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: CaptureButton(
          onPressed: _captureImage,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                _buildCameraPreview(),
                _buildFlashToggle(),
                _buildCloseButton(context),
                _buildCaptureButton(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
