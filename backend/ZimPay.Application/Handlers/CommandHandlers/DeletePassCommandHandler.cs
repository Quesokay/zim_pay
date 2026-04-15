using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.Interfaces;

namespace ZimPay.Application.Handlers.CommandHandlers
{
    public class DeletePassCommandHandler : IRequestHandler<DeletePassCommand, bool>
    {
        private readonly IPassRepository _passRepository;

        public DeletePassCommandHandler(IPassRepository passRepository)
        {
            _passRepository = passRepository;
        }

        public async Task<bool> Handle(DeletePassCommand request, CancellationToken cancellationToken)
        {
            var pass = await _passRepository.GetByIdAsync(request.Id);

            if (pass == null || pass.UserId != request.UserId)
            {
                return false;
            }

            await _passRepository.DeleteAsync(request.Id);
            return true;
        }
    }
}
