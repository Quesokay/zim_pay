using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace ZimPay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedInitialData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Balance", "CreatedAt", "Email", "IsActive", "Name", "Phone", "UpdatedAt" },
                values: new object[] { 1, 1500.00m, new DateTime(2024, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "john.doe@example.com", true, "John Doe", "+1234567890", null });

            migrationBuilder.InsertData(
                table: "Passes",
                columns: new[] { "Id", "Balance", "Barcode", "Color", "Details", "ExpiresAt", "ImageUrl", "IsActive", "IssuedAt", "IssuerId", "IssuerName", "PassNumber", "Title", "Type", "UserId" },
                values: new object[,]
                {
                    { 1, 42.50m, "TRANSIT-123456", "#1a73e8", "Metropolitan Area", null, "", true, new DateTime(2024, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "", "", "", "City Transit", "TransitPass", 1 },
                    { 2, null, "COFFEE-789012", "#ff9384", "8 of 10 stars earned", null, "", true, new DateTime(2024, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "", "", "", "Coffee Shop Rewards", "Loyalty", 1 },
                    { 3, null, "LIB-345678", "#6c9fff", "Membership Active", null, "", true, new DateTime(2024, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "", "", "", "Public Library", "Loyalty", 1 },
                    { 4, null, "GYM-901234", "#86f898", "Next billing: Oct 12", null, "", true, new DateTime(2024, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "", "", "", "Everest Gym", "Loyalty", 1 }
                });

            migrationBuilder.InsertData(
                table: "PaymentMethods",
                columns: new[] { "Id", "AccountNumber", "AddedAt", "BankName", "CardNumber", "ExpiryDate", "HolderName", "IsActive", "IsDefault", "Type", "UpdatedAt", "UserId" },
                values: new object[] { 1, "", new DateTime(2024, 10, 10, 0, 0, 0, 0, DateTimeKind.Unspecified), "Bank of Future", "8892", "12/28", "", true, true, "CreditCard", null, 1 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Passes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Passes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Passes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Passes",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "PaymentMethods",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1);
        }
    }
}
