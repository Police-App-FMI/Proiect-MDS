using AutoMapper;
using Backend.Models;
using Backend.Models.DTOs;

namespace Backend.Helpers
{
    public class MapperProfile: Profile
    {
        public MapperProfile() {

            CreateMap<User, AuthenticationModel>();
            CreateMap<AuthenticationModel, User>();
        }
    }
}
