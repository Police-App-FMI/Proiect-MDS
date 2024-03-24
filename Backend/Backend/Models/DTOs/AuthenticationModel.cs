namespace Backend.Models.DTOs
{
    public class AuthenticationModel
    {
        public string input { get; set; }

        public string? nume { get; set; }

        public string? profile_pic { get; set; }

        public string? mail { get; set; }

        public string password { get; set; }
    }
}
