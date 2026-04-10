using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.DTOs;
using System.Threading.Tasks;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PassController : ControllerBase
    {
        private readonly IMediator _mediator;

        public PassController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost]
        public async Task<IActionResult> AddPass([FromBody] AddPassCommand command)
        {
            try
            {
                var passId = await _mediator.Send(command);
                return CreatedAtAction(nameof(AddPass), new { id = passId }, ApiResponse<int>.SuccessResponse(passId, "Pass added successfully"));
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(ApiResponse<string>.ErrorResponse(ex.Message));
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePass(int id, [FromQuery] int userId)
        {
            var command = new DeletePassCommand(id, userId);
            var result = await _mediator.Send(command);

            if (!result)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Pass not found or does not belong to user"));
            }

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Pass deleted successfully"));
        }
    }
}
