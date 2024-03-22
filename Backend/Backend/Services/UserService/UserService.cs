using AutoMapper;
using Backend.Models;
using Backend.Repositories.UserRepository;

namespace Backend.Services.UserService
{
    public class DatabaseService: IUserService
    {
        public IUserRepository _userRepository;
        public IMapper _mapper;

        public DatabaseService(IUserRepository userRepository, IMapper mapper)
        {
            _userRepository = userRepository;
            _mapper = mapper;
        }


        public async Task<List<User>> GetAllUsers()
        {
            var userList = await _userRepository.GetAllAsync();
            return _mapper.Map<List<User>>(userList);
        }

        public async Task<User> GetById(Guid id)
        {
            var user = await _userRepository.GetByIdAsync(id.ToString());
            return _mapper.Map<User>(user);
        }

        public User GetUserByUsername(string username)
        {
            var user = _userRepository.FindByUsername(username);
            return _mapper.Map<User>(user);
        }

        public async Task<bool> CreateUserAsync(User users)
        {
            var user = _mapper.Map<User>(users);
            if (GetUserByUsername(user.username) == null && _userRepository.FindByEmail(user.email) == null)
            {
                await _userRepository.AddAsync(user);
                return true; // Returnează true dacă adăugarea a fost un succes
            }
            else
            {
                return false; // Returnează false dacă a apărut o excepție
            }
        }

        public async Task<bool> DeleteUser(string username)
        {
            var user = _userRepository.FindByUsername(username);
            if (user != null)
            {
                await _userRepository.DeleteAsync(user);
                return true; // Returnează true dacă ștergerea a fost un succes
            }
            return false; // Returnează false dacă utilizatorul nu a fost găsit
        }
    }
}