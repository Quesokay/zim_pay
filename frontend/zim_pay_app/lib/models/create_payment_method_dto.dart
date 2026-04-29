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
    String bankName = "ZimPay Bank";
    String accountNumber = "N/A";

    if (cardType == CardType.ecocash) {
      bankName = "EcoCash";
      accountNumber = cardNumber; // Storing phone in account number for ecocash
    } else if (cardType == CardType.bankAccount) {
      bankName = "Universal Bank";
      accountNumber = cardNumber;
    }

    return {
      "Type": cardType.index, // Send as integer for the enum on backend
      "CardNumber": cardNumber,
      "BankName": bankName,
      "AccountNumber": accountNumber,
      "HolderName": cardHolderName, 
      "ExpiryDate": expiryDate,
      "CVV": cvv,
      "IsDefault": true
    };
  }
}
