using Backend.Models.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Diagnostics;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class FaceController : ControllerBase
    {
        // Luăm path-ul către interpretorul de python şi script-ul de executat
        private readonly string pythonPath = Path.Combine((string)AppContext.GetData("DataDirectory"), "venv", "Scripts", "python.exe");
        private readonly string script = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Face A.I", "test.py");
        private readonly string upscale = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Upscalling A.I", "upscale.py");

        [HttpPost]
        public async Task<IActionResult> Face_Recognition(IFormFile video)
        {
            var extension = Path.GetExtension(video.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension) || ".mp4" != extension)
            {
                return BadRequest(new { message = "Fişierul primit este invalid sau corupt." });
            }
            var filePath = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Face A.I", "video.mp4");
            using (var stream = System.IO.File.Create(filePath))
            {
                await video.CopyToAsync(stream);
            }

            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = pythonPath;
            start.Arguments = string.Format("\"{0}\" \"{1}\"", script, "");
            start.UseShellExecute = false;
            start.RedirectStandardOutput = true;
            start.RedirectStandardInput = true;
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

        [HttpPost("test")]
        public async Task<IActionResult> test(IFormFile video)
        {
            var extension = Path.GetExtension(video.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(extension) || ".mp4" != extension)
            {
                return BadRequest(new { message = "Fişierul primit este invalid sau corupt." });
            }
            var filePath = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Upscalling A.I", "video.mp4");
            using (var stream = System.IO.File.Create(filePath))
            {
                await video.CopyToAsync(stream);
            }

            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = pythonPath;
            start.Arguments = string.Format("\"{0}\" \"{1}\"", upscale, "");
            start.UseShellExecute = false;
            start.RedirectStandardOutput = true;
            start.RedirectStandardInput = true;
            using (Process process = Process.Start(start))
            {
                using (StreamReader reader = process.StandardOutput)
                {
                    string result = reader.ReadToEnd();
                    System.IO.File.Delete(filePath);
                    if (result != "False")
                        return Ok(result);
                    else return BadRequest(new { message = "Ceva a mers prost!" });
                }
            }
        }
    }
}
