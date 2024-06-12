using Backend.Data;
using Backend.Models;
using Backend.Models.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System.Diagnostics;
using System.Net.Http.Headers;
using System.Text.Json;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FaceController : ControllerBase
    {
        private readonly HttpClient _httpClient;
        private readonly BackendContext _backendcontext;

        public FaceController(IHttpClientFactory httpClientFactory, BackendContext backendcontext)
        {
            _httpClient = httpClientFactory.CreateClient();
            _backendcontext = backendcontext;
        }

        [HttpPost]
        public async Task<IActionResult> Face_Recognition(IFormFile image)
        {
            if (image == null || image.Length == 0)
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

            /*try
            {
                using (var stream = new MemoryStream())
                {
                    await image.CopyToAsync(stream);
                    stream.Seek(0, SeekOrigin.Begin);

                    using (var requestContent = new StreamContent(stream))
                    {
                        requestContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(contentType);

                        var response = await _httpClient.PostAsync("https://app-policesoft.azurewebsites.net/api/classify", requestContent);

                        if (response.IsSuccessStatusCode)
                        {
                            var predictionResponse = await response.Content.ReadAsStringAsync();
                            var predictionJson = JsonConvert.DeserializeObject<dynamic>(predictionResponse);

                            using (JsonDocument doc = JsonDocument.Parse(predictionResponse))
                            {
                                var root = doc.RootElement;
                                var prediction = root.GetProperty("prediction").GetString();

                                var individ = await _backendcontext.Persoana.FirstOrDefaultAsync(i => i.Nume == prediction);

                                if (individ == null)
                                {
                                    return NotFound("Persoana " + prediction + " nu exista in baza de date");
                                }
                                else
                                {
                                    return Ok(individ);
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
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Exception: {ex.Message}");
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
            */
            try
            {
                using (var stream = new MemoryStream())
                {
                    await image.CopyToAsync(stream);
                    stream.Seek(0, SeekOrigin.Begin);

                    var content = new ByteArrayContent(stream.ToArray());
                    content.Headers.ContentType = new MediaTypeHeaderValue(contentType);

                    var response = await _httpClient.PostAsync("https://app-policesoft.azurewebsites.net/api/classify", content);

                    if (response.IsSuccessStatusCode)
                    {
                        var predictionResponse = await response.Content.ReadAsStringAsync();
                        var predictionJson = JsonConvert.DeserializeObject<dynamic>(predictionResponse);

                        using (JsonDocument doc = JsonDocument.Parse(predictionResponse))
                        {
                            var root = doc.RootElement;
                            var prediction = root.GetProperty("prediction").GetString();

                            Console.WriteLine(prediction);

                            var individ = await _backendcontext.Persoana.Include(m => m.Masinile).FirstOrDefaultAsync(i => i.Nume == prediction);

                            if (individ != null && individ.Masinile != null && individ.Masinile.Count > 0)
                            {
                                foreach (var masina in individ.Masinile)
                                {
                                    masina.Propietar = null;
                                }
                            }

                            if (individ == null)
                            {
                                return NotFound("Persoana " + prediction + " nu exista in baza de date");
                            }
                            else
                            {
                                return Ok(individ);
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
