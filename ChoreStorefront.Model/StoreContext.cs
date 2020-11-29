using ChoreStorefront.Model.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System;

namespace ChoreStorefront.Model
{
    public class StoreContext : DbContext, IDbContext
    {
        public StoreContext() : base()
        {

        }
        public DbSet<User> Users { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            base.OnConfiguring(optionsBuilder);
            optionsBuilder.UseSqlite("Data Source=..\\ChoreStorefront\\Data\\store.sqlite;");
        }
    }
}
