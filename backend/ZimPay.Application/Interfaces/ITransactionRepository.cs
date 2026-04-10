using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ZimPay.Domain;

namespace ZimPay.Application.Interfaces
{
    public interface ITransactionRepository
    {
        Task<IEnumerable<Transaction>> GetByUserIdAsync(int userId);
        Task<IEnumerable<Transaction>> GetByUserIdPaginatedAsync(int userId, int pageNumber, int pageSize);
        Task<IEnumerable<Transaction>> GetByDateRangeAsync(int userId, DateTime startDate, DateTime endDate);
        Task<Transaction> GetByIdAsync(int id);
        Task<bool> ExistsAsync(int id);
        Task<int> GetCountByUserIdAsync(int userId);
        Task AddAsync(Transaction transaction);
        Task UpdateAsync(Transaction transaction);
        Task DeleteAsync(int id);
        Task SaveChangesAsync();
    }
}