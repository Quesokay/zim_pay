using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ZimPay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddEcoCashIdentifiers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ClientCorrelator",
                table: "Transactions",
                type: "TEXT",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ReferenceCode",
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
                name: "ClientCorrelator",
                table: "Transactions");

            migrationBuilder.DropColumn(
                name: "ReferenceCode",
                table: "Transactions");
        }
    }
}
