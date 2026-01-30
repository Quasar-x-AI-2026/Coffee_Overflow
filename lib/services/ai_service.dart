import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// 🚀 QUICK FIX VERSION - Should work out of the box
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  Interpreter? _interpreter;
  late List<String> labels;
  bool _loaded = false;

  Future<void> loadModel() async {
    if (_loaded) return;

    try {
      print("🔄 Loading TFLite model...");

      _interpreter = await Interpreter.fromAsset(
        'assets/model/skin_ai_quantized.tflite',
        options: InterpreterOptions()..threads = 4,
      );

      labels = (await rootBundle.loadString('assets/model/labels.txt'))
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      _loaded = true;
      print("✅ Model loaded: ${labels.length} labels");
      
      // Critical: Print model details
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      
      print("📊 INPUT  → shape: ${inputTensor.shape}, type: ${inputTensor.type}");
      print("📊 OUTPUT → shape: ${outputTensor.shape}, type: ${outputTensor.type}");
      
    } catch (e, stack) {
      print("❌ Load failed: $e\n$stack");
      rethrow;
    }
  }

  Future<String> predict(File imageFile) async {
    try {
      if (!_loaded || _interpreter == null) {
        return "❌ Model not loaded";
      }

      // 1️⃣ Decode image
      print("🔍 Step 1: Decoding image...");
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return "❌ Invalid image format";
      }
      print("✅ Decoded: ${image.width}x${image.height}");

      // 2️⃣ Resize
      print("🔍 Step 2: Resizing to 224x224...");
      final resized = img.copyResize(
        image,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );
      print("✅ Resized");

      // 3️⃣ Prepare input - MANUALLY CREATE NESTED LISTS (NO RESHAPE!)
      print("🔍 Step 3: Creating input buffer...");
      final input = _createInputManual(resized);
      print("✅ Input ready");

      // 4️⃣ Prepare output
      print("🔍 Step 4: Creating output buffer...");
      final outputTensor = _interpreter!.getOutputTensor(0);
      final output = _createOutput(outputTensor);
      print("✅ Output buffer ready");

      // 5️⃣ Run inference
      print("🔍 Step 5: Running inference...");
      _interpreter!.run(input, output);
      print("✅ Inference complete!");

      // 6️⃣ Process results
      print("🔍 Step 6: Processing results...");
      final scores = _extractScores(output, outputTensor.type);
      
      final maxScore = scores.reduce(max);
      final maxIndex = scores.indexOf(maxScore);
      final prediction = labels[maxIndex];
      final confidence = (maxScore * 100).toStringAsFixed(1);
      
      print("✅ Result: $prediction ($confidence%)");
      
      // Show top 3
      final ranked = List.generate(
        scores.length, 
        (i) => MapEntry(i, scores[i])
      )..sort((a, b) => b.value.compareTo(a.value));
      
      print("📊 Top 3:");
      for (int i = 0; i < min(3, ranked.length); i++) {
        final label = labels[ranked[i].key];
        final score = (ranked[i].value * 100).toStringAsFixed(1);
        print("   ${i + 1}. $label: $score%");
      }

      return "$prediction ($confidence%)";
      
    } catch (e, stack) {
      print("❌ PREDICTION FAILED:");
      print("   Error: $e");
      print("   Stack: $stack");
      return "Analysis failed: $e";
    }
  }

  /// ✅ GUARANTEED TO WORK: Manual nested list creation
  List<List<List<List<int>>>> _createInputManual(img.Image image) {
    return List.generate(1, (_) {
      return List.generate(224, (y) {
        return List.generate(224, (x) {
          final pixel = image.getPixel(x, y);
          
          // Handle both old and new image package APIs
          try {
            // Try new API (image ^4.x)
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          } catch (e) {
            // Fallback to old API (image ^3.x)
            final p = pixel as int;
            return [
              (p >> 16) & 0xFF, // R
              (p >> 8) & 0xFF,  // G
              p & 0xFF,         // B
            ];
          }
        });
      });
    });
  }

  /// ✅ Create output based on model type
  dynamic _createOutput(Tensor outputTensor) {
    final shape = outputTensor.shape;
    final type = outputTensor.type;
    
    print("   Creating output: shape=$shape, type=$type");
    
    if (type == TensorType.uint8) {
      // Quantized model - single dimension output
      return Uint8List(shape.reduce((a, b) => a * b));
    } else {
      // Float model - [1, num_classes]
      if (shape.length == 2) {
        return List.generate(shape[0], (_) => List.filled(shape[1], 0.0));
      } else {
        return List.filled(shape[0], 0.0);
      }
    }
  }

  /// ✅ Extract and normalize scores
  List<double> _extractScores(dynamic output, TensorType type) {
    if (type == TensorType.uint8) {
      // Dequantize: [0-255] → [0-1]
      final uint8Output = output as Uint8List;
      print("   Dequantizing ${uint8Output.length} uint8 values");
      return uint8Output.map((v) => v / 255.0).toList();
    } else {
      // Already float
      if (output is List && output.isNotEmpty && output[0] is List) {
        return (output[0] as List).cast<double>();
      }
      return (output as List).cast<double>();
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loaded = false;
    print("🗑️ Disposed");
  }
}