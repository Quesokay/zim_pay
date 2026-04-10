using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Infrastructure.Repositories
{
    public class PassRepository : IPassRepository
    {
        private readonly AppDbContext _context;

        public PassRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Pass>> GetByUserIdAsync(int userId)
        {
            return await _context.Passes
                .Where(p => p.UserId == userId)
                .OrderByDescending(p => p.IssuedAt)
                .ToListAsync();
        }

        public async Task<IEnumerable<Pass>> GetActiveByUserIdAsync(int userId)
        {
            return await _context.Passes
                .Where(p => p.UserId == userId && p.IsActive && (p.ExpiresAt == null || p.ExpiresAt > System.DateTime.UtcNow))
                .OrderByDescending(p => p.IssuedAt)
                .ToListAsync();
        }

        public async Task<Pass> GetByIdAsync(int id)
        {
            return await _context.Passes.FirstOrDefaultAsync(p => p.Id == id);
        }

        public async Task<Pass> GetByPassNumberAsync(string passNumber)
        {
            return await _context.Passes.FirstOrDefaultAsync(p => p.PassNumber == passNumber);
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.Passes.AnyAsync(p => p.Id == id);
        }

        public async Task AddAsync(Pass pass)
        {
            _context.Passes.Add(pass);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Pass pass)
        {
            _context.Passes.Update(pass);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var pass = await _context.Passes.FindAsync(id);
            if (pass != null)
            {
                _context.Passes.Remove(pass);
                await _context.SaveChangesAsync();
            }
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}