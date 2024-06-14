using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Backend.Services.UserService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.IdentityModel.Tokens.Jwt;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class OnDutyController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly BackendContext _backendcontext;

        public OnDutyController(IUserService userService, BackendContext backendcontext)
        {
            _userService = userService;
            _backendcontext = backendcontext;
        }

        [HttpGet("Location")]
        public async Task<IActionResult> GetLocation()
        {
            var map = await _backendcontext.Users
                    .Select(x => new
                    {
                        Nume = x.nume,
                        Profile_Pic = x.profile_pic,
                        Location = x.location
                    })
                    .ToListAsync();

            return Ok(map);
        }

        [HttpPut("Location")]
        public async Task<IActionResult> PostLocation([FromBody] ChatModel loc)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            if (user != null) 
            { 
                user.location = loc.newMessage;
                _backendcontext.Users.Update(user);
                await _backendcontext.SaveChangesAsync();
                return Ok();
            }
            else return BadRequest(new { message = "User-ul dat nu a fost găsit!" });
        }

        [HttpGet("CallReinforcements")]
        public async Task<IActionResult> SendReinforcements()
        {
            var emergencies = await _backendcontext.Reinforcements
                            .Select(x => new 
                            {
                                Id = x.Id.ToString(),
                                Nume = x.Nume,
                                Mesaj = x.Message,
                                Location = x.Location,
                                Time = x.DateCreated
                            })
                            .ToListAsync();

            return Ok(emergencies);
        }

        [HttpPost("CallReinforcements")]
        public async Task<IActionResult> CallReinforcements([FromBody] ReinforcementModel emergency)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            if (emergency != null)
            {
                var reinforcement = new Reinforcement
                {
                    Id = Guid.NewGuid(),
                    Nume = user.nume,
                    Message = emergency.Message,
                    Location = emergency.Location,
                    DateCreated = DateTime.Now
                };

                await _backendcontext.AddAsync(reinforcement);
                await _backendcontext.SaveChangesAsync();

                return Ok();
            }
            else return BadRequest(new { message = "Urgența nu a putut fi creată!" });
        }

        [HttpDelete("CallReinforcements")]
        public async Task<IActionResult> EndReinforcements([FromBody] ChatModel Id)
        {
            // Obținem ID-ul utilizatorului autentificat din claim-urile token-ului JWT
            var jti = User.Claims.FirstOrDefault(claim => claim.Type == JwtRegisteredClaimNames.Jti).Value;
            Guid id = Guid.Parse(jti);
            var user = await _userService.GetById(id);

            var delete = await _backendcontext.Reinforcements
                        .Where(p => p.Nume == user.nume && p.Id.ToString() == Id.newMessage)
                        .FirstOrDefaultAsync();

            if(delete != null)
            {
                _backendcontext.Reinforcements.Remove(delete);
                await _backendcontext.SaveChangesAsync();

                return Ok(new { message = "Urgența s-a încheiat!" });
            }
            else return NotFound(new { message = "Urgența nu a fost găsită." });
        }

        [HttpGet("MissingPerson")]
        public async Task<IActionResult> GetPerson()
        {
            var persons = await _backendcontext.MissingPersons
                        .Select(x => new 
                        {
                            Id = x.Id.ToString(),
                            Nume = x.Name,
                            Portret = x.ProfilePic,
                            Descriere = x.Description,
                            Telefon = x.PhoneNumber,
                            UlimaLocatie = x.LastSeenLocation,
                            UltimaData = x.DateCreated
                        })
                        .ToListAsync();

            return Ok(persons);
        }

        [HttpPost("MissingPerson")]
        [AllowAnonymous]
        public async Task<IActionResult> AddPerson([FromBody] MissingPersonModel person)
        {
            var missing = new MissingPerson
            {
                Id = Guid.NewGuid(),
                Name = person.Name,
                ProfilePic = person.ProfilePic,
                Description = person.Description,
                PhoneNumber = person.PhoneNumber,
                LastSeenLocation = person.LastSeenLocation,
                DateCreated = DateTime.Now
            };

            await _backendcontext.AddAsync(missing);
            await _backendcontext.SaveChangesAsync();

            return Ok();
        }

        [HttpPut("MissingPerson")]
        public async Task<IActionResult> UpdatePerson([FromBody] AuthenticationModel newLocation)
        {
            var person = await _backendcontext.MissingPersons
                       .Where(p => p.Id.ToString() == newLocation.input)
                       .FirstOrDefaultAsync();

            if (person != null)
            {
                person.LastSeenLocation = newLocation.password;
                person.DateCreated = DateTime.Now;
                _backendcontext.MissingPersons.Update(person);
                await _backendcontext.SaveChangesAsync();
                return Ok();
            }
            else return NotFound(new { messege = "Persoana selectată nu există în baza de date!" });
        }

        [HttpDelete("MissingPerson")]
        public async Task<IActionResult> FoundPerson([FromBody] ChatModel Id)
        {
            var person = await _backendcontext.MissingPersons
                       .Where(p => p.Id.ToString() == Id.newMessage)
                       .FirstOrDefaultAsync();

            if (person != null)
            {
                _backendcontext.MissingPersons.Remove(person);
                await _backendcontext.SaveChangesAsync();

                return Ok(new { message = "Persoana pierdută a fost găsită!" });
            }
            else return NotFound(new { messege = "Persoana selectată nu există în baza de date!" });
        }
    }
}
