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


        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlite("Data Source=wallet.db;Cache=Shared");
        }

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
                entity.Property(e => e.MerchantName).HasMaxLength(100);
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
        }
    }
}