// import 'dart:async';
// import 'dart:developer' as dev;
// import 'dart:math' as math;
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:echosee_app/app_theme.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class YamnetScreen extends StatefulWidget {
//   const YamnetScreen({super.key});

//   @override
//   State<YamnetScreen> createState() => _YamnetScreenState();
// }

// class _YamnetScreenState extends State<YamnetScreen> {
//   final AudioClassifier _classifier = AudioClassifier();
//   bool _isListening = false;
//   String _currentResult = "Press start to listen";
//   List<Classification> _topResults = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeClassifier();
//   }

//   Future<void> _initializeClassifier() async {
//     try {
//       await _classifier.loadModel();
//       await _classifier.loadLabels();
//       dev.log("Classifier initialized successfully");
//     } catch (e) {
//       dev.log("Error initializing classifier: $e");
//       setState(() => _currentResult = "Error loading model: $e");
//     }
//   }

//   Future<void> _toggleListening() async {
//     if (_isListening) {
//       await _stopListening();
//     } else {
//       await _startListening();
//     }
//   }

//   Future<void> _startListening() async {
//     final status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       setState(() => _currentResult = "Microphone permission denied");
//       return;
//     }

//     setState(() {
//       _isListening = true;
//       _currentResult = "Listening...";
//     });

//     try {
//       _classifier.startInference((results) {
//         if (!mounted) return;
//         setState(() {
//           _topResults = results;
//           if (results.isNotEmpty) _currentResult = results.first.label;
//         });
//       });
//     } catch (e) {
//       dev.log("Error starting inference: $e");
//       await _stopListening();
//     }
//   }

//   Future<void> _stopListening() async {
//     await _classifier.stopInference();
//     if (!mounted) return;
//     setState(() {
//       _isListening = false;
//       _currentResult = "Stopped listening";
//       _topResults = [];
//     });
//   }

//   @override
//   void dispose() {
//     _classifier.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           "YAMNet Sound Classification",
//           style: GoogleFonts.orbitron(
//             color: isDark ? AppColors.darkText : AppColors.lightText,
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(
//           color: isDark ? AppColors.darkText : AppColors.lightText,
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.darkBg : AppColors.lightBg,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _isListening
//                 ? const Icon(
//                     Icons.graphic_eq,
//                     size: 100,
//                     color: AppColors.primary,
//                   )
//                 : Icon(
//                     Icons.mic_none,
//                     size: 100,
//                     color: isDark
//                         ? AppColors.darkTextSub
//                         : AppColors.lightTextSub,
//                   ),
//             const SizedBox(height: 40),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Text(
//                 _currentResult,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.rajdhani(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? AppColors.darkText : AppColors.lightText,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_topResults.isNotEmpty)
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: isDark ? AppColors.darkCard : AppColors.lightCard,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isDark
//                         ? AppColors.darkBorder
//                         : AppColors.lightBorder,
//                   ),
//                 ),
//                 child: Column(
//                   children: _topResults.map((res) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Flexible(
//                             child: Text(
//                               res.label,
//                               style: GoogleFonts.inter(
//                                 color: isDark
//                                     ? AppColors.darkTextSub
//                                     : AppColors.lightTextSub,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             "${(res.score * 100).toStringAsFixed(1)}%",
//                             style: GoogleFonts.inter(
//                               color: AppColors.primary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             const SizedBox(height: 60),
//             GestureDetector(
//               onTap: _toggleListening,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _isListening ? AppColors.error : AppColors.primary,
//                   boxShadow: [
//                     BoxShadow(
//                       color:
//                           (_isListening ? AppColors.error : AppColors.primary)
//                               .withOpacity(0.4),
//                       blurRadius: 20,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   _isListening ? Icons.stop : Icons.mic,
//                   color: Colors.white,
//                   size: 36,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Classification {
//   final String label;
//   final double score;
//   Classification(this.label, this.score);
// }

// class AudioClassifier {
//   Interpreter? _interpreter;
//   List<String> _labels = [];
//   final _audioRecorder = AudioRecorder();
//   StreamSubscription<Uint8List>? _audioSubscription;

//   static const int sampleRate = 16000;
//   static const int inputSamples = 15600; // 0.975 seconds at 16kHz

//   final List<double> _audioBuffer = [];

//   Future<void> loadModel() async {
//     _interpreter = await Interpreter.fromAsset(
//       'assets/yamnet_assets/yamnet.tflite',
//       options: InterpreterOptions()..threads = 4,
//     );

//     final inputShape = _interpreter!.getInputTensor(0).shape;
//     final outputShape = _interpreter!.getOutputTensor(0).shape;
//     dev.log("Model loaded successfully");
//     dev.log("Input: $inputShape | Output: $outputShape");
//   }

//   Future<void> loadLabels() async {
//     final rawCsv = await rootBundle.loadString(
//       'assets/yamnet_assets/yamnet_class_map.csv',
//     );
//     final lines = rawCsv.split('\n');
//     _labels = lines
//         .skip(1)
//         .where((line) => line.trim().isNotEmpty)
//         .map((line) => _parseCsvLine(line))
//         .where((cols) => cols.length > 2)
//         .map((cols) => cols[2].trim())
//         .toList();
//     dev.log("Loaded ${_labels.length} labels");
//   }

//   List<String> _parseCsvLine(String line) {
//     final result = <String>[];
//     bool inQuotes = false;
//     final current = StringBuffer();
//     for (int i = 0; i < line.length; i++) {
//       final ch = line[i];
//       if (ch == '"') {
//         inQuotes = !inQuotes;
//       } else if (ch == ',' && !inQuotes) {
//         result.add(current.toString());
//         current.clear();
//       } else {
//         current.write(ch);
//       }
//     }
//     result.add(current.toString());
//     return result;
//   }

//   void startInference(Function(List<Classification>) onResult) async {
//     if (_interpreter == null) {
//       dev.log("Interpreter not loaded");
//       return;
//     }

//     final config = const RecordConfig(
//       encoder: AudioEncoder.pcm16bits,
//       sampleRate: sampleRate,
//       numChannels: 1,
//       bitRate: 256000,
//     );

//     final stream = await _audioRecorder.startStream(config);

//     _audioSubscription = stream.listen((Uint8List data) {
//       final Int16List int16Data = data.buffer.asInt16List();

//       for (final sample in int16Data) {
//         _audioBuffer.add(sample / 32768.0);
//       }

//       while (_audioBuffer.length >= inputSamples) {
//         final chunk = List<double>.from(_audioBuffer.sublist(0, inputSamples));
//         _audioBuffer.removeRange(0, inputSamples ~/ 2);
//         _runInference(chunk, onResult);
//       }
//     });
//   }

//   void _runInference(
//     List<double> waveform,
//     Function(List<Classification>) onResult,
//   ) {
//     if (_interpreter == null) return;

//     try {
//       final processed = _preprocessWaveform(waveform);

//       final inputTensor = Float32List.fromList(processed);

//       final outputTensor = Float32List(521);

//       _interpreter!.run(inputTensor.buffer, outputTensor.buffer);

//       _processResults(outputTensor, onResult);
//     } catch (e, stack) {
//       dev.log("Inference error: $e");
//       dev.log("Stack: $stack");
//     }
//   }

//   List<double> _preprocessWaveform(List<double> waveform) {
//     // Remove DC offset (center around zero)
//     final mean = waveform.reduce((a, b) => a + b) / waveform.length;
//     final centered = waveform.map((x) => x - mean).toList();

//     double maxAbs = 0.0;
//     for (final sample in centered) {
//       final abs = sample.abs();
//       if (abs > maxAbs) maxAbs = abs;
//     }

//     if (maxAbs > 0.001) {
//       return centered.map((x) => x / maxAbs).toList();
//     }

//     return centered;
//   }

//   void _processResults(
//     Float32List scores,
//     Function(List<Classification>) onResult,
//   ) {
//     final probabilities = <double>[];
//     for (int i = 0; i < scores.length; i++) {
//       probabilities.add(1.0 / (1.0 + math.exp(-scores[i])));
//     }

//     final indexed = <MapEntry<int, double>>[];
//     for (int i = 0; i < probabilities.length; i++) {
//       indexed.add(MapEntry(i, probabilities[i]));
//     }
//     indexed.sort((a, b) => b.value.compareTo(a.value));

//     final top10 = indexed
//         .take(10)
//         .map((e) {
//           return '  ${_labels[e.key]}: ${(e.value * 100).toStringAsFixed(1)}%';
//         })
//         .join('\n');
//     dev.log("Top 10 predictions:\n$top10");

//     final noiseLabels = {
//       'Static',
//       'White noise',
//       'Noise',
//       'Pink noise',
//       'Hum',
//       'Mains hum',
//       'Silence',
//     };

//     final nonNoise = indexed
//         .where((e) => !noiseLabels.contains(_labels[e.key]) && e.value > 0.25)
//         .take(5)
//         .toList();

//     final topResults = (nonNoise.isNotEmpty ? nonNoise : indexed.take(5))
//         .map((e) => Classification(_labels[e.key], e.value))
//         .toList();

//     if (topResults.isNotEmpty) {
//       onResult(topResults);
//     }
//   }

//   Future<void> stopInference() async {
//     await _audioSubscription?.cancel();
//     _audioSubscription = null;
//     await _audioRecorder.stop();
//     _audioBuffer.clear();
//   }

//   void dispose() {
//     _interpreter?.close();
//     _audioRecorder.dispose();
//   }
// }
