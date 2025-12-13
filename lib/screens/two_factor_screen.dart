import 'package:flutter/material.dart';
import '../services/two_factor_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorScreen extends StatefulWidget {
  final VoidCallback onVerified;
  const TwoFactorScreen({super.key, required this.onVerified});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _useBackup = false;

  void _verify() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await TwoFactorService().verifyCode(codeController.text.trim());
      widget.onVerified();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _verifyBackupCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final codes = List<String>.from(doc.data()?['backupCodes'] ?? []);
      final code = codeController.text.trim();
      if (codes.contains(code)) {
        // Remove used code
        codes.remove(code);
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'backupCodes': codes,
        }, SetOptions(merge: true));
        widget.onVerified();
      } else {
        setState(() {
          _error = 'Invalid backup code.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            Text(
                _useBackup
                    ? 'Enter a backup code'
                    : 'Enter your verification code',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: codeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  labelText: _useBackup ? 'Backup Code' : 'Verification Code',
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _useBackup ? _verifyBackupCode : _verify,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: Text(_useBackup ? 'Verify Backup Code' : 'Verify'),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  _useBackup = !_useBackup;
                  _error = null;
                  codeController.clear();
                });
              },
              child:
                  Text(_useBackup ? 'Use SMS Code Instead' : 'Use Backup Code'),
            ),
          ],
        ),
      ),
    );
  }
}
