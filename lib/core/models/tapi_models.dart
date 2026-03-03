import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<ServiceCompany> companies;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.companies = const [],
  });
}

class ServiceCompany {
  final String id;
  final String name;
  final String categoryId;
  final String? logoUrl;

  const ServiceCompany({
    required this.id,
    required this.name,
    required this.categoryId,
    this.logoUrl,
  });

  factory ServiceCompany.fromJson(Map<String, dynamic> json) {
    return ServiceCompany(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class DebtQuery {
  final String reference;
  final double amount;
  final String company;
  final String concept;
  final String? dueDate;
  final String status;

  const DebtQuery({
    required this.reference,
    required this.amount,
    required this.company,
    required this.concept,
    this.dueDate,
    required this.status,
  });

  factory DebtQuery.fromJson(Map<String, dynamic> json) {
    return DebtQuery(
      reference: json['reference'] as String,
      amount: (json['amount'] as num).toDouble(),
      company: json['company'] as String,
      concept: json['concept'] as String? ?? '',
      dueDate: json['due_date'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class PaymentOrder {
  final String orderId;
  final double amount;
  final String status;
  final DateTime timestamp;
  final String? receiptUrl;
  final String company;
  final String reference;

  const PaymentOrder({
    required this.orderId,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.receiptUrl,
    required this.company,
    required this.reference,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      receiptUrl: json['receipt_url'] as String?,
      company: json['company'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }
}
