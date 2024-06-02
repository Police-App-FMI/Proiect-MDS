using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class BazaDeDateController : ControllerBase
    {
        private readonly BackendContext _backendcontext;

        public BazaDeDateController(BackendContext backendcontext)
        {
            _backendcontext = backendcontext;
        }

        [HttpPost("Individ")]
        public async Task<IActionResult> AddIndivid([FromBody] IndividModel person)
        {
            if (person != null)
            {
                var individ = new Individ
                {
                    Id = Guid.NewGuid(),
                    DateCreated = DateTime.Now,
                    CNP = person.CNP,
                    Nume = person.Nume,
                    Permis_Validare = person.Permis_Validare,
                    Data_Nastere = person.Data_Nastere,
                    Adresa_Domiciliu = person.Adresa_Domiciliu
                };

                if (person.Nr_Inmatriculare != null && person.Data_Achizitie != null && person.Kilometraj != null)
                {
                    var autovehicul = new Autovehicul
                    {
                        Id = Guid.NewGuid(),
                        DateCreated = DateTime.Now,
                        Nr_Inmatriculare = person.Nr_Inmatriculare,
                        Model_3D = person.Model_3D,
                        Data_Achizitie = (DateTime)person.Data_Achizitie,
                        Kilometraj = (double)person.Kilometraj,
                        Propietar = individ
                    };
                    individ.Masinile = new List<Autovehicul> { autovehicul };
                    
                    await _backendcontext.AddAsync(autovehicul);
                    
                }

                await _backendcontext.AddAsync(individ);
                await _backendcontext.SaveChangesAsync();

                return Ok();
            }
            else return BadRequest(new { message = "Datele nu sunt valide!" });
        }

        [HttpPost("Autovehicul")]
        public async Task<IActionResult> AddVehicul([FromBody] AutovehiculModel vehicul)
        {
            if (vehicul != null)
            {
                var propietar = await _backendcontext.Persoana
                    .Where(i => i.CNP == vehicul.CNP)
                    .FirstOrDefaultAsync();

                if (propietar != null)
                {
                    var autovehicul = new Autovehicul
                    {
                        Id = Guid.NewGuid(),
                        DateCreated = DateTime.Now,
                        Nr_Inmatriculare = vehicul.Nr_Inmatriculare,
                        Model_3D = vehicul.Model_3D,
                        Data_Achizitie = vehicul.Data_Achizitie,
                        Kilometraj = vehicul.Kilometraj,
                        Propietar = propietar
                    };
                    if (propietar.Masinile == null)
                        propietar.Masinile = new List<Autovehicul> { autovehicul };
                    else propietar.Masinile.Add(autovehicul);

                    _backendcontext.Persoana.Update(propietar);
                    await _backendcontext.AddAsync(autovehicul);
                    await _backendcontext.SaveChangesAsync();

                    return Ok();
                }
                else return BadRequest(new { message = "Proprietarul nu există!" });
            }
            else return BadRequest(new { message = "Datele nu sunt valide!" });
        }
    }
}
