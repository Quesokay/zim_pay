using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class ProcessTransactionCommandHandler : IRequestHandler<ProcessTransactionCommand, bool>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;
        private readonly ITransactionRepository _transactionRepository;
        private readonly ILogger<ProcessTransactionCommandHandler> _logger;

        public ProcessTransactionCommandHandler(
            IPaymentMethodRepository paymentMethodRepository,
            ITransactionRepository transactionRepository,
            ILogger<ProcessTransactionCommandHandler> logger)
        {
            _paymentMethodRepository = paymentMethodRepository;
            _transactionRepository = transactionRepository;
            _logger = logger;
        }

        public async Task<bool> Handle(ProcessTransactionCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("💳 [POS] Received transaction request for {Amount}", request.Amount);

            // 1. Find the card tied to this NFC tag
            var paymentMethod = await _paymentMethodRepository.GetByTokenAsync(request.DigitalToken);
            
            if (paymentMethod == null || !paymentMethod.IsActive)
            {
                _logger.LogWarning("❌ [POS] Transaction declined: Invalid or deactivated NFC token.");
                return false; 
            }

            // 2. Create the Transaction Record
            var transaction = new Transaction
            {
                UserId = paymentMethod.UserId,
                PaymentMethodId = paymentMethod.Id,
                Amount = request.Amount,
                Type = "Payment",
                Status = "Completed",
                Date = DateTime.UtcNow,
                Description = "ZimPay Tap-to-Pay POS"
            };

            await _transactionRepository.AddAsync(transaction);
            
            _logger.LogInformation("✅ [POS] SUCCESS! Charged ${Amount} to User {UserId} via Card {CardId}", 
                request.Amount, paymentMethod.UserId, paymentMethod.Id);

            return true;
        }
    }
}