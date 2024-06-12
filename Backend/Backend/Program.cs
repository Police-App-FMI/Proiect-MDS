using Backend.Data;
using Backend.Helpers.Extensions;
using Backend.Models;
using Backend.Models.DTOs;
using Backend.Repositories.UserRepository;
using Backend.Services.Token_JWT;
using Backend.Services.UserService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using System.Text;
using System.Text.Json.Serialization;
using AutoMapper;
using Microsoft.Data.SqlClient;
using Backend.Services.ChatService;
using Backend.SignalR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http.Extensions;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddControllers();
builder.Services.AddDbContext<BackendContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
    };
});
builder.Services.AddSingleton<JwtTokenService>();

builder.Services.AddScoped<IUserRepository, UserRepository>();

builder.Services.AddHttpClient();

builder.Services.AddRepositories();
builder.Services.AddServices();

builder.Services.AddHostedService<ChatCleanupService>();

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.Preserve;
});

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

builder.Services.AddSignalR();

var dataDirectory = Directory.GetCurrentDirectory();
AppContext.SetData("DataDirectory", dataDirectory);

var app = builder.Build();

app.Use(async (context, next) =>
{
    var httpClientFactory = context.RequestServices.GetRequiredService<IHttpClientFactory>();
    var httpClient = httpClientFactory.CreateClient();

    await next();
});

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.UseMiddleware<JwtMiddleware>();

app.MapControllers();

app.Run();