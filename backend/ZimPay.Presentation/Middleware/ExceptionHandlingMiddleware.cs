using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using ZimPay.Application.DTOs;

namespace ZimPay.Presentation.Middleware
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unhandled exception has occurred.");
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";

            var response = new ApiResponse<object>();

            switch (exception)
            {
                case InvalidOperationException invalidOpEx:
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    response.Success = false;
                    response.Message = invalidOpEx.Message;
                    response.Errors.Add(invalidOpEx.Message);
                    break;

                case ArgumentException argEx:
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    response.Success = false;
                    response.Message = "Invalid argument provided.";
                    response.Errors.Add(argEx.Message);
                    break;

                case KeyNotFoundException keyNotEx:
                    context.Response.StatusCode = (int)HttpStatusCode.NotFound;
                    response.Success = false;
                    response.Message = "Resource not found.";
                    response.Errors.Add(keyNotEx.Message);
                    break;

                default:
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    response.Success = false;
                    response.Message = "An internal server error occurred.";
                    response.Errors.Add(exception.Message);
                    break;
            }

            return context.Response.WriteAsJsonAsync(response);
        }
    }
}
