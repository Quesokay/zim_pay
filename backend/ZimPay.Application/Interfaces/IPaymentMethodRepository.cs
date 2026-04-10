using System.Collections.Generic;
using System.Threading.Tasks;
using ZimPay.Domain;

namespace ZimPay.Application.Interfaces
{
    public interface IPaymentMethodRepository
    {
        Task<IEnumerable<PaymentMethod>> GetByUserIdAsync(int userId);
        Task<IEnumerable<PaymentMethod>> GetActiveByUserIdAsync(int userId);
        Task<PaymentMethod> GetByIdAsync(int id);
        Task<PaymentMethod> GetDefaultByUserIdAsync(int userId);
        Task<bool> ExistsAsync(int id);
        Task AddAsync(PaymentMethod paymentMethod);
        Task UpdateAsync(PaymentMethod paymentMethod);
        Task DeleteAsync(int id);
        Task SaveChangesAsync();
    }
}