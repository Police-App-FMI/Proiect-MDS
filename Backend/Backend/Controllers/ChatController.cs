using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Backend.Services.UserService;
using Backend.SignalR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly BackendContext _backendcontext;
        private readonly IHubContext<SRHub> _hubContext;

        public ChatController(IUserService userService, BackendContext backendcontext, IHubContext<SRHub> hubContext)
        {
            _userService = userService;
            _backendcontext = backendcontext;
            _hubContext = hubContext;
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

            foreach (var message in chat)
            {
                await _hubContext.Clients.All.SendAsync("ReceiveMessage", message.Nume, message.Profile_Pic, message.Mesaj, message.Date_Send);
            }

            return Ok(chat);
        }

        [HttpPost]
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
        public async Task<IActionResult> ChangeMessage([FromBody] ChatModel change)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            var chat = _backendcontext.Chats
                    .AsEnumerable() // Extrage datele în memorie
                    .Where(p => p.Nume == user.nume &&
                        ((p.DateCreated.Value - change.dateSend.Value).TotalMilliseconds <= 1 ||
                        (p.DateModified.Value - change.dateSend.Value).TotalMilliseconds <= 1))
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
        public async Task<IActionResult> DeleteMessage([FromBody] ChatModel delete)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            var chat = _backendcontext.Chats
                .AsEnumerable() // Extrage datele în memorie
                .Where(p => p.Nume == user.nume &&
                    ((p.DateCreated.Value - delete.dateSend.Value).TotalMilliseconds <= 1 ||
                    (p.DateModified.Value - delete.dateSend.Value).TotalMilliseconds <= 1))
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
