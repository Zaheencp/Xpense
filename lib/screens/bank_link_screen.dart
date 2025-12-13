import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/bank_integration_service.dart';
import 'transaction_list_screen.dart';

class BankLinkScreen extends StatefulWidget {
  const BankLinkScreen({super.key});

  @override
  _BankLinkScreenState createState() => _BankLinkScreenState();
}

class _BankLinkScreenState extends State<BankLinkScreen> {
  String? _linkToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _createLinkToken();
  }

  Future<void> _createLinkToken() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/plaid/create_link_token'),
    );
    final data = jsonDecode(response.body);
    setState(() {
      _linkToken = data['link_token'];
      _isLoading = false;
    });
  }

  Future<void> _handlePublicToken(String publicToken) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final accessToken =
          await BankIntegrationService().linkAccount(publicToken);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                TransactionListScreen(accessToken: accessToken),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to link account: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Link Bank Account')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_linkToken == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Link Bank Account')),
        body: const Center(child: Text('Failed to get link token.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Link Bank Account')),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                // Replace with your actual redirect URI
                if (request.url.contains('http://localhost:3000/redirect')) {
                  final uri = Uri.parse(request.url);
                  final publicToken = uri.queryParameters['public_token'];
                  if (publicToken != null) {
                    _handlePublicToken(publicToken);
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://sandbox.plaid.com/link/?token=$_linkToken'),
          ),
      ),
    );
  }
}
