using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.IdentityModel.Tokens;
using System.Diagnostics;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class CarController : ControllerBase
    {
        // Luăm path-ul către interpretorul de python şi script-ul de executat
        private readonly string pythonPath = Path.Combine((string)AppContext.GetData("DataDirectory"), "Scripts", "python.exe");
        private readonly string script = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Car A.I", "test.py");

        [HttpPost]
        public async Task<IActionResult> Car_Plate_Recognition(IFormFile picture)
        {
            var extension = Path.GetExtension(picture.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension) || ".jpg" != extension)
            {
                return BadRequest(new { message = "Fişierul primit este invalid sau corupt." });
            }
            var filePath = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Car A.I", "picture.jpg");
            using (var stream = System.IO.File.Create(filePath))
            {
                await picture.CopyToAsync(stream);
            }

            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = pythonPath;
            start.Arguments = string.Format("\"{0}\" \"{1}\"", script, "");
            start.UseShellExecute = false;
            start.RedirectStandardOutput = true;
            using (Process process = Process.Start(start))
            {
                using (StreamReader reader = process.StandardOutput)
                {
                    string result = reader.ReadToEnd();
                    System.IO.File.Delete(filePath);
                    return Ok(result);
                }
            }
        }
    }
}
