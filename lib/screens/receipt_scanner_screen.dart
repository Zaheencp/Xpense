import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';
// import 'package:universal_html/html.dart' as html;
import '../controllers/firebasecontroller.dart';
import '../models/categorymodel.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xpense/screens/widgets/bottomnavbar.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  File? _image;
  String? _imageUrl; // For web platform
  String? _extractedText;
  bool _isProcessing = false;
  String? _merchant;
  String? _total;
  String? _date;
  Expensecategory? _selectedCategory;
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String? _errorMsg;

  Future<void> _pickImage() async {
    // Check for Desktop or Web (Mock scanning for unsupported platforms)
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _simulateScanForDesktop();
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
      });
      await _performAdvancedOCR(_image!);
    }
  }

  Future<void> _simulateScanForDesktop() async {
    setState(() {
      _isProcessing = true;
      _errorMsg = null;
    });

    // Simulate network/processing delay (Faster now)
    await Future.delayed(const Duration(milliseconds: 500));

    const mockText = """
Walmart Supercenter
Date: 2024-05-20
Item 1   10.00
Item 2   20.00
TOTAL    54.20
Thank you for shopping!
""";

    setState(() {
      _image = null; // No actual file on desktop/web simulation
      _extractedText = mockText;
      _merchant = "Walmart Supercenter";
      _total = "54.20";
      _date = "2024-05-20";
      _isProcessing = false;
    });

    _selectedCategory = Expensecategory.expenses.firstWhere(
      (cat) =>
          cat.name!.toLowerCase().contains("groceries") ||
          cat.name!.toLowerCase().contains("shopping"),
      orElse: () => Expensecategory.expenses.first,
    );

    _totalController.text = _total ?? '';
    _dateController.text = _date ?? '';
    _memoController.text = "Simulated Scan: $mockText";

    // Show a snackbar to inform the user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Simulated OCR Scan (ML Kit not supported on specific platform)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _performAdvancedOCR(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _errorMsg = null;
    });

    try {
      // On-device ML extraction
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      String? merchant;
      String? total;
      String? date;
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final text = line.text.toLowerCase();
          if (merchant == null &&
              text.length > 2 &&
              !text.contains(RegExp(r'\d'))) {
            merchant = line.text;
          }
          if (total == null && text.contains('total')) {
            final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(text);
            if (match != null) total = match.group(1);
          }
          if (date == null &&
              RegExp(r'(\d{2,4}[-/\.]\d{2}[-/\.]\d{2,4})').hasMatch(text)) {
            date = RegExp(r'(\d{2,4}[-/\.]\d{2}[-/\.]\d{2,4})')
                .firstMatch(text)
                ?.group(0);
          }
        }
      }
      // Fallbacks
      merchant ??= recognizedText.blocks.isNotEmpty
          ? recognizedText.blocks.first.text
          : null;
      total ??= RegExp(r'(\d+[.,]\d{2})')
          .allMatches(recognizedText.text)
          .map((m) => m.group(0))
          .fold<String?>(null, (prev, curr) {
        if (prev == null) return curr;
        return double.parse(curr!.replaceAll(',', '.')) >
                double.parse(prev.replaceAll(',', '.'))
            ? curr
            : prev;
      });
      date ??= DateFormat('yyyy-MM-dd').format(DateTime.now());
      setState(() {
        _merchant = merchant;
        _total = total;
        _date = date;
        _extractedText = recognizedText.text;
        _isProcessing = false;
      });
      _selectedCategory = Expensecategory.expenses.firstWhere(
        (cat) =>
            _merchant != null &&
            cat.name != null &&
            _merchant!.toLowerCase().contains(cat.name!.toLowerCase()),
        orElse: () => Expensecategory.expenses.first,
      );
      _totalController.text = _total ?? '';
      _dateController.text = _date ?? '';
      _memoController.text = recognizedText.text;
    } catch (e) {
      if (e.toString().contains("MissingPluginException")) {
        // Fallback to simulation if plugin is missing (Web/Desktop)
        await _simulateScanForDesktop();
      } else {
        setState(() {
          _isProcessing = false;
          _errorMsg = 'OCR Error: $e';
        });
      }
    }
  }

  Future<void> _performCloudOCR(File imageFile) async {
    // For production, use a backend proxy for security.
    // Backend endpoint: POST /api/cloud-ocr { image: <base64> } => { text: ... }
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    setState(() {
      _isProcessing = true;
      _errorMsg = null;
    });
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:5000/api/cloud-ocr'), // Change to your backend endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['text'] ?? '';
        if (text.isEmpty) {
          setState(() {
            _isProcessing = false;
            _errorMsg = 'No text found in receipt.';
          });
          return;
        }
        _performAdvancedOCRFromText(text);
      } else {
        setState(() {
          _isProcessing = false;
          _errorMsg = 'Cloud OCR failed: \n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMsg = 'Cloud OCR error: $e';
      });
    }
  }

  void _performAdvancedOCRFromText(String text) {
    String? merchant;
    String? total;
    String? date;
    final lines = text.split('\n');
    for (final line in lines) {
      final l = line.toLowerCase();
      if (merchant == null && l.length > 2 && !l.contains(RegExp(r'\d'))) {
        merchant = line;
      }
      if (total == null && l.contains('total')) {
        final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(l);
        if (match != null) total = match.group(1);
      }
      if (date == null &&
          RegExp(r'(\d{2,4}[-/\.]\d{2}[-/\.]\d{2,4})').hasMatch(l)) {
        date = RegExp(r'(\d{2,4}[-/\.]\d{2}[-/\.]\d{2,4})')
            .firstMatch(l)
            ?.group(0);
      }
    }
    merchant ??= lines.isNotEmpty ? lines.first : null;
    total ??= RegExp(r'(\d+[.,]\d{2})')
        .allMatches(text)
        .map((m) => m.group(0))
        .fold<String?>(null, (prev, curr) {
      if (prev == null) return curr;
      return double.parse(curr!.replaceAll(',', '.')) >
              double.parse(prev.replaceAll(',', '.'))
          ? curr
          : prev;
    });
    date ??= DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _merchant = merchant;
      _total = total;
      _date = date;
      _extractedText = text;
      _isProcessing = false;
    });
    _selectedCategory = Expensecategory.expenses.firstWhere(
      (cat) =>
          _merchant != null &&
          cat.name != null &&
          _merchant!.toLowerCase().contains(cat.name!.toLowerCase()),
      orElse: () => Expensecategory.expenses.first,
    );
    _totalController.text = _total ?? '';
    _dateController.text = _date ?? '';
    _memoController.text = text;
  }

  void _showConfirmSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setStateSheet) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, color: Colors.blueGrey),
                    SizedBox(width: 8),
                    Text('Confirm Expense',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Expensecategory>(
                  initialValue: _selectedCategory,
                  items: Expensecategory.expenses
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                if (cat.icon != null) Icon(cat.icon, size: 18),
                                const SizedBox(width: 8),
                                Text(cat.name ?? 'Other'),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (cat) =>
                      setStateSheet(() => _selectedCategory = cat),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _totalController,
                  decoration: const InputDecoration(
                      labelText: 'Amount', prefixText: ' 0'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_dateController.text) ??
                          DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setStateSheet(() => _dateController.text =
                        DateFormat('yyyy-MM-dd')
                            .format(picked ?? DateTime.now()));
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _memoController,
                  decoration: const InputDecoration(labelText: 'Memo'),
                  maxLines: 2,
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Expense'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48)),
                  onPressed: () async {
                    if (_totalController.text.isEmpty ||
                        _selectedCategory == null ||
                        _dateController.text.isEmpty) {
                      setStateSheet(
                          () => _errorMsg = 'Please fill all required fields.');
                      return;
                    }
                    if (double.tryParse(
                            _totalController.text.replaceAll(',', '.')) ==
                        null) {
                      setStateSheet(
                          () => _errorMsg = 'Amount must be a valid number.');
                      return;
                    }
                    Navigator.pop(context);
                    await _addExpense();
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addExpense() async {
    final firebaseController =
        Provider.of<FirebaseController>(context, listen: false);
    final result = await firebaseController.addData(
      _selectedCategory?.name ?? 'Other',
      _totalController.text,
      _dateController.text,
      _memoController.text,
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $result')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added!')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Bottom()),
      (route) => false,
    );
    setState(() {
      _image = null;
      _extractedText = null;
      _merchant = null;
      _total = null;
      _date = null;
      _selectedCategory = null;
      _totalController.clear();
      _dateController.clear();
      _memoController.clear();
      _errorMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null || _imageUrl != null)
                kIsWeb
                    ? Image.network(_imageUrl!,
                        width: 200, height: 200, fit: BoxFit.cover)
                    : Image.file(_image!,
                        width: 200, height: 200, fit: BoxFit.cover),
              if (_isProcessing) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                const Text('Extracting information...'),
              ],
              if (!_isProcessing && _extractedText != null) ...[
                const SizedBox(height: 20),
                const Text('Extracted Info:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (_merchant != null) Text('Merchant: $_merchant'),
                if (_total != null) Text('Total: $_total'),
                if (_date != null) Text('Date: $_date'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showConfirmSheet,
                  child: const Text('Add as Expense'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_image != null) await _performCloudOCR(_image!);
                  },
                  child: const Text('Try Cloud OCR (Advanced)'),
                ),
              ],
              if (_image == null && !_isProcessing)
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Scan Receipt'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
