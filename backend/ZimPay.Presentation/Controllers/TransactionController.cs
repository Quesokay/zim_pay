using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using ZimPay.Application.Queries;
using System.Threading.Tasks;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TransactionController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly ILogger<TransactionController> _logger;

        public TransactionController(IMediator mediator, ILogger<TransactionController> logger)
        {
            _mediator = mediator;
            _logger = logger;
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
                return Ok(new { message = "Payment Approved" });
            }
            catch (System.InvalidOperationException ex)
            {
                // This will send the "Insufficient funds" string back to Flutter!
                return BadRequest(new { message = ex.Message });
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
    }
}
