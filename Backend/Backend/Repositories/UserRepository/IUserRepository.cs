using Backend.Models;
using Backend.Repositories.GenericRepository;

namespace Backend.Repositories.UserRepository
{
    public interface IUserRepository: IGenericRepository<User>
    {
        User FindByUsername(string username);

        public User FindByEmail(string email);

        List<User> FindAllActive();
        Task UpdateAsync(User user);

        Task AddAsync(User user);
        Task DeleteAsync(User user);
        Task<User> GetByIdAsync(string id);
    }
}
