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
            if (string.IsNullOrEmpty(request.Pin))
            {
                return BadRequest(new { message = "PIN is required." });
            }

            // In this specific implementation, we are logging in using the PIN only.
            // For a production app, we would typically check against the current user's PIN.
            // Here we'll find the first user that matches the PIN for simulation.
            var user = await _context.Users
                .Include(u => u.PaymentMethods)
                .FirstOrDefaultAsync(u => u.Pin == request.Pin);

            // 2. If no matching PIN found
            if (user == null)
            {
                return Unauthorized(new { message = "Invalid PIN." });
            }

            // 3. Return the user data to Flutter
            return Ok(new { 
                message = "Login successful",
                user = user 
            });
        }
    }

    // A simple DTO to catch the incoming JSON request
    public class LoginRequest
    {
        public string Pin { get; set; }
    }
}