// To parse this JSON data, do
//
//     final pendingOrder = pendingOrderFromJson(jsonString);

import 'dart:convert';

PendingOrder pendingOrderFromJson(String str) => PendingOrder.fromJson(json.decode(str));

String pendingOrderToJson(PendingOrder data) => json.encode(data.toJson());

class PendingOrder {
  PendingOrder({
    required this.message,
    required this.success,
    required this.serverTime,
    required this.data,
    required this.pageNo,
    required this.pageSize,
    required this.totalPages,
    required this.totalCount,
    required this.isLast,
  });

  String? message;
  bool? success;
  int? serverTime;
  PendingOrderData? data;
  int? pageNo;
  int? pageSize;
  int? totalPages;
  int? totalCount;
  bool? isLast;

  factory PendingOrder.fromJson(Map<String, dynamic> json) => PendingOrder(
    message: json["message"],
    success: json["success"],
    serverTime: json["serverTime"],
    data: PendingOrderData.fromJson(json["data"]),
    pageNo: json["pageNo"],
    pageSize: json["pageSize"],
    totalPages: json["totalPages"],
    totalCount: json["totalCount"],
    isLast: json["isLast"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "success": success,
    "serverTime": serverTime,
    "data": data?.toJson(),
    "pageNo": pageNo,
    "pageSize": pageSize,
    "totalPages": totalPages,
    "totalCount": totalCount,
    "isLast": isLast,
  };
}

class PendingOrderCopy {
  PendingOrderCopy({
    required this.message,
    required this.success,
    required this.serverTime,
    required this.data,
    required this.pageNo,
    required this.pageSize,
    required this.totalPages,
    required this.totalCount,
    required this.isLast,
  });

  String? message;
  bool? success;
  int? serverTime;
  PendingOrderData? data;
  int? pageNo;
  int? pageSize;
  int? totalPages;
  int? totalCount;
  bool? isLast;

  factory PendingOrderCopy.fromJson(Map<String, dynamic> json) => PendingOrderCopy(
    message: json["message"],
    success: json["success"],
    serverTime: json["serverTime"],
    data: PendingOrderData.fromJson(json["data"]),
    pageNo: json["pageNo"],
    pageSize: json["pageSize"],
    totalPages: json["totalPages"],
    totalCount: json["totalCount"],
    isLast: json["isLast"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "success": success,
    "serverTime": serverTime,
    "data": data?.toJson(),
    "pageNo": pageNo,
    "pageSize": pageSize,
    "totalPages": totalPages,
    "totalCount": totalCount,
    "isLast": isLast,
  };
}

class PendingOrderData {
  PendingOrderData({
    required this.unpaidOrders,
  });

  List<UnpaidOrder> unpaidOrders;

  factory PendingOrderData.fromJson(Map<String, dynamic> json) => PendingOrderData(
    unpaidOrders: List<UnpaidOrder>.from(json["unpaidOrders"].map((x) => UnpaidOrder.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "unpaidOrders": List<dynamic>.from(unpaidOrders.map((x) => x.toJson())),
  };
}

class UnpaidOrder {
  UnpaidOrder({
    required this.name,
    required this.totalAmount,
    this.payableAmount,
    this.paidAmount,
    required this.vehCount,
    required this.vehNums,
    required this.pkgeName,
    this.pkgDescription,
    required this.orderId,
  });

  String? name;
  double? totalAmount;
  double? payableAmount;
  double? paidAmount;
  int? vehCount;
  List<String> vehNums = [];
  String? pkgeName;
  dynamic pkgDescription;
  int? orderId;
  bool isSelected = true;

  factory UnpaidOrder.fromJson(Map<String, dynamic> json) => UnpaidOrder(
    name: json["name"],
    totalAmount: json["totalAmount"],
    payableAmount: json["payableAmount"],
    paidAmount: json["paidAmount"],
    vehCount: json["vehCount"],
    vehNums: List<String>.from(json["vehNums"].map((x) => x)),
    pkgeName: json["pkgeName"],
    pkgDescription: json["pkgDescription"],
    orderId: json["orderId"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "totalAmount": totalAmount,
    "payableAmount": payableAmount,
    "paidAmount": paidAmount,
    "vehCount": vehCount,
    "vehNums": List<dynamic>.from(vehNums.map((x) => x)),
    "pkgeName": pkgeName,
    "pkgDescription": pkgDescription,
    "orderId": orderId,
  };
}
