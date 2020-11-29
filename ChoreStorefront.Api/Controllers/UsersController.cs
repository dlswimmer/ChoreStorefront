using ChoreStorefront.Core;
using ChoreStorefront.Model;
using ChoreStorefront.Model.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;

namespace ChoreStorefront.Api
{
    [TsClassController]
    [Route("api/[controller]")]
    public class UsersController : ApiController
    {
        private readonly IDbContext _dbContext;

        public UsersController(IDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet]
        public async Task<List<User>> GetUsers()
        {
            var users = await _dbContext.Users.ToListAsync();
            return users;
        }
    }
}
