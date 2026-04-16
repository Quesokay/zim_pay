using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using ZimPay.Application.Commands.Transaction;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class ProcessTransactionCommandHandler : IRequestHandler<ProcessTransactionCommand, bool>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;
        private readonly ITransactionRepository _transactionRepository;
        private readonly ILogger<ProcessTransactionCommandHandler> _logger;
        private readonly IUserRepository _userRepository;

        public ProcessTransactionCommandHandler(
            IPaymentMethodRepository paymentMethodRepository,
            ITransactionRepository transactionRepository,
            ILogger<ProcessTransactionCommandHandler> logger,
            IUserRepository userRepository)
        {
            _paymentMethodRepository = paymentMethodRepository;
            _transactionRepository = transactionRepository;
            _logger = logger;
            _userRepository = userRepository;
        }

    public async Task<bool> Handle(ProcessTransactionCommand request, CancellationToken cancellationToken)
    {
        _logger.LogInformation("💳 [POS] Processing transaction: Amount=${Amount}, Token={Token}", request.Amount, request.DigitalToken);

        // 1. ✨ IDENTITY VERIFICATION ✨
        var user = await _userRepository.GetByNfcTokenAsync(request.DigitalToken);
        
        if (user == null)
        {
            _logger.LogWarning("❌ [POS] Transaction declined: Token {Token} not found in database.", request.DigitalToken);
            throw new InvalidOperationException("Transaction Declined: Unrecognized NFC tag.");
        }

        if (!user.ContactlessEnabled)
        {
            _logger.LogWarning("❌ [POS] Transaction declined: User {UserId} has contactless disabled.", user.Id);
            throw new InvalidOperationException("Transaction Declined: Contactless payments are disabled for this user.");
        }

        _logger.LogInformation("👤 [POS] Verified User: {UserName} (ID: {UserId})", user.Name, user.Id);

        // 2. ✨ DIGITAL CUSTODIAN ROUTING ✨
        // The user was found. Now find their currently selected active card.
        var activeCard = user.PaymentMethods.FirstOrDefault(c => c.IsDefault && c.IsActive);

        if (activeCard == null)
            throw new InvalidOperationException("Transaction Declined: No active default payment method selected on your phone.");

        // 3. Check Balance on the specific card
        if (activeCard.Balance < request.Amount)
            throw new InvalidOperationException($"Transaction Declined: Insufficient funds on {activeCard.BankName}.");

        // 4. Biometric Limit Check
        if (request.Amount > user.TapLimit)
        {
            var pendingTransaction = new Transaction
            {
                UserId = user.Id,
                PaymentMethodId = activeCard.Id, 
                Amount = request.Amount,
                Type = "Payment",
                Status = "Pending",
                Date = DateTime.UtcNow,
                MerchantName = request.MerchantName,
                Description = "ZimPay Tap-to-Pay POS"
            };
            await _transactionRepository.AddAsync(pendingTransaction);
            throw new InvalidOperationException($"BIOMETRIC_REQUIRED:{pendingTransaction.Id}");
        }

        // 5. Auto-Approve & Deduct
        activeCard.DeductFunds(request.Amount);
        await _paymentMethodRepository.UpdateAsync(activeCard); 

        var transaction = new Transaction
        {
            UserId = user.Id,
            PaymentMethodId = activeCard.Id,
            Amount = request.Amount,
            Type = "Payment",
            Status = "Completed",
            MerchantName = request.MerchantName,
            Date = DateTime.UtcNow,
            Description = "ZimPay Tap-to-Pay POS"
        };
        await _transactionRepository.AddAsync(transaction);
        
        return true;
    }
    }
}