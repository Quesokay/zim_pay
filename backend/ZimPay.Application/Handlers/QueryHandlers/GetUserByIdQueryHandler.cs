using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZimPay.Application.DTOs;
using ZimPay.Application.Interfaces;
using ZimPay.Application.Queries;

namespace ZimPay.Application.Handlers.QueryHandlers
{
    public class GetUserByIdQueryHandler : IRequestHandler<GetUserByIdQuery, UserDetailDto>
    {
        private readonly IUserRepository _userRepository;

        public GetUserByIdQueryHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<UserDetailDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByIdAsync(request.UserId);
            
            if (user == null)
                return null;

            return new UserDetailDto
            {
                Id = user.Id,
                Email = user.Email,
                Name = user.Name,
                Phone = user.Phone,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt,
                IsActive = user.IsActive,
                FingerprintEnabled = user.FingerprintEnabled,
                ContactlessEnabled = user.ContactlessEnabled,
                TapLimit = user.TapLimit,
                PaymentMethods = user.PaymentMethods != null ? new System.Collections.Generic.List<PaymentMethodDto>(
                    System.Linq.Enumerable.Select(user.PaymentMethods, pm => new PaymentMethodDto
                    {
                        Id = pm.Id,
                        UserId = pm.UserId,
                        Type = pm.Type,
                        CardNumber = pm.CardNumber,
                        BankName = pm.BankName,
                        AccountNumber = pm.AccountNumber,
                        HolderName = pm.HolderName,
                        ExpiryDate = pm.ExpiryDate,
                        Balance = pm.Balance,
                        IsDefault = pm.IsDefault,
                        IsActive = pm.IsActive,
                        AddedAt = pm.AddedAt,
                        UpdatedAt = pm.UpdatedAt,
                        DigitalToken = pm.DigitalToken
                    })
                ) : new System.Collections.Generic.List<PaymentMethodDto>(),
                Transactions = user.SentTransactions != null ? new System.Collections.Generic.List<TransactionDto>(
                    System.Linq.Enumerable.Select(user.SentTransactions, t => new TransactionDto
                    {
                        Id = t.Id,
                        UserId = t.UserId,
                        Type = t.Type,
                        Amount = t.Amount,
                        Description = t.Description,
                        Status = t.Status,
                        Date = t.Date,
                        CompletedAt = t.CompletedAt,
                        RecipientUserId = t.RecipientUserId,
                        PaymentMethodId = t.PaymentMethodId
                    })
                ) : new System.Collections.Generic.List<TransactionDto>(),
                Passes = user.Passes != null ? new System.Collections.Generic.List<PassDto>(
                    System.Linq.Enumerable.Select(user.Passes, p => new PassDto
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
                    })
                ) : new System.Collections.Generic.List<PassDto>()
            };
        }
    }
}
