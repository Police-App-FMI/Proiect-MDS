using Microsoft.AspNetCore.SignalR;

namespace Backend.SignalR
{
    public class SRHub : Hub
    {
        public async Task GetMessage(string nume, string profile_pic, string mesaj, DateTime date_send)
        {
            await Clients.All.SendAsync("ReceiveMessage", nume, profile_pic, mesaj, date_send);
        }
    }
}