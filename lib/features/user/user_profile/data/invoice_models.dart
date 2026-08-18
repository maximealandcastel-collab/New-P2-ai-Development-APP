

// ═══════════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/cupertino.dart';

enum InvoiceStatus { paid, pending }

class InvoiceItem {
  final String title;
  final String client;
  final String billedAgo;
  final double amount;
  final InvoiceStatus status;

  const InvoiceItem({
    required this.title,
    required this.client,
    required this.billedAgo,
    required this.amount,
    required this.status,
  });
}

class LineItem {
  final String description;
  final String subtitle;
  final double amount;
  final bool isBold;
  final bool isNegative;
  final bool isHighlighted;

  const LineItem({
    required this.description,
    this.subtitle = '',
    required this.amount,
    this.isBold = false,
    this.isNegative = false,
    this.isHighlighted = false,
  });
}

class PaymentMethod {
  final String name;
  final String assetIcon; // use icon instead
  final IconData icon;
  final Color iconColor;

  const PaymentMethod({
    required this.name,
    required this.icon,
    required this.iconColor,
    this.assetIcon = '',
  });
}
