class CreatePaymentMethodDto {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;

  CreatePaymentMethodDto({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
  });

  Map<String, dynamic> toJson() {
    return {
      "Type": "Visa",               // Hardcode a default or add to constructor
      "CardNumber": cardNumber,
      "BankName": "ZimPay Bank",    // Required by your backend
      "AccountNumber": "N/A",       // Required by your backend
      "HolderName": cardHolderName, 
      "ExpiryDate": expiryDate,
      "CVV": cvv,
      "IsDefault": true
    };
  }
}
