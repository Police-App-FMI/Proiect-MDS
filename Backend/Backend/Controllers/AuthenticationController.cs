using Backend.Models;
using Backend.Models.DTOs;
using Backend.Services.UserService;
using Backend.Services.Token_JWT;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Backend.Data;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Security.Cryptography;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthenticationController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly JwtTokenService _JwtToken;
        private readonly BackendContext _backendcontext;

        public AuthenticationController(IUserService userService, JwtTokenService JwtToken, BackendContext backendcontext)
        {
            _userService = userService;
            _JwtToken = JwtToken;
            _backendcontext = backendcontext;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetUsers()
        {
            var users = await _userService.GetAllUsers();

            var List = users.Select(user => new
            {
                Nume = user.nume,
                isOnline = user.IsOnline,
                LastActive = user.lastActive,
                Profile_Pic = user.profile_pic
            }).ToList();
            return Ok(List);
        }

        [HttpPut("checkToken")]
        [Authorize]
        public async Task<IActionResult> CheckToken()
        {
            // Dacă utilizatorul este logat, se va ajunge aici și se va returna HTTP 200 (OK) şi se actualizează activitatea
            
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);
            user.lastActive = DateTime.Now;
            _backendcontext.Users.Update(user);
            await _backendcontext.SaveChangesAsync();
            return Ok();
            
            // Altfel se va returna un HTTP 401 (Unauthorized) şi se va apela HttpPut Disconnect din Frontend
        }

        [HttpPut("disconnect")]
        public async Task<IActionResult> Disconnect([FromBody] ChatModel model)
        {
            var user = await _backendcontext.Users
                        .Where(p => p.nume == model.newMessage)
                        .FirstOrDefaultAsync();
            if (user != null)
            {
                user.lastActive = DateTime.Now;
                user.IsOnline = false;
                user.location = null;
                _backendcontext.Users.Update(user);
                await _backendcontext.SaveChangesAsync();
                return Ok();
            }
            else return BadRequest(new { message = "User-ul dat nu a fost găsit!" });
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] AuthenticationModel model)
        {
            var user = new User
            {
                Id = Guid.NewGuid(),
                username = model.input,
                nume = model.nume,
                profile_pic = model.profile_pic,
                email = model.mail,
                password = model.password,
                DateCreated = DateTime.Now
            };

            var result = await _userService.CreateUserAsync(user);

            if (result)
            {
                return Ok(new { message = "User registered successfully!" });
            }

            return BadRequest(new { message = "User registration failed." });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] AuthenticationModel model)
        {
            if(model.input.Contains('@'))
            {
                var user = await _backendcontext.Users
                            .Where(p => p.email == model.input)
                            .FirstOrDefaultAsync();
                if (user != null && VerifyPassword(model.password, user.password))
                {
                    // Sigleton pattern
                    if (user.IsOnline)
                    {
                        return Unauthorized(new { message = "User is already logged in on another divice!" });
                    }
                    // Generarea token-ului JWT
                    var token = _JwtToken.GenerateToken(user);

                    // Intoarcem datele relevante
                    var userDetails = new
                    {
                        Nume = user.nume,
                        ProfilePic = user.profile_pic,
                        Email = user.email,
                        Token = token
                    };
                    // Actualizăm starea user-ului
                    user.lastActive = DateTime.Now;
                    user.IsOnline = true;
                    _backendcontext.Users.Update(user);
                    await _backendcontext.SaveChangesAsync();

                    return Ok(userDetails);
                }

                return Unauthorized(new { message = "Email or password is incorrect" });
            }
            else
            {
                var user = _userService.GetUserByUsername(model.input);
                if (user != null && VerifyPassword(model.password, user.password))
                {
                    // Sigleton pattern
                    if (user.IsOnline)
                    {
                        return Unauthorized(new { message = "User is already logged in on another divice!" });
                    }
                    // Generarea token-ului JWT
                    var token = _JwtToken.GenerateToken(user);

                    // Intoarcem datele relevante
                    var userDetails = new
                    {
                        Nume = user.nume,
                        ProfilePic = user.profile_pic,
                        Email = user.email,
                        Token = token
                    };
                    // Actualizăm starea user-ului
                    user.lastActive = DateTime.Now;
                    user.IsOnline = true;
                    _backendcontext.Users.Update(user);
                    await _backendcontext.SaveChangesAsync();

                    return Ok(userDetails);
                }

                return Unauthorized(new { message = "Username or password is incorrect" });
            }
        }

        private bool VerifyPassword(string enteredPassword, string storedHash)
        {
            // Convertim hash-ul stocat într-un byte array
            byte[] hashBytes = Convert.FromBase64String(storedHash);

            // Extragem sarea din hash-ul stocat
            byte[] salt = new byte[16];
            Array.Copy(hashBytes, 0, salt, 0, 16);

            // Creăm un nou hash pentru parola introdusă folosind sarea stocată
            var pbkdf2 = new Rfc2898DeriveBytes(enteredPassword, salt, 10000);
            byte[] hash = pbkdf2.GetBytes(20);

            // Comparăm hash-urile
            for (int i = 0; i < 20; i++)
            {
                if (hashBytes[i + 16] != hash[i])
                {
                    return false;
                }
            }

            return true;
        }
    }
}
