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

            var paymentMethod = new PaymentMethod
            {
                UserId = request.UserId,
                Type = request.PaymentMethod.Type,
                CardNumber = request.PaymentMethod.CardNumber,
                BankName = request.PaymentMethod.BankName,
                AccountNumber = request.PaymentMethod.AccountNumber,
                HolderName = request.PaymentMethod.HolderName,
                ExpiryDate = request.PaymentMethod.ExpiryDate,
                IsDefault = request.PaymentMethod.IsDefault,
                IsActive = true,
                AddedAt = DateTime.UtcNow
            };

            // If this is the first payment method or marked as default, set as default
            var existingMethods = await _paymentMethodRepository.GetByUserIdAsync(request.UserId);
            if (!System.Linq.Enumerable.Any(existingMethods))
            {
                paymentMethod.IsDefault = true;
            }

            await _paymentMethodRepository.AddAsync(paymentMethod);
            return paymentMethod.Id;
        }
    }
}
