import 'wallet_item.dart';

class CreatePaymentMethodDto {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final CardType cardType;

  CreatePaymentMethodDto({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
    this.cardType = CardType.creditCard,
  });

  Map<String, dynamic> toJson() {
    return {
      "Type": cardType.index, // Send as integer for the enum on backend
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
