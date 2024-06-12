using Backend.Models.Base;
using System.ComponentModel.DataAnnotations;

namespace Backend.Models
{
    public class Autovehicul: BaseEntity
    {
        [Key]
        public string Nr_Inmatriculare { get; set; }

        public string Model_3D { get; set; }

        public DateTime Data_Achizitie { get; set; }

        public double Kilometraj {  get; set; }

        public Individ? Propietar {  get; set; }
    }
}
