using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;
using System.Linq;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class SetDefaultPaymentMethodCommandHandler : IRequestHandler<SetDefaultPaymentMethodCommand, bool>
    {
        private readonly IPaymentMethodRepository _paymentMethodRepository;

        public SetDefaultPaymentMethodCommandHandler(IPaymentMethodRepository paymentMethodRepository)
        {
            _paymentMethodRepository = paymentMethodRepository;
        }

        public async Task<bool> Handle(SetDefaultPaymentMethodCommand request, CancellationToken cancellationToken)
        {
            var paymentMethods = await _paymentMethodRepository.GetActiveByUserIdAsync(request.UserId);
            var methodsList = paymentMethods.ToList();

            var newDefault = methodsList.FirstOrDefault(pm => pm.Id == request.PaymentMethodId);
            if (newDefault == null)
            {
                return false;
            }

            foreach (var pm in methodsList)
            {
                pm.IsDefault = (pm.Id == request.PaymentMethodId);
                await _paymentMethodRepository.UpdateAsync(pm);
            }

            await _paymentMethodRepository.SaveChangesAsync();
            return true;
        }
    }
}