import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/two_factor_service.dart';
import 'two_factor_screen.dart';
import 'dart:math';

class TwoFactorSettingsScreen extends StatefulWidget {
  const TwoFactorSettingsScreen({super.key});

  @override
  State<TwoFactorSettingsScreen> createState() =>
      _TwoFactorSettingsScreenState();
}

class _TwoFactorSettingsScreenState extends State<TwoFactorSettingsScreen> {
  bool _loading = true;
  bool _enabled = false;
  String? _phone;
  List<String> _backupCodes = [];

  @override
  void initState() {
    super.initState();
    _load2FAStatus();
  }

  Future<void> _load2FAStatus() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _enabled = doc.data()?['twoFactorEnabled'] ?? false;
      _phone = doc.data()?['phoneNumber'];
      _backupCodes = List<String>.from(doc.data()?['backupCodes'] ?? []);
      _loading = false;
    });
  }

  Future<void> _set2FAStatus(bool enabled) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'twoFactorEnabled': enabled,
    }, SetOptions(merge: true));
    setState(() {
      _enabled = enabled;
    });
  }

  Future<void> _changePhone() async {
    final phoneController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Phone Number'),
        content: TextField(
          controller: phoneController,
          decoration:
              const InputDecoration(labelText: 'New Phone (+1234567890)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Change')),
        ],
      ),
    );
    if (ok == true && phoneController.text.isNotEmpty) {
      await TwoFactorService().sendCode(phoneController.text.trim());
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TwoFactorScreen(
          onVerified: () async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'phoneNumber': phoneController.text.trim(),
            }, SetOptions(merge: true));
            setState(() {
              _phone = phoneController.text.trim();
            });
            Navigator.of(context).pop();
          },
        ),
      ));
    }
  }

  Future<void> _generateBackupCodes() async {
    final codes = List.generate(5, (_) => _randomCode());
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'backupCodes': codes,
    }, SetOptions(merge: true));
    setState(() {
      _backupCodes = codes;
    });
  }

  String _randomCode() {
    final rand = Random.secure();
    return List.generate(8, (_) => rand.nextInt(10)).join();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Factor Authentication Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('2FA Status: ', style: TextStyle(fontSize: 18)),
                Switch(
                  value: _enabled,
                  onChanged: (val) async {
                    if (!val) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Disable 2FA'),
                          content: const Text(
                              'Are you sure you want to disable two-factor authentication?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Disable')),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                    }
                    await _set2FAStatus(val);
                  },
                ),
                Text(_enabled ? 'Enabled' : 'Disabled',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Phone Number: ${_phone ?? "Not set"}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _changePhone,
              child: const Text('Change Phone Number'),
            ),
            const SizedBox(height: 24),
            const Text('Backup Codes:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_backupCodes.isEmpty)
              ElevatedButton(
                onPressed: _generateBackupCodes,
                child: const Text('Generate Backup Codes'),
              ),
            if (_backupCodes.isNotEmpty)
              ..._backupCodes.map((code) => Row(
                    children: [
                      Text(code,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied!')));
                        },
                      ),
                    ],
                  )),
            if (_backupCodes.isNotEmpty)
              ElevatedButton(
                onPressed: _generateBackupCodes,
                child: const Text('Regenerate Backup Codes'),
              ),
          ],
        ),
      ),
    );
  }
}
