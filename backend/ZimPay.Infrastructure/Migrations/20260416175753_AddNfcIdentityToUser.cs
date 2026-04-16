using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ZimPay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddNfcIdentityToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NfcIdentityToken",
                table: "Users",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "MerchantName",
                table: "Transactions",
                type: "TEXT",
                maxLength: 100,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NfcIdentityToken",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "MerchantName",
                table: "Transactions");
        }
    }
}
