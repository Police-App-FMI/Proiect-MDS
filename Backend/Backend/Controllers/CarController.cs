using Backend.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using System.Diagnostics;
using System.Net.Http.Headers;
using System.Text.Json;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class CarController : ControllerBase
    {
        // Luăm path-ul către interpretorul de python şi script-ul de executat
        private readonly HttpClient _httpClient;
        private readonly BackendContext _backendcontext;

        public CarController(IHttpClientFactory httpClientFactory, BackendContext backendcontext)
        {
            _httpClient = httpClientFactory.CreateClient();
            _backendcontext = backendcontext;
        }

        [HttpPost]
        public async Task<IActionResult> Car_Recognition(IFormFile image)
        {
            if (image == null)
            {
                return BadRequest(new { message = "No file uploaded" });
            }

            if (image.Length == 0)
            {
                return BadRequest(new { message = "No file uploaded" });
            }

            var extension = Path.GetExtension(image.FileName).ToLowerInvariant();
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };

            if (string.IsNullOrEmpty(extension) || !allowedExtensions.Contains(extension))
            {
                return BadRequest(new { message = "Fişierul primit este invalid sau corupt." });
            }

            string contentType;
            switch (extension)
            {
                case ".jpg":
                    contentType = "image/jpg";
                    break;
                case ".jpeg":
                    contentType = "image/jpeg";
                    break;
                case ".png":
                    contentType = "image/png";
                    break;
                default:
                    return BadRequest(new { message = "Unsupported file type." });
            }
            try
            {
                using (var stream = new MemoryStream())
                {
                    await image.CopyToAsync(stream);

                    stream.Seek(0, SeekOrigin.Begin);

                    var content = new ByteArrayContent(stream.ToArray());
                    content.Headers.ContentType = new MediaTypeHeaderValue(contentType);

                    var response = await _httpClient.PostAsync("https://app-policesoft.azurewebsites.net/api/classifyplate", content);

                    if (response.IsSuccessStatusCode)
                    {
                        var predictionResponse = await response.Content.ReadAsStringAsync();
                        var predictionJson = JsonConvert.DeserializeObject<dynamic>(predictionResponse);

                        using (JsonDocument doc = JsonDocument.Parse(predictionResponse))
                            {
                                var root = doc.RootElement;
                                var prediction = root.GetProperty("license_plate_text").GetString();

                                var masina = await _backendcontext.Masina.Include(m => m.Propietar).FirstOrDefaultAsync(i => i.Nr_Inmatriculare == prediction);

                                masina.Propietar.Masinile = null;
                                
                                if (masina == null)
                                {
                                    return NotFound("Masina " + prediction + " nu exista in baza de date");
                                }
                                else
                                {
                                    return Ok(masina);
                                }
                            }
                        }
                    else
                    {
                        var errorContent = await response.Content.ReadAsStringAsync();
                        Debug.WriteLine($"Error response from Python API: {errorContent}");
                        return StatusCode((int)response.StatusCode, $"Imaginea nu a ajuns la API: {errorContent}");
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Exception: {ex.Message}");
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}
