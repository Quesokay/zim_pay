using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class AddPaymentMethodCommandHandler : IRequestHandler<AddPaymentMethodCommand, int>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;
        private readonly IUserRepository _userRepository;

        public AddPaymentMethodCommandHandler(
            IPaymentMethodRepository paymentMethodRepository,
            IUserRepository userRepository)
        {
            _paymentMethodRepository = paymentMethodRepository;
            _userRepository = userRepository;
        }

        public async Task<int> Handle(AddPaymentMethodCommand request, CancellationToken cancellationToken)
        {
            // Verify user exists
            var userExists = await _userRepository.ExistsAsync(request.UserId);
            if (!userExists)
                throw new InvalidOperationException($"User with ID {request.UserId} not found.");

            // Mask card number: keep only last 4 digits for storage
            string fullNumber = (request.PaymentMethod.CardNumber ?? "").Replace(" ", "");
            string maskedCardNumber = fullNumber.Length >= 4
                ? fullNumber.Substring(fullNumber.Length - 4)
                : fullNumber;

            var paymentMethod = new ZimPay.Domain.PaymentMethod
            {
                UserId = request.UserId,
                Type = request.PaymentMethod.Type ?? "Credit Card",
                CardNumber = maskedCardNumber,
                BankName = request.PaymentMethod.BankName ?? "ZimPay Bank",
                AccountNumber = request.PaymentMethod.AccountNumber,
                HolderName = request.PaymentMethod.HolderName,
                ExpiryDate = request.PaymentMethod.ExpiryDate,
                IsDefault = request.PaymentMethod.IsDefault,
                IsActive = true,
                AddedAt = DateTime.UtcNow
            };

            // Handle default card logic
            var existingMethods = await _paymentMethodRepository.GetByUserIdAsync(request.UserId);
            if (!System.Linq.Enumerable.Any(existingMethods))
            {
                // First card is always default
                paymentMethod.IsDefault = true;
            }
            else if (paymentMethod.IsDefault)
            {
                // If new card is default, unmark previous default
                foreach (var existing in existingMethods)
                {
                    if (existing.IsDefault)
                    {
                        existing.IsDefault = false;
                        await _paymentMethodRepository.UpdateAsync(existing);
                    }
                }
            }

            await _paymentMethodRepository.AddAsync(paymentMethod);
            return paymentMethod.Id;
        }
    }
}
