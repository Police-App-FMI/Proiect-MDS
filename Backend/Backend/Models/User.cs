using Backend.Models.Base;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Security.Cryptography;

namespace Backend.Models
{
    public class User : BaseEntity
    {
        [Key]
        public string nume { get; set; }

        public string username { get; set; }

        public string profile_pic { get; set; }

        public string email { get; set; }

        private string _password;
        public string password
        {
            get { return _password; }
            set { _password = HashPassword(value); }
        }

        private string HashPassword(string password)
        {
            // Creăm sarea random
            byte[] salt;
            new RNGCryptoServiceProvider().GetBytes(salt = new byte[16]);

            // Creăm hash-ul PBKDF2
            var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 10000);
            byte[] hash = pbkdf2.GetBytes(20);

            // Combinăm sarea și hash-ul
            byte[] hashBytes = new byte[36];
            Array.Copy(salt, 0, hashBytes, 0, 16);
            Array.Copy(hash, 0, hashBytes, 16, 20);

            // Convertim byte array-ul într-un șir
            string savedPasswordHash = Convert.ToBase64String(hashBytes);
            return savedPasswordHash;
        }

        public DateTime? lastActive { get; set; }

        private bool _isOnline;
        public bool IsOnline
        {
            get
            {
                if (lastActive == null)
                {
                    return false;
                }
                // Verificăm dacă user-ul s-a autentificat cu succes şi dacă a avut activitate în ultimele 5 minute
                return _isOnline && DateTime.Now - lastActive < TimeSpan.FromMinutes(5);
            }
            set { _isOnline = value; }
        }

        public string? location { get; set; }
    }
}