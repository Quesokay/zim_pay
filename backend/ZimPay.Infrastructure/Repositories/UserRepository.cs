using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly AppDbContext _context;

        public UserRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<User> GetByIdAsync(int id)
        {
            return await _context.Users
                .Include(u => u.PaymentMethods)
                .Include(u => u.SentTransactions)
                .Include(u => u.ReceivedTransactions)
                .Include(u => u.Passes)
                .FirstOrDefaultAsync(u => u.Id == id);
        }

        public async Task<User> GetByEmailAsync(string email)
        {
            return await _context.Users
                .Include(u => u.PaymentMethods)
                .Include(u => u.Passes)
                .FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            return await _context.Users.ToListAsync();
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.Users.AnyAsync(u => u.Id == id);
        }

        public async Task<bool> EmailExistsAsync(string email)
        {
            return await _context.Users.AnyAsync(u => u.Email == email);
        }

        public async Task AddAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(User user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user != null)
            {
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();
            }
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }

        public async Task<User> GetByNfcTokenAsync(string nfcToken)
        {
            // Make sure to Include PaymentMethods so we can easily find the active card later!
            return await _context.Users
                .Include(u => u.PaymentMethods) 
                .FirstOrDefaultAsync(u => u.NfcIdentityToken == nfcToken && u.IsActive);
        }
    }
}