using Backend.Models;

namespace Backend.Services.UserService
{
    public interface IUserService
    {
        Task<List<User>> GetAllUsers();

        Task<User> GetById(Guid id);

        User GetUserByUsername(string username);

        Task<bool> CreateUserAsync(User users);
        Task<bool> DeleteUser(string username);
    }
}
