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

            // 1. Check if the user exists in the database
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Phone == request.Phone);

            // 2. If they don't exist, return NotFound
            if (user == null)
            {
                return NotFound(new { message = "No account found with this phone number." });
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
        public string Phone { get; set; }
    }
}