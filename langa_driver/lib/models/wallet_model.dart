import 'package:flutter/foundation.dart' show immutable, required;
import 'package:langas_driver/utils/delivery_enums.dart';
import 'package:langas_driver/utils/app_enums.dart';
import 'package:langas_driver/models/delivery_models.dart' show Pagination;

@immutable
class WalletFloat {
  final int id;
  final double runningBalance;
  final String transactionRef;
  final DateTime? dateCreated;
  final int walletId;
  final String currencyCode;
  final int currencyId;
  final WalletBalanceType balanceType;
  final WalletAccountType walletAccountType;
  final WalletOwnerType ownerType;

  const WalletFloat({
    required this.id,
    required this.runningBalance,
    required this.transactionRef,
    this.dateCreated,
    required this.walletId,
    required this.currencyCode,
    required this.currencyId,
    required this.balanceType,
    required this.walletAccountType,
    required this.ownerType,
  });

  factory WalletFloat.fromJson(Map<String, dynamic> json) {
    return WalletFloat(
      id: json['id'] as int? ?? 0,
      runningBalance: (json['runningBalance'] as num?)?.toDouble() ?? 0.0,
      transactionRef: json['transactionRef'] as String? ?? '',
      dateCreated: json['dateCreated'] != null
          ? DateTime.tryParse(json['dateCreated'] as String)
          : null,
      walletId: json['walletId'] as int? ?? 0,
      currencyCode: json['currencyCode'] as String? ?? '',
      currencyId: json['currencyId'] as int? ?? 0,
      balanceType: WalletBalanceType.fromJson(json['balanceType'] as String?),
      walletAccountType:
          WalletAccountType.fromJson(json['walletAccountType'] as String?),
      ownerType: WalletOwnerType.fromJson(json['ownerType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'runningBalance': runningBalance,
      'transactionRef': transactionRef,
      'dateCreated': dateCreated?.toIso8601String(),
      'walletId': walletId,
      'currencyCode': currencyCode,
      'currencyId': currencyId,
      'balanceType': balanceType.toJson(),
      'walletAccountType': walletAccountType.toJson(),
      'ownerType': ownerType.toJson(),
    };
  }
}

@immutable
class WalletTransaction {
  final String id;
  final TransactionType type;
  final double principalAmount;
  final String? paymentLink;
  final String? pollUrl;
  final int? sourceWalletNumber;
  final int? destinationWalletNumber;
  final int? commissionWalletNumber;
  final double? commissionAmount;
  final String reference;
  final TransactionStatus status;
  final String narration;
  final int? clientId;
  final int? driverId;
  final int? organizationId;
  final PaymentMethod paymentMethod;
  final DateTime? createdDate;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.principalAmount,
    this.paymentLink,
    this.pollUrl,
    this.sourceWalletNumber,
    this.destinationWalletNumber,
    this.commissionWalletNumber,
    this.commissionAmount,
    required this.reference,
    required this.status,
    required this.narration,
    this.clientId,
    this.driverId,
    this.organizationId,
    required this.paymentMethod,
    this.createdDate,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String? ?? '',
      type: TransactionType.fromJson(json['type'] as String?),
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentLink: json['paymentLink'] as String?,
      pollUrl: json['pollUrl'] as String?,
      sourceWalletNumber: json['sourceWalletNumber'] as int?,
      destinationWalletNumber: json['destinationWalletNumber'] as int?,
      commissionWalletNumber: json['commissionWalletNumber'] as int?,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      reference: json['reference'] as String? ?? '',
      status: TransactionStatus.fromJson(json['status'] as String?),
      narration: json['narration'] as String? ?? '',
      clientId: json['clientId'] as int?,
      driverId: json['driverId'] as int?,
      organizationId: json['organizationId'] as int?,
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'principalAmount': principalAmount,
      'paymentLink': paymentLink,
      'pollUrl': pollUrl,
      'sourceWalletNumber': sourceWalletNumber,
      'destinationWalletNumber': destinationWalletNumber,
      'commissionWalletNumber': commissionWalletNumber,
      'commissionAmount': commissionAmount,
      'reference': reference,
      'status': status.toJson(),
      'narration': narration,
      'clientId': clientId,
      'driverId': driverId,
      'organizationId': organizationId,
      'paymentMethod': paymentMethod.toJson(),
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}

@immutable
class PaginatedWalletTransactions {
  final List<WalletTransaction> content;
  final Pagination pagination;

  const PaginatedWalletTransactions({
    required this.content,
    required this.pagination,
  });

  factory PaginatedWalletTransactions.fromJson(Map<String, dynamic> json) {
    var contentList = <WalletTransaction>[];
    if (json['content'] is List) {
      contentList = (json['content'] as List)
          .map((item) =>
              WalletTransaction.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return PaginatedWalletTransactions(
      content: contentList,
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((transaction) => transaction.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
