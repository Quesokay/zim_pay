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
                return Ok(ApiResponse<int>.SuccessResponse(paymentMethodId, "Payment method added successfully"));
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(ApiResponse<string>.ErrorResponse(ex.Message));
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePaymentMethod(int id, [FromQuery] int userId)
        {
            var command = new DeletePaymentMethodCommand(id, userId);
            var result = await _mediator.Send(command);

            if (!result)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Payment method not found or does not belong to user"));
            }

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Payment method deleted successfully"));
        }
    }
}
