using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Infrastructure.Repositories
{
    public class TransactionRepository : ITransactionRepository
    {
        private readonly AppDbContext _context;

        public TransactionRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Transaction>> GetByUserIdAsync(int userId)
        {
            return await _context.Transactions
                .Where(t => t.UserId == userId)
                .Include(t => t.User)
                .Include(t => t.Recipient)
                .OrderByDescending(t => t.Date)
                .ToListAsync();
        }

        public async Task<IEnumerable<Transaction>> GetByUserIdPaginatedAsync(int userId, int pageNumber, int pageSize)
        {
            return await _context.Transactions
                .Where(t => t.UserId == userId)
                .Include(t => t.User)
                .Include(t => t.Recipient)
                .OrderByDescending(t => t.Date)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<IEnumerable<Transaction>> GetByDateRangeAsync(int userId, DateTime startDate, DateTime endDate)
        {
            return await _context.Transactions
                .Where(t => t.UserId == userId && t.Date >= startDate && t.Date <= endDate)
                .Include(t => t.User)
                .Include(t => t.Recipient)
                .OrderByDescending(t => t.Date)
                .ToListAsync();
        }

        public async Task<Transaction> GetByIdAsync(int id)
        {
            return await _context.Transactions
                .Include(t => t.User)
                .Include(t => t.Recipient)
                .FirstOrDefaultAsync(t => t.Id == id);
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.Transactions.AnyAsync(t => t.Id == id);
        }

        public async Task<int> GetCountByUserIdAsync(int userId)
        {
            return await _context.Transactions.CountAsync(t => t.UserId == userId);
        }

        public async Task<IEnumerable<Transaction>> GetPendingByUserIdAsync(int userId)
        {
            return await _context.Transactions
                .Where(t => t.UserId == userId && t.Status == "Pending")
                .OrderByDescending(t => t.Date)
                .ToListAsync();
        }

        public async Task AddAsync(Transaction transaction)
        {
            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Transaction transaction)
        {
            _context.Transactions.Update(transaction);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var transaction = await _context.Transactions.FindAsync(id);
            if (transaction != null)
            {
                _context.Transactions.Remove(transaction);
                await _context.SaveChangesAsync();
            }
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}