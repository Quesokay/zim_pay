using Microsoft.AspNetCore.Mvc;
using MediatR;
using ZimPay.Application.Commands;
using ZimPay.Application.Queries;
using ZimPay.Application.DTOs;
using System.Threading.Tasks;

namespace ZimPay.Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IMediator _mediator;

        public UserController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserCommand command)
        {
            try
            {
                var response = await _mediator.Send(command);
                return CreatedAtAction(nameof(GetUserById), new { id = response.Data.Id }, response);
            }
            catch (System.InvalidOperationException ex)
            {
                return BadRequest(new ApiResponse<UserDto>
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(int id)
        {
            var query = new GetUserByIdQuery(id);
            var user = await _mediator.Send(query);

            if (user == null)
                return NotFound(new { message = $"User with ID {id} not found." });

            return Ok(new ApiResponse<UserDetailDto>
            {
                Success = true,
                Message = "User retrieved successfully",
                Data = user
            });
        }

        [HttpGet("{id}/transactions")]
        public async Task<IActionResult> GetUserTransactions(int id, [FromQuery] int? pageNumber = null, [FromQuery] int? pageSize = null)
        {
            var query = new GetTransactionsByUserIdQuery(id, pageNumber, pageSize);
            var transactions = await _mediator.Send(query);

            return Ok(new ApiResponse<System.Collections.Generic.List<TransactionDto>>
            {
                Success = true,
                Message = "Transactions retrieved successfully",
                Data = transactions
            });
        }

        [HttpGet("{id}/payment-methods")]
        public async Task<IActionResult> GetUserPaymentMethods(int id, [FromQuery] bool onlyActive = false)
        {
            var query = new GetPaymentMethodsByUserIdQuery(id, onlyActive);
            var paymentMethods = await _mediator.Send(query);

            return Ok(new ApiResponse<System.Collections.Generic.List<PaymentMethodDto>>
            {
                Success = true,
                Message = "Payment methods retrieved successfully",
                Data = paymentMethods
            });
        }

        [HttpGet("{id}/passes")]
        public async Task<IActionResult> GetUserPasses(int id, [FromQuery] bool onlyActive = false)
        {
            var query = new GetPassesByUserIdQuery(id, onlyActive);
            var passes = await _mediator.Send(query);

            return Ok(new ApiResponse<System.Collections.Generic.List<PassDto>>
            {
                Success = true,
                Message = "Passes retrieved successfully",
                Data = passes
            });
        }

        [HttpPatch("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserDto dto)
        {
            var command = new UpdateUserCommand(id, dto);
            var updatedUser = await _mediator.Send(command);

            if (updatedUser == null)
                return NotFound(new { message = $"User with ID {id} not found." });

            return Ok(new ApiResponse<UserDetailDto>
            {
                Success = true,
                Message = "User updated successfully",
                Data = updatedUser
            });
        }
    }
}