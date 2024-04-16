using Backend.Models.Base;

namespace Backend.Models
{
    public class MissingPerson: BaseEntity
    {
        public string Name { get; set; }
        public string ProfilePic { get; set; }
        public string Description { get; set; }
        public string PhoneNumber { get; set; }
        public string LastSeenLocation { get; set; }
    }
}
