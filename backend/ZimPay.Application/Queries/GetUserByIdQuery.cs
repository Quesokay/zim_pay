using MediatR;
using ZimPay.Application.DTOs;

namespace ZimPay.Application.Queries
{
    public class GetUserByIdQuery : IRequest<UserDetailDto>
    {
        public int UserId { get; set; }

        public GetUserByIdQuery(int userId)
        {
            UserId = userId;
        }
    }
}
