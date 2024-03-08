using Backend.Models;

namespace Backend.Helpers.Extensions
{
    public static class OnlyActive
    {
        public static IQueryable<User> GetActiveUsers(this IQueryable<User> query)
        {
            return query.Where(x => !x.IsDeleted);
        }
    }
}
