import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/firebasecontroller.dart';
import '../models/categorymodel.dart';
import '../screens/widgets/bottomnavbar.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
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
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
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
                  controller: TextEditingController(text: _merchantName),
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
                  controller: TextEditingController(text: _amount),
                  onChanged: (value) {
                    // Format amount as user types (for static QR codes)
                    if (!hasAmountInQR) {
                      _amount = _formatAmount(value);
                    } else {
                      _amount = value;
                    }
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
                  controller: TextEditingController(text: _location),
                  onChanged: (value) => _location = value,
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

  void _launchUPIApp() async {
    if (_scannedData == null) return;

    try {
      Uri uri = Uri.parse(_scannedData!);

      // Check if amount is in the original QR code
      bool hasAmountInOriginalQR = uri.queryParameters.containsKey('am') &&
          uri.queryParameters['am'] != null &&
          uri.queryParameters['am']!.isNotEmpty;

      if (hasAmountInOriginalQR) {
        // Dynamic QR: Launch exactly as scanned (amount is pre-filled)
        print('launching UPI app with pre-filled amount: $uri');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          Future.delayed(const Duration(seconds: 5), () {
            _saveExpenseAfterPayment();
          });
        } else {
          _showUPIAppsList();
        }
      } else {
        // Static QR: Create new URL with user-entered amount
        if (_amount == null || _amount!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter an amount to pay')),
          );
          return;
        }

        // Validate amount format
        String formattedAmount = _formatAmount(_amount!);
        if (formattedAmount == '0.00' || formattedAmount == '0') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please enter a valid amount greater than 0')),
          );
          return;
        }

        // Create new UPI URL with amount (for static QR codes without signature)
        // Amount is already formatted above
        final newUri = uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            'am': formattedAmount,
          },
        );

        print('launching UPI app with user amount: $newUri');
        if (await canLaunchUrl(newUri)) {
          await launchUrl(newUri, mode: LaunchMode.externalApplication);
          Future.delayed(const Duration(seconds: 5), () {
            _saveExpenseAfterPayment();
          });
        } else {
          _showUPIAppsList();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching UPI app: $e')),
      );
    }
  }

  void _showUPIAppsList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Choose UPI App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Google Pay'),
            onTap: () => _launchSpecificUPI('googlepay'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('PhonePe'),
            onTap: () => _launchSpecificUPI('phonepe'),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Paytm'),
            onTap: () => _launchSpecificUPI('paytm'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('BHIM UPI'),
            onTap: () => _launchSpecificUPI('bhimupi'),
          ),
        ],
      ),
    );
  }

  void _launchSpecificUPI(String app) async {
    Navigator.pop(context);
    String upiUrl = _scannedData!;

    try {
      Uri uri = Uri.parse(upiUrl);

      // Check if amount is in the original QR code
      bool hasAmountInOriginalQR = uri.queryParameters.containsKey('am') &&
          uri.queryParameters['am'] != null &&
          uri.queryParameters['am']!.isNotEmpty;

      if (hasAmountInOriginalQR) {
        // Dynamic QR: Launch exactly as scanned
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          Future.delayed(const Duration(seconds: 5), () {
            _saveExpenseAfterPayment();
          });
        }
      } else {
        // Static QR: Add amount if user entered one
        if (_amount != null && _amount!.isNotEmpty) {
          // Format amount as decimal (e.g., 10.00)
          String formattedAmount = _formatAmount(_amount!);

          // Validate amount
          if (formattedAmount == '0.00' || formattedAmount == '0') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please enter a valid amount greater than 0')),
            );
            return;
          }

          final newUri = uri.replace(
            queryParameters: {
              ...uri.queryParameters,
              'am': formattedAmount,
            },
          );
          if (await canLaunchUrl(newUri)) {
            await launchUrl(newUri, mode: LaunchMode.externalApplication);
            Future.delayed(const Duration(seconds: 5), () {
              _saveExpenseAfterPayment();
            });
          }
        } else {
          // Launch without amount - user will enter in UPI app
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            Future.delayed(const Duration(seconds: 5), () {
              _saveExpenseAfterPayment();
            });
          }
        }
      }
    } catch (e) {
      print('----------- Error launching $app: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching $app: $e')),
      );
    }
  }

  Future<void> _saveExpenseAfterPayment() async {
    if (_merchantName == null || _amount == null) return;

    final firebaseController =
        Provider.of<FirebaseController>(context, listen: false);

    // Determine category based on merchant name
    Expensecategory? selectedCategory = Expensecategory.expenses.firstWhere(
      (cat) =>
          _merchantName!.toLowerCase().contains(cat.name?.toLowerCase() ?? ''),
      orElse: () => Expensecategory.expenses.first,
    );

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String memo = 'Payment to $_merchantName via QR Code';

    final result = await firebaseController.addData(
      selectedCategory.name ?? 'Other',
      _amount!,
      currentDate,
      memo,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $result')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!')),
      );
    }
  }

  Future<void> _saveExpenseWithoutPayment() async {
    if (_merchantName == null || _amount == null) return;

    final firebaseController =
        Provider.of<FirebaseController>(context, listen: false);

    Expensecategory? selectedCategory = Expensecategory.expenses.firstWhere(
      (cat) =>
          _merchantName!.toLowerCase().contains(cat.name?.toLowerCase() ?? ''),
      orElse: () => Expensecategory.expenses.first,
    );

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String memo = 'QR Payment to $_merchantName (Saved without payment)';

    final result = await firebaseController.addData(
      selectedCategory.name ?? 'Other',
      _amount!,
      currentDate,
      memo,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving expense: $result')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully!')),
      );
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
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Point camera at QR code',
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
