using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands.Transaction;
using ZimPay.Application.DTOs;
using ZimPay.Application.Queries;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using ZimPay.Application.Interfaces;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TransactionController : ControllerBase
    {
        private readonly IMediator _mediator;
        private readonly ILogger<TransactionController> _logger;
        private readonly ZimPay.Infrastructure.AppDbContext _context;
        private readonly IEcoCashService _ecoCashService;

        public TransactionController(
            IMediator mediator,
            ILogger<TransactionController> logger,
            ZimPay.Infrastructure.AppDbContext context,
            IEcoCashService ecoCashService)
        {
            _mediator = mediator;
            _logger = logger;
            _context = context;
            _ecoCashService = ecoCashService;
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
                var result = await _mediator.Send(command);
                return Ok(ApiResponse<object>.SuccessResponse(result, "Transaction Processed"));
            }
            catch (System.InvalidOperationException ex)
            {
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

        [HttpGet("ecocash-status/{endUserId}/{clientCorrelator}")]
        public async Task<IActionResult> GetEcoCashStatus(string endUserId, string clientCorrelator)
        {
            try
            {
                var status = await _ecoCashService.GetTransactionStatusAsync(endUserId, clientCorrelator);
                return Ok(ApiResponse<string>.SuccessResponse(status, "Status retrieved from EcoCash EIP"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking EcoCash status");
                return BadRequest(ApiResponse<string>.ErrorResponse(ex.Message));
            }
        }

        [HttpPost("ecocash-webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> EcoCashWebhook([FromBody] JsonElement payload)
        {
            try
            {
                _logger.LogInformation("📥 RAW ECOCASH WEBHOOK PAYLOAD: {Payload}", payload.GetRawText());

                string refCode = "";
                string clientCorr = "";
                string status = "UNKNOWN";

                if (payload.TryGetProperty("referenceCode", out JsonElement refElement))
                    refCode = refElement.GetString();

                if (payload.TryGetProperty("clientCorrelator", out JsonElement corrElement))
                    clientCorr = corrElement.GetString();
                
                if (payload.TryGetProperty("transactionStatus", out JsonElement statusElement))
                    status = statusElement.GetString();

                if (string.IsNullOrEmpty(refCode) && string.IsNullOrEmpty(clientCorr))
                {
                    return BadRequest("Missing identification (referenceCode or clientCorrelator)");
                }

                var command = new ProcessEcoCashCallbackCommand
                {
                    ReferenceCode = refCode,
                    ClientCorrelator = clientCorr,
                    TransactionStatus = status
                };

                await _mediator.Send(command);

                return Ok(new { message = "Callback processed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Webhook Error");
                return StatusCode(500, "Internal Server Error");
            }
        }
    }
}
