import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isInitialized = false;
  List<CameraDescription> _cameras = [];

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      // Check camera permission
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          throw Exception('Camera permission denied');
        }
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize camera controller
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  // Get camera controller
  CameraController? get controller => _controller;

  // Check if camera is initialized
  bool get isInitialized => _isInitialized;

  // Get available cameras
  List<CameraDescription> get cameras => _cameras;

  // Take a photo using camera
  Future<File?> takePhoto() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final image = await _controller!.takePicture();
      return File(image.path);
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  // Pick image from camera (using image picker)
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized || _controller == null || _cameras.length < 2) {
      return;
    }

    try {
      final currentIndex = _cameras.indexOf(_controller!.description);
      final newIndex = (currentIndex + 1) % _cameras.length;
      
      await _controller!.dispose();
      
      _controller = CameraController(
        _cameras[newIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
    } catch (e) {
      throw Exception('Failed to switch camera: $e');
    }
  }

  // Toggle flash
  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      if (_controller!.value.flashMode == FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.torch);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      throw Exception('Failed to toggle flash: $e');
    }
  }

  // Get flash mode
  FlashMode get flashMode {
    if (!_isInitialized || _controller == null) {
      return FlashMode.off;
    }
    return _controller!.value.flashMode;
  }

  // Check if flash is available (simplified for compatibility)
  bool get isFlashAvailable {
    if (!_isInitialized || _controller == null) {
      return false;
    }
    // For now, assume flash is available if camera is initialized
    return true;
  }

  // Dispose camera controller
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }

  // Get camera preview widget
  Widget? getCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return null;
    }
    
    return CameraPreview(_controller!);
  }

  // Get camera value
  CameraValue? get cameraValue {
    if (!_isInitialized || _controller == null) {
      return null;
    }
    return _controller!.value;
  }
}
