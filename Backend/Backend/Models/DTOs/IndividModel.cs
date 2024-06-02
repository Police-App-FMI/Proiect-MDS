namespace Backend.Models.DTOs
{
    public class IndividModel
    {
        public string CNP { get; set; }

        public string Nume { get; set; }

        public string Permis_Validare { get; set; }

        public DateTime Data_Nastere { get; set; }
        public string Adresa_Domiciliu { get; set; }

        public string? Nr_Inmatriculare { get; set; }

        public string? Model_3D { get; set; }

        public DateTime? Data_Achizitie { get; set; }

        public double? Kilometraj { get; set; }
    }
}
