using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging; // ADDED LOGGER
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class AddPaymentMethodCommandHandler : IRequestHandler<AddPaymentMethodCommand, string>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;
        private readonly IUserRepository _userRepository;
        private readonly ITokenizationService _tokenService;
        private readonly ILogger<AddPaymentMethodCommandHandler> _logger; // ADDED LOGGER

        public AddPaymentMethodCommandHandler(
            IPaymentMethodRepository paymentMethodRepository,
            IUserRepository userRepository,
            ITokenizationService tokenService,
            ILogger<AddPaymentMethodCommandHandler> logger) // INJECTED LOGGER
        {
            _paymentMethodRepository = paymentMethodRepository;
            _userRepository = userRepository;
            _tokenService = tokenService;
            _logger = logger;
        }

        public async Task<string> Handle(AddPaymentMethodCommand request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("🚀 [BACKEND] Received AddPaymentMethod request for User ID: {UserId}", request.UserId);

            var userExists = await _userRepository.ExistsAsync(request.UserId);
            if (!userExists)
            {
                _logger.LogWarning("❌ [BACKEND] User ID {UserId} was not found in the database. Aborting.", request.UserId);
                throw new InvalidOperationException($"User with ID {request.UserId} not found.");
            }

            string fullNumber = (request.PaymentMethod.CardNumber ?? "").Replace(" ", "");
            string maskedCardNumber;

            if (request.PaymentMethod.Type == CardType.EcoCash)
            {
                // Mask Zimbabwean Phone: +263 772 123 456 -> +263 ••• ••• 456
                maskedCardNumber = fullNumber.Length >= 3
                    ? $"+263 ••• ••• {fullNumber.Substring(fullNumber.Length - 3)}"
                    : fullNumber;
                _logger.LogInformation("📱 [BACKEND] Processing EcoCash. Masked Phone: {MaskedPhone}", maskedCardNumber);
            }
            else if (request.PaymentMethod.Type == CardType.BankAccount)
            {
                // Mask Bank Account: 12345678 -> •••• 5678
                maskedCardNumber = fullNumber.Length >= 4
                    ? $"•••• {fullNumber.Substring(fullNumber.Length - 4)}"
                    : fullNumber;
                _logger.LogInformation("🏦 [BACKEND] Processing Bank Account. Masked Account: {MaskedAccount}", maskedCardNumber);
            }
            else
            {
                // Mask Card: 4111222233334444 -> •••• 4444
                maskedCardNumber = fullNumber.Length >= 4
                    ? $"•••• {fullNumber.Substring(fullNumber.Length - 4)}"
                    : fullNumber;
                _logger.LogInformation("💳 [BACKEND] Processing Card. Masked Card: {MaskedCard}", maskedCardNumber);
            }

            var paymentMethod = new ZimPay.Domain.PaymentMethod
            {
                UserId = request.UserId,
                Type = request.PaymentMethod.Type,
                CardNumber = maskedCardNumber,
                BankName = request.PaymentMethod.Type == CardType.EcoCash ? "EcoCash" : (request.PaymentMethod.BankName ?? "ZimPay Bank"),
                AccountNumber = request.PaymentMethod.AccountNumber,
                HolderName = request.PaymentMethod.HolderName,
                ExpiryDate = request.PaymentMethod.ExpiryDate,
                IsDefault = request.PaymentMethod.IsDefault,
                IsActive = true,
                AddedAt = DateTime.UtcNow,
                DigitalToken = "PENDING_GENERATION"
            };

            var existingMethods = await _paymentMethodRepository.GetByUserIdAsync(request.UserId);
            if (!System.Linq.Enumerable.Any(existingMethods))
            {
                paymentMethod.IsDefault = true;
            }
            else if (paymentMethod.IsDefault)
            {
                foreach (var existing in existingMethods)
                {
                    if (existing.IsDefault)
                    {
                        existing.IsDefault = false;
                        await _paymentMethodRepository.UpdateAsync(existing);
                    }
                }
            }

            _logger.LogInformation("💾 [BACKEND] Saving preliminary record to SQLite database...");
            await _paymentMethodRepository.AddAsync(paymentMethod);

            _logger.LogInformation("🔐 [BACKEND] Generating JWT Digital Token for NFC usage...");
            paymentMethod.DigitalToken = _tokenService.GenerateDigitalToken(paymentMethod, fullNumber);
            
            await _paymentMethodRepository.UpdateAsync(paymentMethod);

            _logger.LogInformation("✅ [BACKEND] SUCCESS! Payment Method {MethodId} saved with Digital Token attached.", paymentMethod.Id);

            return paymentMethod.DigitalToken;
        }
    }
}