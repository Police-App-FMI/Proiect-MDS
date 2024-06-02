using Backend.Models.Base;
using System.ComponentModel.DataAnnotations;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Backend.Models
{
    public class Individ: BaseEntity
    {
        [Key]
        public string CNP { get; set; }

        public string Nume { get; set; }

        public string Permis_Validare { get; set; }

        public DateTime Data_Nastere { get; set; }
        public string Adresa_Domiciliu { get; set; }

        public ICollection<Autovehicul>? Masinile { get; set; }
    }
}
