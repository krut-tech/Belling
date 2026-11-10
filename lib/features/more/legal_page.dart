import 'package:flutter/material.dart';

/// Plain-language privacy and compliance notes shown inside the app.
class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  static const _sections = <(String, String)>[
    (
      'Your data',
      'Bills, items and customer details (names, phone numbers, GSTIN) are stored on this phone. '
          'If you sign in, they are also copied to your private cloud account so you can restore or use '
          'another device. We do not sell your data or use it for advertising. You are the owner of the '
          'data and responsible for the customers\' details you enter.',
    ),
    (
      'Customer privacy (DPDP Act, 2023)',
      'You collect customers\' phone numbers and GSTIN only to bill them and send dues reminders. '
          'Collect only what you need, use it only for billing, and delete a customer\'s details if they ask '
          '(Parties > edit/delete) unless a law requires you to keep the bills.',
    ),
    (
      'Keeping records',
      'GST law requires invoices and books to be kept for at least 6 years after the due date of the annual return. '
          'Issued invoices cannot be edited or deleted in Belling: cancel with a credit note. '
          'Take regular backups (More > Backup).',
    ),
    (
      'Tax accuracy',
      'Belling calculates GST from the rates you set. HSN codes, GST rates, e-invoice and e-way bill '
          'limits change; check them with your CA. Files made for GSTR-1, e-invoice and e-way bill are '
          'helpers, not filed returns: verify before uploading. Belling is not tax or legal advice.',
    ),
    (
      'When to use which document',
      'Shops registered under the composition scheme or not registered for GST must issue a Bill of Supply and '
          'must not charge GST. Set your GSTIN in Business settings only if you are registered. '
          'E-invoicing is mandatory above the turnover limit notified by the government.',
    ),
    (
      'Reminders and messages',
      'Send payment reminders only to customers who owe you, at reasonable times. Do not send promotional '
          'messages without the customer\'s consent.',
    ),
    (
      'App lock and device safety',
      'The PIN lock protects the app on this phone. Keep your phone updated, and install Belling updates only '
          'from the official release page.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & legal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final s in _sections) ...[
            Text(s.$1, style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(s.$2, style: t.bodyMedium),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
