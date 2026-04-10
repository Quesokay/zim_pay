using Microsoft.EntityFrameworkCore;
using ZimPay.Application.Commands;
using ZimPay.Infrastructure;
using ZimPay.Application.Interfaces;
using ZimPay.Infrastructure.Repositories;
using ZimPay.Presentation.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add health checks
builder.Services.AddHealthChecks();

// Add DbContext with SQLite
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=wallet.db";
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite(connectionString, b => b.MigrationsAssembly("ZimPay.Infrastructure")));

// Add MediatR - Register all handlers from Application assembly
builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(typeof(CreateUserCommand).Assembly);
});

// Add repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IPaymentMethodRepository, PaymentMethodRepository>();
builder.Services.AddScoped<ITransactionRepository, TransactionRepository>();
builder.Services.AddScoped<IPassRepository, PassRepository>();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Add exception handling middleware
app.UseMiddleware<ExceptionHandlingMiddleware>();

// Apply migrations automatically on startup
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    dbContext.Database.Migrate();
}

// app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

// Map health check endpoint
app.MapHealthChecks("/health");


app.Run();
