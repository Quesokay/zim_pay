using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using System.Threading.Tasks;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentMethodController : ControllerBase
    {
        private readonly IMediator _mediator;

        public PaymentMethodController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost]
        public async Task<IActionResult> AddPaymentMethod([FromBody] AddPaymentMethodCommand command)
        {
            try
            {
                var paymentMethodId = await _mediator.Send(command);
                return CreatedAtAction(nameof(AddPaymentMethod), new { id = paymentMethodId }, paymentMethodId);
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
