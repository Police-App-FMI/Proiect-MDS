using Backend.Models.Base;

namespace Backend.Models
{
    public class Chat: BaseEntity
    {
        public string Nume { get; set; }

        public string Profile_Pic { get; set; }

        public string Message { get; set; }
    }
}
