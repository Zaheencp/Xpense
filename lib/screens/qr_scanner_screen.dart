import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../controllers/firebasecontroller.dart';
import '../models/categorymodel.dart';
import '../screens/widgets/bottomnavbar.dart';
import '../controllers/cardprovider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedData;
  String? _merchantName;
  String? _amount;
  String? _location;
  Expensecategory? _selectedCategory;

  // Controllers for bottom sheet fields so focus/cursor behaves correctly
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // To fix on start error
    cameraController.stop();
    _getCurrentLocation();
  }

  String _formatAmount(String amount) {
    try {
      // Remove any non-numeric characters except decimal point
      String cleanAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');

      // Parse as double
      double amountValue = double.parse(cleanAmount);

      // Format as decimal with 2 decimal places (e.g., 10.00)
      return amountValue.toStringAsFixed(2);
    } catch (e) {
      // If parsing fails, return the original amount
      return amount;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {});

      // Get location name from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _location = '${place.locality}, ${place.country}';
          _locationController.text = _location ?? '';
        });
      }
    } catch (e) {
      // Silently ignore location errors; user can still enter location manually.
    }
  }

  void _parseUPIQRCode(String qrData) {
    // UPI QR code format: upi://pay?pa=merchant@upi&pn=Merchant Name&am=Amount&cu=INR&tn=Note&mode=01&sign=...&orgid=000000
    try {
      print('-------------- $qrData');
      Uri uri = Uri.parse(qrData);

      if (uri.scheme == 'upi' && uri.host == 'pay') {
        // Extract all UPI parameters according to specification
        String? payeeVPA = uri.queryParameters['pa']; // MANDATORY
        String? merchantName = uri.queryParameters['pn']; // MANDATORY
        String? amount = uri.queryParameters['am'];
        // String? mode = uri.queryParameters['mode']; // Optional now
        // String? signature = uri.queryParameters['sign']; // MANDATORY (commented out validation)
        // String? orgId = uri.queryParameters['orgid']; // MANDATORY (commented out validation)

        // Additional parameters (extracted for validation but not stored)
        uri.queryParameters['cu']; // currency
        uri.queryParameters['tn']; // transaction note
        uri.queryParameters['tr']; // transaction reference
        uri.queryParameters['tid']; // transaction ID
        uri.queryParameters['mc']; // merchant code
        uri.queryParameters['mid']; // merchant ID
        uri.queryParameters['msid']; // store ID
        uri.queryParameters['mtid']; // terminal ID
        uri.queryParameters['url']; // reference URL

        // Validate mandatory parameters
        if (payeeVPA == null || payeeVPA.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invalid UPI QR: Missing payee VPA (pa)')),
          );
          return;
        }

        if (merchantName == null || merchantName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invalid UPI QR: Missing merchant name (pn)')),
          );
          return;
        }

        // Mode parameter check removed - it is optional in many standard UPI QRs
        // if (mode == null || mode.isEmpty) { ... }

        // if (signature == null || signature.isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //         content: Text('Invalid UPI QR: Missing signature (sign)')),
        //   );
        //   return;
        // }

        // if (orgId == null || orgId.isEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //         content:
        //             Text('Invalid UPI QR: Missing organization ID (orgid)')),
        //   );
        //   return;
        // }

        setState(() {
          _merchantName = merchantName;
          _amount = amount;
          _scannedData = qrData; // Keep original QR data intact
        _merchantController.text = _merchantName ?? '';
        _amountController.text = _amount ?? '';
        });

        // Check if amount is present in QR code
        bool hasAmountInQR = amount != null && amount.isNotEmpty;

        _showPaymentConfirmation(hasAmountInQR: hasAmountInQR);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Invalid UPI QR code format - must start with upi://pay')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing QR code: $e')),
      );
    }
  }

  void _showPaymentConfirmation({bool hasAmountInQR = false}) {
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
                    Icon(Icons.qr_code_scanner, color: Colors.blueGrey),
                    SizedBox(width: 8),
                    Text('Payment Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Merchant Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: _merchantController,
                  onChanged: (value) => _merchantName = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    prefixText: '₹ ',
                    helperText: hasAmountInQR
                        ? 'Amount is pre-filled from QR code'
                        : 'Enter amount to pay (e.g., 10.00)',
                  ),
                  controller: _amountController,
                  autofocus: !hasAmountInQR,
                  onChanged: (value) {
                    // Just store what the user types; no auto-formatting
                    _amount = value;
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  readOnly: hasAmountInQR, // Make read-only if amount is in QR
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  controller: _locationController,
                  onChanged: (value) => _location = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Expensecategory>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedCategory,
                  items: Expensecategory.expenses
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon, size: 20),
                                const SizedBox(width: 8),
                                Text(category.name ?? ''),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setStateSheet(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: const Text('Pay Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _launchUPIApp();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save as Expense'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveExpenseWithoutPayment();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _generateUniqueTransactionId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();
  }

  Uri _constructUPIUri({
    required String pa,
    required String pn,
    required String amount,
    required String tr,
    required String tid,
    String? mc,
  }) {
    return Uri.parse(
      'upi://pay'
      '?pa=$pa'
      '&pn=${Uri.encodeComponent(pn)}'
      '&am=$amount'
      '&cu=INR'
      '&tr=$tr'
      '&tid=$tid'
      '${mc != null ? '&mc=$mc' : ''}'
      '&mode=02', // 02 = Secure/Signed Intent often helps
    );
  }

  void _launchUPIApp() async {
    if (_scannedData == null) return;

    try {
      final originalUri = Uri.parse(_scannedData!);
      final pa = originalUri.queryParameters['pa'];
      final pn = originalUri.queryParameters['pn'] ?? '';
      final mc = originalUri.queryParameters['mc'];

      if (pa == null || pa.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid QR: Missing Payee Address (pa)')),
        );
        return;
      }

      // Generate unique IDs for this attempt
      final txnId = _generateUniqueTransactionId();

      // Determine amount to use
      String finalAmount;
      bool hasAmountInOriginalQR =
          originalUri.queryParameters.containsKey('am') &&
              originalUri.queryParameters['am'] != null &&
              originalUri.queryParameters['am']!.isNotEmpty;

      if (hasAmountInOriginalQR) {
        finalAmount = originalUri.queryParameters['am']!;
      } else {
        if (_amount == null || _amount!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter an amount to pay')),
          );
          return;
        }
        // Format user entered amount
        String formatted = _formatAmount(_amount!);
        if (double.tryParse(formatted) == null ||
            double.parse(formatted) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid amount > 0')),
          );
          return;
        }
        finalAmount = formatted;
      }

      // Construct FRESH URI (still useful for logging/debugging what would have been sent)
      final freshUri = _constructUPIUri(
          pa: pa, pn: pn, amount: finalAmount, tr: txnId, tid: txnId, mc: mc);

      debugPrint('Mocking UPI Payment: $freshUri');

      // MOCK PAYMENT SIMULATION
      _simulateMockPayment(txnId, pn);
    } catch (e) {
      debugPrint('Error launching UPI app: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _simulateMockPayment(String txnId, String payeeName) async {
    // 1. Show Processing Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Processing Mock Payment..."),
          ],
        ),
      ),
    );

    // 2. Simulate delay
    await Future.delayed(const Duration(milliseconds: 1300));

    if (!mounted) return;
    Navigator.pop(context); // Close processing dialog

    // 3. Show Success Dialog (non-blocking)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text("Payment Successful to $payeeName"),
            const SizedBox(height: 10),
            Text(
              "Ref: $txnId",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    // 4. Save Expense in background
    _saveExpenseAfterPayment(mockTxnId: txnId);

    // 5. After 1 second, close dialog and navigate home
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Close the success dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Navigate back to the home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Bottom()),
      (route) => false,
    );
  }

  Future<void> _saveExpenseAfterPayment({String? mockTxnId}) async {
    if (_merchantName == null || _amount == null) return;

    final firebaseController =
        Provider.of<FirebaseController>(context, listen: false);

    // Use selected category, or auto-detect if not selected
    Expensecategory? selectedCategory = _selectedCategory ??
        Expensecategory.expenses.firstWhere(
          (cat) => _merchantName!
              .toLowerCase()
              .contains(cat.name?.toLowerCase() ?? ''),
          orElse: () => Expensecategory.expenses.first,
        );

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String memo = mockTxnId != null
        ? 'QR Payment - Mock Payment - Ref: $mockTxnId'
        : 'Payment to $_merchantName via QR Code';

    final result = await firebaseController.addData(
      selectedCategory.name ?? 'Other',
      _amount!,
      currentDate,
      memo,
      location: _location,
      paymentMethod: 'UPI',
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $result')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!')),
      );

      // Sync with TransactionProvider
      if (mounted) {
        final txProvider =
            Provider.of<TransactionProvider>(context, listen: false);
        txProvider.fetchcategory(selectedCategory.name ?? 'Other');
        txProvider.fetchamount(_amount!);
        txProvider.avlabalance();
      }
    }
  }

  Future<void> _saveExpenseWithoutPayment() async {
    if (_merchantName == null || _amount == null) return;

    final firebaseController =
        Provider.of<FirebaseController>(context, listen: false);

    // Use selected category, or auto-detect if not selected
    Expensecategory? selectedCategory = _selectedCategory ??
        Expensecategory.expenses.firstWhere(
          (cat) => _merchantName!
              .toLowerCase()
              .contains(cat.name?.toLowerCase() ?? ''),
          orElse: () => Expensecategory.expenses.first,
        );

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String memo = 'QR Payment to $_merchantName (Saved without payment)';

    final result = await firebaseController.addData(
      selectedCategory.name ?? 'Other',
      _amount!,
      currentDate,
      memo,
      location: _location,
      paymentMethod: 'UPI',
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $result')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!')),
      );

      // Sync with TransactionProvider
      if (mounted) {
        final txProvider =
            Provider.of<TransactionProvider>(context, listen: false);
        txProvider.fetchcategory(selectedCategory.name ?? 'Other');
        txProvider.fetchamount(_amount!);
        txProvider.avlabalance();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Bottom()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              controller: cameraController,
              errorBuilder: (context, error, stackTrace) {
                print('Error: $error');
                return Center(child: Text('Error: $error'));
              },
              onDetect: (capture) {
                if (!_isProcessing && _isScanning) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      setState(() {
                        _isProcessing = true;
                        _isScanning = false;
                      });
                      _parseUPIQRCode(barcode.rawValue!);
                      break;
                    }
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan Qr Code',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (_isProcessing) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Processing QR code...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
