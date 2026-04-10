using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Infrastructure.Repositories
{
    public class PaymentMethodRepository : IPaymentMethodRepository
    {
        private readonly AppDbContext _context;

        public PaymentMethodRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<PaymentMethod>> GetByUserIdAsync(int userId)
        {
            return await _context.PaymentMethods
                .Where(pm => pm.UserId == userId)
                .OrderByDescending(pm => pm.IsDefault)
                .ToListAsync();
        }

        public async Task<IEnumerable<PaymentMethod>> GetActiveByUserIdAsync(int userId)
        {
            return await _context.PaymentMethods
                .Where(pm => pm.UserId == userId && pm.IsActive)
                .OrderByDescending(pm => pm.IsDefault)
                .ToListAsync();
        }

        public async Task<PaymentMethod> GetByIdAsync(int id)
        {
            return await _context.PaymentMethods.FirstOrDefaultAsync(pm => pm.Id == id);
        }

        public async Task<PaymentMethod> GetDefaultByUserIdAsync(int userId)
        {
            return await _context.PaymentMethods
                .FirstOrDefaultAsync(pm => pm.UserId == userId && pm.IsDefault && pm.IsActive);
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.PaymentMethods.AnyAsync(pm => pm.Id == id);
        }

        public async Task AddAsync(PaymentMethod paymentMethod)
        {
            _context.PaymentMethods.Add(paymentMethod);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(PaymentMethod paymentMethod)
        {
            _context.PaymentMethods.Update(paymentMethod);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var pm = await _context.PaymentMethods.FindAsync(id);
            if (pm != null)
            {
                _context.PaymentMethods.Remove(pm);
                await _context.SaveChangesAsync();
            }
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}