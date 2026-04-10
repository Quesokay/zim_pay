using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using System.Threading.Tasks;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TransactionController : ControllerBase
    {
        private readonly IMediator _mediator;

        public TransactionController(IMediator mediator)
        {
            _mediator = mediator;
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
    }
}
