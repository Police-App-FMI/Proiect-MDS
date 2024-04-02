using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Backend.Services.UserService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly BackendContext _backendcontext;

        public ChatController(IUserService userService, BackendContext backendcontext)
        {
            _userService = userService;
            _backendcontext = backendcontext;
        }

        [HttpGet]
        public async Task<IActionResult> GetMessages()
        {
            var chat = await _backendcontext.Chats
                    .Select(x => new
                    {
                        Nume = x.Nume,
                        Profile_Pic = x.Profile_Pic,
                        Mesaj = x.Message,
                        Date_Send = x.DateModified ?? x.DateCreated
                    }).ToListAsync();

            return Ok(chat);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> SendMessage([FromBody] ChatModel message)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            var chat = new Chat
            {
                Id = Guid.NewGuid(),
                Nume = user.nume,
                Profile_Pic = user.profile_pic,
                Message = message.newMessage,
                DateCreated = DateTime.Now
            };
            await _backendcontext.AddAsync(chat);
            await _backendcontext.SaveChangesAsync();

            return Ok();
        }

        [HttpPut]
        [Authorize]
        public async Task<IActionResult> ChangeMessage([FromBody] ChatModel change)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            var chat = _backendcontext.Chats
                        .Where(p => p.Nume == user.nume && (p.DateCreated == change.dateSend || p.DateModified == change.dateSend))
                        .FirstOrDefault();

            if (chat != null)
            {
                chat.Message = change.newMessage;
                chat.DateModified = DateTime.Now;
                _backendcontext.Chats.Update(chat);
                await _backendcontext.SaveChangesAsync();
                return Ok();
            }
            else return NotFound(new { message = "Mesajul nu a fost găsit." });
        }

        [HttpDelete]
        [Authorize]
        public async Task<IActionResult> DeleteMessage([FromBody] ChatModel delete)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            var chat = _backendcontext.Chats
                    .Where(p => p.Nume == user.nume && (p.DateCreated == delete.dateSend || p.DateModified == delete.dateSend))
                    .FirstOrDefault();

            if (chat != null)
            {
                _backendcontext.Chats.Remove(chat);
                await _backendcontext.SaveChangesAsync();

                return Ok(new { message = "Mesajul s-a şters." });
            }
            else return NotFound(new { message = "Mesajul nu a fost găsit." });
        }
    }
}
