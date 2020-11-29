using ChoreStorefront.Model.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace ChoreStorefront.Model
{
    public interface IDbContext : IDisposable
    {
        DbSet<TEntity> Set<TEntity>() where TEntity : class;
        Task<int> SaveChangesAsync(CancellationToken cancellationToken);

        public DbSet<User> Users { get; }
    }
}
