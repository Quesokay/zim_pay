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
                return CreatedAtAction(nameof(AddPass), new { id = passId }, passId);
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
