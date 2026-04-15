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
    public class GetPassesByUserIdQueryHandler : IRequestHandler<GetPassesByUserIdQuery, List<PassDto>>
    {
        private readonly IPassRepository _passRepository;

        public GetPassesByUserIdQueryHandler(IPassRepository passRepository)
        {
            _passRepository = passRepository;
        }

        public async Task<List<PassDto>> Handle(GetPassesByUserIdQuery request, CancellationToken cancellationToken)
        {
            IEnumerable<ZimPay.Domain.Pass> passes;

            if (request.OnlyActive)
            {
                passes = await _passRepository.GetActiveByUserIdAsync(request.UserId);
            }
            else
            {
                passes = await _passRepository.GetByUserIdAsync(request.UserId);
            }

            return passes.Select(p => new PassDto
            {
                Id = p.Id,
                UserId = p.UserId,
                Type = p.Type,
                Title = p.Title,
                Details = p.Details,
                IssuerId = p.IssuerId,
                IssuerName = p.IssuerName,
                PassNumber = p.PassNumber,
                Barcode = p.Barcode,
                Balance = p.Balance,
                Color = p.Color,
                ImageUrl = p.ImageUrl,
                IssuedAt = p.IssuedAt,
                ExpiresAt = p.ExpiresAt,
                IsActive = p.IsActive
            }).ToList();
        }
    }
}
