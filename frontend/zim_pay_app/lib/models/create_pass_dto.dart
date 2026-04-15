class CreatePassDto {
  final String type; // "Ticket", "Loyalty", "TransitPass", "BoardingPass", "EventPass"
  final String title;
  final String details;
  final String issuerId;
  final String issuerName;
  final String passNumber;
  final String barcode;
  final double balance;
  final String color;
  final String? imageUrl;
  final DateTime? expiresAt;

  CreatePassDto({
    required this.type,
    required this.title,
    required this.details,
    required this.issuerId,
    required this.issuerName,
    required this.passNumber,
    required this.barcode,
    required this.balance,
    required this.color,
    this.imageUrl,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "Type": type,
      "Title": title,
      "Details": details,
      "IssuerId": issuerId,
      "IssuerName": issuerName,
      "PassNumber": passNumber,
      "Barcode": barcode,
      "Balance": balance,
      "Color": color,
      "ImageUrl": imageUrl,
      "ExpiresAt": expiresAt?.toIso8601String(),
    };
  }
}
