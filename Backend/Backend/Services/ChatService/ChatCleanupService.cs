using Backend.Data;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services.ChatService
{
    public class ChatCleanupService : IHostedService, IDisposable
    {
        private readonly IServiceProvider _serviceProvider;
        private Timer _timer;

        public ChatCleanupService(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _timer = new Timer(DoWork, null, TimeSpan.Zero, TimeSpan.FromHours(1));
            return Task.CompletedTask;
        }

        private async void DoWork(object state)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<BackendContext>();
                var chatsToDelete = await context.Chats.Where(c => c.DateCreated < DateTime.Now.AddHours(-24)).ToListAsync();
                if (chatsToDelete.Any())
                {
                    context.Chats.RemoveRange(chatsToDelete);
                    await context.SaveChangesAsync();
                }
            }
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _timer?.Change(Timeout.Infinite, 0);
            return Task.CompletedTask;
        }

        public void Dispose()
        {
            _timer?.Dispose();
        }
    }
}
