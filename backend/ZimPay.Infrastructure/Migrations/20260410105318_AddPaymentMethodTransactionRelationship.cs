using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ZimPay.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentMethodTransactionRelationship : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Transactions_PaymentMethodId",
                table: "Transactions",
                column: "PaymentMethodId");

            migrationBuilder.AddForeignKey(
                name: "FK_Transactions_PaymentMethods_PaymentMethodId",
                table: "Transactions",
                column: "PaymentMethodId",
                principalTable: "PaymentMethods",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Transactions_PaymentMethods_PaymentMethodId",
                table: "Transactions");

            migrationBuilder.DropIndex(
                name: "IX_Transactions_PaymentMethodId",
                table: "Transactions");
        }
    }
}
