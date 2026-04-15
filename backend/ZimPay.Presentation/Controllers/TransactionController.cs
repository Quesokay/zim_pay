using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands.Transaction;
using ZimPay.Application.DTOs;
using ZimPay.Application.Queries;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TransactionController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly ILogger<TransactionController> _logger;
        private readonly ZimPay.Infrastructure.AppDbContext _context;

        public TransactionController(IMediator mediator, ILogger<TransactionController> logger, ZimPay.Infrastructure.AppDbContext context)
        {
            _mediator = mediator;
            _logger = logger;
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> CreateTransaction([FromBody] CreateTransactionCommand command)
        {
            try
            {
                var transactionId = await _mediator.Send(command);
                return CreatedAtAction(nameof(CreateTransaction), new { id = transactionId }, transactionId);
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("process")]
        public async Task<IActionResult> Process([FromBody] ProcessTransactionCommand command)
        {
            try 
            {
                var success = await _mediator.Send(command);
                return Ok(ApiResponse<bool>.SuccessResponse(true, "Payment Approved"));
            }
            catch (System.InvalidOperationException ex)
            {
                if (ex.Message.StartsWith("BIOMETRIC_REQUIRED:"))
                {
                    var parts = ex.Message.Split(':');
                    var transactionId = parts[1];
                    return Ok(ApiResponse<object>.SuccessResponse(new { biometricRequired = true, transactionId = int.Parse(transactionId) }, "Biometric verification required."));
                }

                _logger.LogWarning(ex, "Transaction processing failed: {Message}", ex.Message);
                return BadRequest(ApiResponse<string>.ErrorResponse(ex.Message));
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserTransactions(int userId)
        {
            // Assuming your query is called GetTransactionsByUserIdQuery
            var query = new GetTransactionsByUserIdQuery(userId);
            var transactions = await _mediator.Send(query);

            if (transactions == null || !transactions.Any())
            {
                // Returning empty array inside your custom ApiResponse wrapper
                return Ok(ApiResponse<IEnumerable<TransactionDto>>.SuccessResponse(new List<TransactionDto>(), "No transactions found."));
            }

            return Ok(ApiResponse<IEnumerable<TransactionDto>>.SuccessResponse(transactions, "Transactions retrieved successfully."));
        }

        [HttpPost("{id}/approve")]
        public async Task<IActionResult> ApproveTransaction(int id)
        {
            try
            {
                var command = new ApproveTransactionCommand(id);
                var result = await _mediator.Send(command);
                return Ok(new { message = "Payment Approved Successfully" });
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("user/{userId}/pending")]
        public async Task<IActionResult> GetPendingTransactions(int userId)
        {
            var query = new GetPendingTransactionsByUserIdQuery(userId);
            var transactions = await _mediator.Send(query);
            return Ok(ApiResponse<List<TransactionDto>>.SuccessResponse(transactions, "Pending transactions retrieved successfully."));
        }
    }
}
