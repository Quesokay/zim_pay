using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class DeletePaymentMethodCommandHandler : IRequestHandler<DeletePaymentMethodCommand, bool>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;

        public DeletePaymentMethodCommandHandler(IPaymentMethodRepository paymentMethodRepository)
        {
            _paymentMethodRepository = paymentMethodRepository;
        }

        public async Task<bool> Handle(DeletePaymentMethodCommand request, CancellationToken cancellationToken)
        {
            var paymentMethod = await _paymentMethodRepository.GetByIdAsync(request.Id);

            if (paymentMethod == null || paymentMethod.UserId != request.UserId)
            {
                return false;
            }

            await _paymentMethodRepository.DeleteAsync(request.Id);
            return true;
        }
    }
}
