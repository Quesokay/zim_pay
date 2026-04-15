using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ZimPay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddTapLimitToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "TapLimit",
                table: "Users",
                type: "TEXT",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1,
                column: "TapLimit",
                value: 50.00m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TapLimit",
                table: "Users");
        }
    }
}
