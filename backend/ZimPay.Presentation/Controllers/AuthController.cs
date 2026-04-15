using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using ZimPay.Infrastructure;
using ZimPay.Domain;

namespace ZimPay.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrEmpty(request.Phone))
            {
                return BadRequest(new { message = "Phone number is required." });
            }

            // 1. Check if the user already exists in the database
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Phone == request.Phone);

            // 2. If they don't exist, perform Registration automatically!
            if (user == null)
            {
                user = new User
                {
                    Name = "New ZimPay User",
                    // Generate a placeholder email until they update their profile
                    Email = $"user_{Guid.NewGuid().ToString().Substring(0, 5)}@zimpay.com", 
                    Phone = request.Phone,
                    Balance = 150.00m, // Give them a $150 signup bonus for capstone testing!
                    TapLimit = 50.00m, // Default biometric limit
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }

            // 3. Return the user data to Flutter
            return Ok(new { 
                message = "Authentication successful", 
                user = user 
            });
        }
    }

    // A simple DTO to catch the incoming JSON request
    public class LoginRequest
    {
        public string Phone { get; set; }
    }
}