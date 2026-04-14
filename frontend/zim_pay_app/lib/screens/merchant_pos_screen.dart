import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert'; // Required for utf8 decoding

class MerchantPosScreen extends StatefulWidget {
  const MerchantPosScreen({super.key});

  @override
  State<MerchantPosScreen> createState() => _MerchantPosScreenState();
}

class _MerchantPosScreenState extends State<MerchantPosScreen> {
  final _amountController = TextEditingController();
  bool _isScanning = false;
  String _statusMessage = 'Enter amount and press "Ready to Charge"';

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _startNfcRead() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount first!')),
      );
      return;
    }

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() => _statusMessage = 'NFC is not available on this device.');
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Waiting for customer to tap ZimPay Card...';
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || ndef.cachedMessage == null) {
        _handleError('Tag is empty or not formatted correctly.');
        return;
      }

      try {
        // 1. Grab the first record on the tag
        final record = ndef.cachedMessage!.records.first;
        final payload = record.payload;

        // 2. Decode the NDEF Text Record (Strip out the 'en' language code)
        final languageCodeLength = payload[0] & 0x3F;
        final extractedToken = utf8.decode(payload.sublist(1 + languageCodeLength));

        NfcManager.instance.stopSession();

        if (mounted) {
          setState(() {
            _isScanning = false;
            _statusMessage = '✅ Card Read Successfully!\nProcessing payment...';
          });

          // 3. Trigger the Backend Payment
          _processPayment(extractedToken, _amountController.text);
        }
      } catch (e) {
        _handleError('Could not read ZimPay Token: $e');
      }
    });
  }

  void _handleError(String error) {
    NfcManager.instance.stopSession(errorMessage: error);
    if (mounted) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: $error';
      });
    }
  }

  void _processPayment(String secureToken, String amount) {
    // TODO: Dispatch a BLoC event here to send the Token + Amount to your .NET backend!
    debugPrint('💰 [POS] Attempting to charge \$$amount using Token: $secureToken');

    // Simulating network delay for the UI
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Approved ✅'),
            content: Text('Successfully charged \$$amount to ZimPay Card.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  setState(() {
                    _amountController.clear();
                    _statusMessage = 'Enter amount and press "Ready to Charge"';
                  });
                },
                child: const Text('New Transaction'),
              )
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ZimPay Terminal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0058BA),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                border: InputBorder.none,
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 48),

            // Scanner Status
            Icon(
              _isScanning ? Icons.contactless : Icons.point_of_sale,
              size: 80,
              color: _isScanning ? const Color(0xFF0058BA) : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 48),

            // Trigger Button
            if (!_isScanning)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startNfcRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0058BA),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ready to Charge', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}