# Proiect-MDS
![Not Found!](https://github.com/Rares5000/Proiect-MDS/assets/76045639/01abeb99-98f4-49fc-bf59-b4b3b0f6f890)
## The Backend API

Welcome to our project! Firstly, we will talk a bit about the backend API for our mobile application. The API is designed to interact with a database that includes the following tables:

- [**Person**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Individ.cs): Stores relevant data about a person.
- [**Car**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Autovehicul.cs): Stores relevant data about a car that can be linked to a person.
- [**Users**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/User.cs): Stores relevant and personal data about a user.
- [**Chats**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Chat.cs): Stores messages sent in chat along with data about the user who sent the message. Messages are deleted after 24 hours, a feature implemented in the [ChatService](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Services/ChatService/ChatCleanupService.cs).
- [**Reinforcements**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Reinforcement.cs): Stores relevant data about a user who is requesting assistance from colleagues.
- [**Missing Persons**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/MissingPerson.cs): Stores relevant data about a missing person.

We have also implemented 6 controllers to facilitate data flow between the backend and frontend:

- [**Authentication Controller**](https://github.com/Police-App-FMI/Proiect-MDS/main/README.md#authentication-controller): Implements the logic for user accounts, using extensively the features implemented in [UserService](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Services/UserService/UserService.cs).
- [**Database Controller**](https://github.com/Police-App-FMI/Proiect-MDS/main/README.md#database-controller): Implements the logic for inserting data into the database.
- [**Car Controller**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/CarController.cs): Implements the logic for license plate recognition.
- [**Face Controller**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/FaceController.cs): Implements the logic for facial recognition of individuals.
- [**Chat Controller**](https://github.com/Police-App-FMI/Proiect-MDS/main/README.md#chat-controller): Implements the logic for sending, modifying, deleting, and receiving chat messages.
- [**On Duty Controller**](https://github.com/Police-App-FMI/Proiect-MDS/main/README.md#on-duty-controller): Implements the logic for the Call Reinforcements, Missing Person, and GPS Location functionalities for users who are "On Duty".

### Authentication Controller[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/AuthenticationController.cs)
The `AuthenticationController` is responsible for user authentication and management. It includes the following methods:

- **GetUsers**: This method retrieves all users. It returns a list of users with their name, online status, last active time, and profile picture.

- **CheckToken**: This method checks if the user is logged in. If the user is logged in, it returns HTTP 200 (OK) and updates the user's activity. Otherwise, it returns HTTP 401 (Unauthorized), and the frontend will call the `Disconnect` method.

- **Disconnect**: This method disconnects a user. It updates the user's last active time, sets the online status to false, and clears the user's location.

- **Register**: This method registers a new user. It creates a new user with the provided details and saves it to the database. If the registration is successful, it returns a success message. Otherwise, it returns a failure message.

- **Login**: This method logs in a user. It checks if the entered username or email and password match the stored details. If the login is successful, it generates a JWT token, returns the user's details, and updates the user's status. Otherwise, it returns an error message.

- **VerifyPassword**: This private method verifies the entered password against the stored hash. It converts the stored hash into a byte array, extracts the salt from the stored hash, creates a new hash for the entered password using the stored salt, and compares the hashes. If the hashes match, it returns true. Otherwise, it returns false.

The `AuthenticationController` uses the `IUserService` for user management, `JwtTokenService` for JWT token generation, and `BackendContext` for database operations.

#### User Service
The `UserService` class implements the `IUserService` interface. It uses the `IUserRepository` for database operations and `IMapper` for object mapping. It includes the following methods:

- **GetAllUsers**: This method retrieves all users from the repository and maps them to `User` objects.
- **GetById**: This method retrieves a user by their ID from the repository and maps it to a `User` object.
- **GetUserByUsername**: This method retrieves a user by their username from the repository and maps it to a `User` object.
- **CreateUserAsync**: This method creates a new user. It checks if a user with the same username or email already exists. If not, it adds the new user to the repository. It returns true if the addition was successful, and false if an exception occurred.
- **DeleteUser**: This method deletes a user by their username. It checks if the user exists. If so, it deletes the user from the repository. It returns true if the deletion was successful, and false if the user was not found.

### Database Controller[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/BazaDeDateController.cs)
The `DatabaseController` is responsible for managing the database. It includes the following methods:

- **AddIndivid**: This method adds a new individual to the database. It creates a new `Person` object with the provided details and saves it to the database. If the individual also has a car, it creates a new `Car` object, links it to the individual, and saves it to the database. If the addition is successful, it returns HTTP 200 (OK). Otherwise, it returns HTTP 400 (Bad Request) with an error message.

- **AddVehicul**: This method adds a new vehicle to the database. It checks if the owner of the vehicle exists. If so, it creates a new `Car` object with the provided details, links it to the owner, and saves it to the database. If the addition is successful, it returns HTTP 200 (OK). Otherwise, it returns HTTP 400 (Bad Request) with an error message.

This controller uses the `BackendContext` for database operations.

#### Backend Context
The `BackendContext` class extends the `DbContext` class from Entity Framework Core. It represents a session with the database and can be used to query and save instances of our entities. It includes the following `DbSet` properties:

- **Person**: This property represents the `Individ` table in the database.
- **Car**: This property represents the `Autovehicul` table in the database.
- **Users**: This property represents the `User` table in the database.
- **Chats**: This property represents the `Chat` table in the database.
- **Reinforcements**: This property represents the `Reinforcement` table in the database.
- **MissingPersons**: This property represents the `MissingPerson` table in the database.

The `BackendContext` constructor takes `DbContextOptions<BackendContext>` as a parameter, which is a framework-provided way to configure the context.

The `OnModelCreating` method is overridden to configure the model that was discovered by convention from the entity types exposed in `DbSet` properties on your derived context. In this case, it configures the one-to-many relationship between `Individ` and `Autovehicul`.

<!-- Aici intră secţiunea ta Rareş cu cotroller-ele de ML -->

### Chat Controller[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/ChatController.cs)
The `ChatController` is responsible for managing the chat functionality. It includes the following methods:

- **GetMessages**: This method retrieves all chat messages. It returns a list of messages with the sender's name, profile picture, message, and send date. It also sends the messages to all clients connected to the `SignalR` hub.

- **SendMessage**: This method sends a new message. It creates a new `Chat` object with the provided message and the authenticated user's details and saves it to the database.

- **ChangeMessage**: This method changes a message. It finds the message by the authenticated user's name and the send date, changes the message, updates the modified date, and saves the changes to the database. If the message is not found, it returns an error message.

- **DeleteMessage**: This method deletes a message. It finds the message by the authenticated user's name and the send date and removes it from the database. If the message is not found, it returns an error message.

This controller uses the `IUserService` for user management, `BackendContext` for database operations, and `IHubContext<SRHub>` for SignalR hub operations.

#### SRHub
The `SRHub` class extends the `Hub` class from SignalR. It includes the following methods:

- **GetMessage**: This method sends a message to all clients connected to the hub. It takes the sender's name, profile picture, message, and send date as parameters.

#### Chat Cleanup Service
The `ChatCleanupService` class implements the `IHostedService` and `IDisposable` interfaces. It is responsible for cleaning up old chat messages. It includes the following methods:

- **StartAsync**: This method starts the service. It initializes a timer that calls the `DoWork` method every hour.

- **DoWork**: This method deletes chat messages that are older than 24 hours. It retrieves the messages from the database, removes them, and saves the changes to the database.

- **StopAsync**: This method stops the service. It changes the timer's due time to infinite, effectively stopping the timer.

- **Dispose**: This method disposes of the timer.

This service uses the `IServiceProvider` for dependency injection and `BackendContext` for database operations.

### On Duty Controller[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/OnDutyController.cs)
The `OnDutyController` is responsible for managing the "on duty" functionalities. It includes the following methods:

- **GetLocation**: This method retrieves the locations of all users. It returns a list of users with their name, profile picture, and location.

- **PostLocation**: This method updates the location of the authenticated user. If the update is successful, it returns HTTP 200 (OK). Otherwise, it returns HTTP 400 (Bad Request) with an error message.

- **SendReinforcements**: This method retrieves all reinforcements. It returns a list of reinforcements with the ID, name, message, location, and time.

- **CallReinforcements**: This method calls for reinforcements. It creates a new `Reinforcement` object with the provided details and the authenticated user's name and saves it to the database. If the call is successful, it returns HTTP 200 (OK). Otherwise, it returns HTTP 400 (Bad Request) with an error message.

- **EndReinforcements**: This method ends a reinforcement. It finds the reinforcement by the authenticated user's name and the ID and removes it from the database. If the end is successful, it returns HTTP 200 (OK) with a success message. Otherwise, it returns HTTP 404 (Not Found) with an error message.

- **GetPerson**: This method retrieves all missing persons. It returns a list of missing persons with the ID, name, portrait, description, phone number, last seen location, and last seen date.

- **AddPerson**: This method adds a missing person. It creates a new `MissingPerson` object with the provided details and saves it to the database.

- **UpdatePerson**: This method updates the last seen location of a missing person. It finds the person by the ID, updates the last seen location and the last seen date, and saves the changes to the database. If the update is successful, it returns HTTP 200 (OK). Otherwise, it returns HTTP 404 (Not Found) with an error message.

- **FoundPerson**: This method marks a missing person as found. It finds the person by the ID and removes them from the database. If the operation is successful, it returns HTTP 200 (OK) with a success message. Otherwise, it returns HTTP 404 (Not Found) with an error message.

This controller uses the `IUserService` for user management and `BackendContext` for database operations.


## The Mobile Police App

