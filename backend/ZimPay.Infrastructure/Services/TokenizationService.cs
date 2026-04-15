using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using ZimPay.Application.Interfaces;
using ZimPay.Domain;

namespace ZimPay.Infrastructure.Services
{
    public class TokenizationService : ITokenizationService
    {
        private readonly IConfiguration _configuration;

        public TokenizationService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateDigitalToken(PaymentMethod paymentMethod, string rawCardNumber)
        {
            // In a real scenario, this key should be highly secure and stored in an environment variable or Key Vault.
            // For development, we will pull it from appsettings.json
            var secretKey = _configuration["JwtSettings:SecretKey"] 
                ?? "YourSuperSecretAndLongDevelopmentKeyForZimPayCapstone!";
                
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, paymentMethod.UserId.ToString()),
                new Claim("PaymentMethodId", paymentMethod.Id.ToString()),
                // We store the RAW card number inside the encrypted token.
                // The database only stores the masked version.
                new Claim("SecureData", rawCardNumber), 
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var token = new JwtSecurityToken(
                issuer: "ZimPayAuthServer",
                audience: "ZimPayMobileApp",
                claims: claims,
                // Tokens in digital wallets often have long expirations, but require biometric auth to use.
                expires: DateTime.UtcNow.AddYears(3), 
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public bool ValidateDigitalToken(string token)
        {
            // We will implement this in Phase 2 for verifying transactions
            throw new NotImplementedException();
        }
    }
}