using Backend.Data;
using Backend.Models;
using Backend.Helpers.Extensions;
using Backend.Repositories.GenericRepository;
using Microsoft.EntityFrameworkCore;

namespace Backend.Repositories.UserRepository
{
    public class UserRepository : GenericRepository<User>, IUserRepository
    {
        public UserRepository(BackendContext backendContext) : base(backendContext)
        {
        }

        public List<User> FindAllActive()
        {
            return _table.GetActiveUsers().ToList();
        }

        public User FindByUsername(string username)
        {
            return _table.FirstOrDefault(u => u.username.Equals(username));
        }

        public User FindByEmail(string email) 
        {
            return _table.FirstOrDefault(u => u.email.Equals(email));
        }

        public async Task UpdateAsync(User user)
        {
            _backendContext.Update(user);
            await _backendContext.SaveChangesAsync();
        }

        public async Task AddAsync(User user)
        {
            await _backendContext.AddAsync(user);
            await _backendContext.SaveChangesAsync();
        }

        public async Task DeleteAsync(User user)
        {
            _backendContext.Remove(user);
            await _backendContext.SaveChangesAsync();
        }

        public async Task<User> GetByIdAsync(string id)
        {
            Guid userIdGuid = Guid.Parse(id);
            return await _backendContext.Users.FirstOrDefaultAsync(u => u.Id == userIdGuid);
        }
    }
}
