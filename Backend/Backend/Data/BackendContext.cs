using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Data
{
    public class BackendContext: DbContext
    {
        // One to Many
        public DbSet<Individ> Persoana { get; set; }
        public DbSet<Autovehicul> Masina { get; set; }

        public DbSet<User> Users { get; set; }
        public DbSet<Chat> Chats { get; set; }
        public DbSet<Reinforcement> Reinforcements { get; set; }
        public DbSet<MissingPerson> MissingPersons { get; set; }
        public BackendContext(DbContextOptions<BackendContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // One to Many
            modelBuilder.Entity<Individ>()
                    .HasMany(m1 => m1.Masinile)    
                    .WithOne(m2 => m2.Propietar);

            base.OnModelCreating(modelBuilder);
        }
    }
}
