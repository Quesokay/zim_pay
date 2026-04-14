using Microsoft.EntityFrameworkCore;
using ZimPay.Domain;

namespace ZimPay.Infrastructure
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<PaymentMethod> PaymentMethods { get; set; }
        public DbSet<Transaction> Transactions { get; set; }
        public DbSet<Pass> Passes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(256);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(256);
                entity.Property(e => e.Phone).HasMaxLength(20);
                entity.HasIndex(e => e.Email).IsUnique();
            });

            // PaymentMethod configuration
            modelBuilder.Entity<PaymentMethod>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Type).IsRequired().HasMaxLength(50);
                entity.HasOne(pm => pm.User)
                    .WithMany(u => u.PaymentMethods)
                    .HasForeignKey(pm => pm.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Transaction configuration
            modelBuilder.Entity<Transaction>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Type).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Status).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Amount).HasPrecision(18, 2);
                
                entity.HasOne(t => t.User)
                    .WithMany(u => u.SentTransactions)
                    .HasForeignKey(t => t.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(t => t.Recipient)
                    .WithMany(u => u.ReceivedTransactions)
                    .HasForeignKey(t => t.RecipientUserId)
                    .IsRequired(false)
                    .OnDelete(DeleteBehavior.SetNull);

                entity.HasOne(t => t.PaymentMethod)
                    .WithMany(pm => pm.Transactions)
                    .HasForeignKey(t => t.PaymentMethodId)
                    .IsRequired(false)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Pass configuration
            modelBuilder.Entity<Pass>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Type).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.HasOne(p => p.User)
                    .WithMany(u => u.Passes)
                    .HasForeignKey(p => p.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Seed Data
            var now = new DateTime(2024, 10, 10);

            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    Name = "John Doe",
                    Email = "john.doe@example.com",
                    Phone = "+1234567890",
                    Balance = 1500.00m,
                    CreatedAt = now,
                    IsActive = true
                }
            );

            modelBuilder.Entity<PaymentMethod>().HasData(
                new PaymentMethod
                {
                    Id = 1,
                    UserId = 1,
                    Type = "CreditCard",
                    BankName = "Bank of Future",
                    CardNumber = "8892",
                    DigitalToken = "seeded_dummy_jwt_token_for_testing",
                    ExpiryDate = "12/28",
                    IsDefault = true,
                    IsActive = true,
                    AddedAt = now
                }
            );

            modelBuilder.Entity<Pass>().HasData(
                new Pass
                {
                    Id = 1,
                    UserId = 1,
                    Type = "TransitPass",
                    Title = "City Transit",
                    Details = "Metropolitan Area",
                    Balance = 42.50m,
                    Barcode = "TRANSIT-123456",
                    Color = "#1a73e8",
                    IsActive = true,
                    IssuedAt = now
                },
                new Pass
                {
                    Id = 2,
                    UserId = 1,
                    Type = "Loyalty",
                    Title = "Coffee Shop Rewards",
                    Details = "8 of 10 stars earned",
                    Barcode = "COFFEE-789012",
                    Color = "#ff9384",
                    IsActive = true,
                    IssuedAt = now
                },
                new Pass
                {
                    Id = 3,
                    UserId = 1,
                    Type = "Loyalty",
                    Title = "Public Library",
                    Details = "Membership Active",
                    Barcode = "LIB-345678",
                    Color = "#6c9fff",
                    IsActive = true,
                    IssuedAt = now
                },
                new Pass
                {
                    Id = 4,
                    UserId = 1,
                    Type = "Loyalty",
                    Title = "Everest Gym",
                    Details = "Next billing: Oct 12",
                    Barcode = "GYM-901234",
                    Color = "#86f898",
                    IsActive = true,
                    IssuedAt = now
                }
            );
        }
    }
}