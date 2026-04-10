using System.Collections.Generic;
using System.Threading.Tasks;
using ZimPay.Domain;

namespace ZimPay.Application.Interfaces
{
    public interface IPassRepository
    {
        Task<IEnumerable<Pass>> GetByUserIdAsync(int userId);
        Task<IEnumerable<Pass>> GetActiveByUserIdAsync(int userId);
        Task<Pass> GetByIdAsync(int id);
        Task<Pass> GetByPassNumberAsync(string passNumber);
        Task<bool> ExistsAsync(int id);
        Task AddAsync(Pass pass);
        Task UpdateAsync(Pass pass);
        Task DeleteAsync(int id);
        Task SaveChangesAsync();
    }
}