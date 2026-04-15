using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;
using ZimPay.Application.Queries;

namespace ZimPay.Application.Handlers.QueryHandlers
{
    public class GetPaymentMethodsByUserIdQueryHandler : IRequestHandler<GetPaymentMethodsByUserIdQuery, List<PaymentMethodDto>>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;

        public GetPaymentMethodsByUserIdQueryHandler(IPaymentMethodRepository paymentMethodRepository)
        {
            _paymentMethodRepository = paymentMethodRepository;
        }

        public async Task<List<PaymentMethodDto>> Handle(GetPaymentMethodsByUserIdQuery request, CancellationToken cancellationToken)
        {
            IEnumerable<ZimPay.Domain.PaymentMethod> paymentMethods;

            if (request.OnlyActive)
            {
                paymentMethods = await _paymentMethodRepository.GetActiveByUserIdAsync(request.UserId);
            }
            else
            {
                paymentMethods = await _paymentMethodRepository.GetByUserIdAsync(request.UserId);
            }

            return paymentMethods.Select(pm => new PaymentMethodDto
            {
                Id = pm.Id,
                UserId = pm.UserId,
                Type = pm.Type,
                CardNumber = pm.CardNumber,
                BankName = pm.BankName,
                AccountNumber = pm.AccountNumber,
                HolderName = pm.HolderName,
                ExpiryDate = pm.ExpiryDate,
                IsDefault = pm.IsDefault,
                IsActive = pm.IsActive,
                AddedAt = pm.AddedAt,
                UpdatedAt = pm.UpdatedAt
            }).ToList();
        }
    }
}
