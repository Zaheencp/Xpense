import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final bool isSyncing;

  const SyncIndicator({super.key, required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    return isSyncing
        ? const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 8),
              Text('Syncing...'),
            ],
          )
        : const Text('Up to date');
  }
}
