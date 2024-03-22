using Backend.Models.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class FaceController : ControllerBase
    {
        // Luăm path-ul către interpretorul de python şi script-ul de executat
        private readonly string pythonPath = Path.Combine((string)AppContext.GetData("DataDirectory"), "Scripts", "python.exe");
        private readonly string script = Path.Combine((string)AppContext.GetData("DataDirectory"), "Machine Learning", "Face A.I", "test.py");

        [HttpPost]
        public async Task<IActionResult> Face_Recognition([FromBody] string input)
        {
            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = pythonPath;
            start.Arguments = string.Format("\"{0}\" \"{1}\"", script, input);
            start.UseShellExecute = false;
            start.RedirectStandardOutput = true;
            start.RedirectStandardInput = true;
            using (Process process = Process.Start(start))
            {
                using (StreamWriter writer = process.StandardInput)
                {
                    writer.WriteLine(input);
                }

                using (StreamReader reader = process.StandardOutput)
                {
                    string result = reader.ReadToEnd();
                    return Ok(result);
                }
            }
        }
    }
}
