namespace Backend.Models.DTOs
{
    public class AuthenticationModel
    {
        public string username { get; set; }

        public string? profile_pic { get; set; }

        public string? email { get; set; }

        public string password { get; set; }
    }
}
