using Backend.Models.Base;

namespace Backend.Models
{
    public class Reinforcement: BaseEntity
    {
        public string Nume { get; set; }
        public string Message { get; set; }
        public string Location { get; set; }
    }
}
