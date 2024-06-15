# Police Software

PoliceSoft is a mobile application designed to enhance the efficiency and effectiveness of law enforcement officers in traffic operations. The app features communication, face and car plate recognition, on-duty management, and tools for handling missing persons.

## Key Features

- **General Chat**: Communication among officers.
- **Face Recognition**: Extract personal information from government databases.
- **Car Plate Recognition**: Retrieve vehicle details.
- **On Duty Management**: Track on-duty officers and call for reinforcements.
- **Missing Persons**: Report and view missing persons on a map.

## Use Case Diagram
![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/assets/76045639/22d145be-147a-4c3a-a739-7b494ff663c4)

## Workflow Diagram
![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/workflow.png)


## User Stories
- A police officer uses the application to identify if a person has had prior incidents, through facial recognition.
- A police officer uses the application to identify if a car has all its documents in order, through license plate recognition.
- In emergency situations, the application provides information on which officers are available, displaying a map to see who is closest.
- A police officer is in danger and calls the nearest on-duty officers through the application.
- Officers can use the application if a criminal has committed a crime and was recorded by a surveillance camera to check their identity.
- Officers can use the application if a car appears suspicious to verify if the driver matches the owner.
- Officers can use the application if a car appears suspicious to check if the car matches the license plate.
- In the case of a serious road accident, the officer can call other units for assistance.
- In the case of a car chase, the officer can check who the car belongs to and see information related to the driver.
- The officer can use the application to see possible vehicles of a fugitive, preventing their escape.

## The Backend API

Welcome to our project! Firstly, we will talk a bit about the backend API for our mobile application. The API is designed to interact with a database that includes the following tables:

- [**Person**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Individ.cs): Stores relevant data about a person.
- [**Car**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Autovehicul.cs): Stores relevant data about a car that can be linked to a person.
- [**Users**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/User.cs): Stores relevant and personal data about a user.
- [**Chats**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Chat.cs): Stores messages sent in chat along with data about the user who sent the message. Messages are deleted after 24 hours, a feature implemented in the [ChatService](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Services/ChatService/ChatCleanupService.cs).
- [**Reinforcements**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/Reinforcement.cs): Stores relevant data about a user who is requesting assistance from colleagues.
- [**Missing Persons**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Models/MissingPerson.cs): Stores relevant data about a missing person.

We have also implemented 6 controllers to facilitate data flow between the backend and frontend:

- [**Authentication Controller**](#authentication-controller): Implements the logic for user accounts, using extensively the features implemented in [UserService](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Services/UserService/UserService.cs).
- [**Database Controller**](#database-controller): Implements the logic for inserting data into the database.
- [**Car Controller**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/CarController.cs): Implements the logic for license plate recognition.
- [**Face Controller**](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Controllers/FaceController.cs): Implements the logic for facial recognition of individuals.
- [**Chat Controller**](#chat-controller): Implements the logic for sending, modifying, deleting, and receiving chat messages.
- [**On Duty Controller**](#on-duty-controller): Implements the logic for the Call Reinforcements, Missing Person, and GPS Location functionalities for users who are "On Duty".

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


## The Machine Learning Part
<!-- Aici trebuie să faci introducerea cum am făcut-o eu mai sus la Backend API Rareş! -->
### Upscalling A.I[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Machine%20Learning/Upscalling%20A.I/upscale.py)

This script uses the DNN (Deep Neural Network) module from OpenCV to upscale images and videos. It uses pre-trained models for upscaling.

##### How it works

1. The script first creates a `DnnSuperResImpl` object.

2. It then tries to open an image file and a video file.

3. If the image file is opened successfully:
    - The script loads the pre-trained FSRCNN model.
    - It sets the model and scale.
    - It performs the upscaling algorithm on the image.
    - The upscaled image is then saved to memory.

4. If the video file is opened successfully:
    - The script loads the pre-trained ESPCN model (as it is faster than EDSR).
    - It sets the model and scale.
    - It gets the first frame of the video and performs the upscaling algorithm on it.
    - It gets the dimensions of the upscaled frame.
    - It creates a `VideoWriter` object with the dimensions of the upscaled frame and a frame rate of 24 (set by us).
    - It writes the first upscaled frame to the output file.
    - It then gets the total number of frames in the video.
    - For each frame in the video, it performs the upscaling algorithm and writes the upscaled frame to the output file.
    - Finally, it closes the files.

If neither the image nor the video file is opened successfully, the script prints "False".

##### Requirements

- OpenCV
- Pre-trained [FSRCNN](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Machine%20Learning/Upscalling%20A.I/FSRCNN_x4.pb) and [ESPCN](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Machine%20Learning/Upscalling%20A.I/ESPCN_x4.pb) models

##### Usage

Run the script in the same directory as your image and video files. Make sure to update the paths to the image, video, and model files in the script.


### License Plate Detection[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Machine%20Learning/Car%20A.I/__init__.py)

This script is designed to recognize vehicle license plate numbers from images using OpenCV and the Google Cloud Vision API. The script is intended to be deployed as an Azure Function.

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/sample1.png)

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/sample2.png)

#### How it works

1. The main function is triggered by an HTTP request.

2. The script extracts the image file from the request body.

3. The Google Cloud Vision API client is initialized using credentials specified in the environment.

4. The image is read directly from the request body.

5. If the image is successfully decoded:
	- The 'detect_license_plate function' is called to identify and extract the license plate text.
	- The extracted text is returned in a JSON response.

6. If the image cannot be decoded, an error message is returned.
   
#### Requirements
	- OpenCV
	- Google Cloud Vision API
	- Azure Functions

#### Usage

Deploy the script as an Azure Function. Ensure that the image and model files are accessible. The paths to the Google Cloud Vision credentials and the Haar cascade model need to be correctly set in the environment and script, respectively.

Run the script in the same directory as your image files or update the image_path to the correct path of your image.


### Face Detection[^](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/Backend/Backend/Machine%20Learning/Car%20A.I/__init__.py)

This script uses OpenCV and TFLite to detect faces, upscale images, and recognize known individuals from an input image. The script is designed to run as an Azure Function.

#### How it works

1. Initialization:
    - The script initializes the TFLite model and allocates tensors.
    - It loads the Haar Cascade for face detection.
    - It initializes a list of class names for recognized individuals.
    - A DnnSuperResImpl object is created for image upscaling.

2. Image Processing Functions:
    - predict_frame: Resizes the frame, prepares it for the TFLite model, and returns the predicted class name.
    - upscale_image: Uses the FSRCNN model to upscale the image.
    - crop_face: Converts the image to grayscale, detects faces, and crops the face region.

3. Prediction Function:
	- predict_image: Crops the face from the image and predicts the class label using the TFLite model.

4. Main Function:
    - main: Handles the HTTP request, reads and decodes the image, processes the image for face detection and recognition, and returns the prediction result.
#### Requirements
	- OpenCV
	- NumPy
	- TFLite Runtime
	- Azure Functions
	- Logging
	- Usage

#### Usage

Run the script with the image path as an argument. Update the image path in the script accordingly.

Run the script in the same directory as your image files or update the image_path to the correct path of your image.

## The mobile app

Welcome to the front-end of our project! Here, we'll talk about the design of the front-end app.

We have implemented 6 screens for the frontend of our app:

- [**Login screen**](#login-screen): It's the login screen that has the email/username and password TextForms.
- [**Home screen**](#home-screen): It's the home screen of our app, rom which you can access all functionalities.
- [**URL Error**](#url-error): Shows up in case of an error.
- [**Face recognition**](#face-recognition): It's the screen used for the face recognition functionality.
- [**Plate recognition**](#plate-recognition): It's the screen used for the car plate recognition functionality.
- [**Missing person**](#missing-person): It's the screen used for the missing person functionality.
- [**Call reinforcements**](#call-reinforcements): It's the screen used for the call reinforcements functionality, that sends the location of the officer that has an emergency and a notification to other on-duty officers.
- [**On Duty**](#on-duty): It's the screen used for the on duty functionality, which has a list of on duty officers and a map with the location of the on duty officers.


### Login Screen[^](*link*)

This screen implements a login screen featuring a modern UI with email and password validation.


## Features

- Email and password input fields with validation

- Gradient background

- Rounded corners for UI elements

- Login button that triggers authentication logic

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [Provider](https://pub.dev/packages/provider) - State management
- [Email Validator](https://pub.dev/packages/email_validator) - Email validation


## Explanation of Key Elements
- **Gradient Background**: Provides a visually appealing gradient background.
- **Rounded Corners**: Adds rounded corners to containers for a modern look.
- **Email and Password Validation**: Uses the email_validator package to validate email addresses and ensures passwords are at least 6 characters long.
- **Login Button**: Triggers the verifyLogin function from User_provider to handle authentication logic.



### Home Screen[^](*link*)

This screen implements the home screen for the Police App featuring a chat interface with emoji support, image handling, and message editing capabilities.

## Features

- Real-time message updates with a chat stream
- Text input with emoji picker
- Image message handling
- Message editing and deletion
- Responsive UI with a gradient background and rounded corners

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [Provider](https://pub.dev/packages/provider) - State management
- [Emoji Picker Flutter](https://pub.dev/packages/emoji_picker_flutter) - Emoji picker
- [Intl](https://pub.dev/packages/intl) - Internationalization and localization

## Explanation of Key Elements
- **Real-time Message Updates**: Listens for new messages and updates the chat interface in real-time.
- **Emoji Picker**: Allows users to select and insert emojis into their messages.
- **Image Handling**: Supports sending and displaying image messages, with base64 encoding/decoding.
- **Message Editing and Deletion**: Provides options to edit or delete messages through dialog interactions.
- **Responsive UI**: Features a gradient background, rounded corners, and responsive design elements to ensure a modern look.

### URL Error Screen

This screen notifies the user about server unavailability and provides a button to attempt reconnection.

## Features

- Informative message about server unavailability
- Reconnection button to retry server connection

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [Provider](https://pub.dev/packages/provider) - State management

## Explanation of Key Elements

- **Informative Message**: Displays a message informing the user that the server is down.
- **Reconnection Button**: Allows the user to attempt reconnecting to the server.
- **Snackbar Feedback**: Provides feedback to the user with a Snackbar indicating loading and connection status.


### Plate Recognition Screen

This screen allows users to recognize car plates from images using an API integration.

## Features

- Select image from gallery or capture with camera
- Display image and details of recognized vehicle
- Error message display for server connection issues

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [Image Picker](https://pub.dev/packages/image_picker) - Plugin for selecting images
- [File Picker](https://pub.dev/packages/file_picker) - Plugin for selecting files
- [HTTP](https://pub.dev/packages/http) - HTTP client for making requests
- [HTTP Parser](https://pub.dev/packages/http_parser) - Utility for parsing HTTP media types

## Explanation of Key Elements
- **Image Selection**: Users can choose an image from the gallery or capture one using the camera.
- **Image Display**: Displays the selected image with the option to recognize the car plate.
- **API Integration**: Utilizes an API to send the selected image for plate recognition.
- **Error Handling**: Displays error messages if there are issues connecting to the server or recognizing the plate.


### Face Recognition Screen[^](*link*)

This screen enables facial recognition using images captured from the camera or gallery.

## Features

- Select image from gallery or capture with camera
- Display image and details of recognized individual
- Error message display for server connection issues

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [Image Picker](https://pub.dev/packages/image_picker) - Plugin for selecting images
- [File Picker](https://pub.dev/packages/file_picker) - Plugin for selecting files
- [HTTP](https://pub.dev/packages/http) - HTTP client for making requests
- [HTTP Parser](https://pub.dev/packages/http_parser) - Utility for parsing HTTP media types

## Explanation of Key Elements
- **Image Selection**: Users can choose an image from the gallery or capture one using the camera.
- **Image Display**: Displays the selected image with the option to recognize the individual.
- **API Integration**: Utilizes an API to send the selected image for facial recognition.
- **Error Handling**: Displays error messages if there are issues connecting to the  server or recognizing the individual.


### Call Reinforcements Screen[^](*link*)

This screen allows users to call reinforcements and display SOS calls.

## Features

- Call button triggers API request to call reinforcements
- Display list of SOS calls with details

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [HTTP](https://pub.dev/packages/http) - HTTP client for making requests
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) - Plugin for integrating Google Maps
- [URL Launcher](https://pub.dev/packages/url_launcher) - Plugin for launching URLs

## Explanation of Key Elements
- **Call Button**: Initiates a request to call reinforcements using the specified API endpoint.
- **SOS Calls List**: Displays a list of SOS calls retrieved from the backend.
- **API Integration**: Communicates with the backend to send SOS calls and fetch updated call lists.

### Missing Person Screen[^](*link*)

This screen displays the location of a missing person using Google Maps.

## Features

- Displays a Google Map showing the missing person's last known location
- Shows a circular search area around the location

## Dependencies

- [Flutter](https://flutter.dev/) - UI toolkit
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) - Plugin for   integrating Google Maps

## Explanation of Key Elements
- **Google Map**: Displays the map with a marker at the missing person's location.
- **Search Area Circle**: Represents a circular area around the missing person's location for search purposes.

## Design patterns 

## Overview
The `/login` endpoint is a POST endpoint that allows users to authenticate in the application. It implements a Singleton design pattern to prevent a user from being logged in on multiple devices simultaneously.

## Functionality
1. **Input Verification:** Depending on the input provided (email or username), the endpoint determines how to verify the user's authentication.
2. **Password Verification:** The provided password is compared with the password stored in the database for the respective user.
3. **Singleton Pattern:** If the user is already authenticated on another device (`user.IsOnline` is `true`), the authentication is denied.
4. **JWT Token Generation:** If the authentication is successful, a JWT token is generated for the user.
5. **User State Update:** The user's state is updated to reflect that they are now online, and the information is saved in the database.

## Implementation Details

### Input Verification (Email or Username)
- If `model.input` contains an `@` symbol, it is assumed to be an email.
  - The user is searched in the database using the email.
- If `model.input` does not contain `@`, it is assumed to be a username.
  - The user is searched using the `_userService.GetUserByUsername` service.

### Password Verification
- The `VerifyPassword` function is used to compare the provided password (`model.password`) with the password stored in the database.

### Singleton Pattern
- If `user.IsOnline` is `true`, the endpoint returns an `Unauthorized` response with a message indicating that the user is already logged in on another device.

### JWT Token Generation
- The `_JwtToken.GenerateToken(user)` function is used to generate a JWT token for the user.
  - The JWT token is used for subsequent authentication in the application.

### User State Update
- The last active date (`user.lastActive`) is updated to the current date and time.
- The user's online status (`user.IsOnline`) is set to `true`.
- The changes are saved in the database using `_backendcontext.Users.Update(user)` and `await _backendcontext.SaveChangesAsync()`.

## Response Structure

### Successful Authentication
- **Status:** 200 OK
- **Content:**
  ```json
  {
    "Nume": "nume",
    "ProfilePic": "profile_pic",
    "Email": "email",
    "Token": "token_jwt"
  }

## ChatGPT

### For our project ChatGPT and other language models to make our workflow more efficient. For example, when we had a quick problem, we asked ChatGPT for a solution and went from there.

### Below is an example of how we started to implement the Google Maps API for the multiple screens that used it. We asked ChatGPT for it's input and the solution worked well.

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/chatgpt_screenshot.png)

## Refactoring

#### Refactoring refers to modifying a small part of code in order to improve it, while still retaining the original functionality. Using this principal of incremental changes, we managed to refactor our car plate recognition code. Below is a before and after of the work we did. The first iteration used EasyOCR and actually added the result over the original picture. However, the package took a lot of memory(5 GB) so we change to Google Vision API and this way we were able to use the car plate recognition using Azure in order to host our backend.

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/before.png)

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/after.png)

## Bug reporting and solving with pull requests

#### While we were working on our project, we first had this bug

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/bug.png)

#### Following this report, we solved this issues through the following pull requests.

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/pullreq.png)

## Code comments

#### In our code, we made sure to add comments to important parts to make sure that it's easy to understand and follow through when other people are looking through our code.

#### Below are a few screenshots of such cases.

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/commentfrontend.png)

#### For the frontend of our project

![Not Found!](https://github.com/Police-App-FMI/Proiect-MDS/blob/main/ReadMePhotos/commentbackend.png)

#### For the backend of our project

## App Demo[^](https://youtu.be/nTvU5FMcFx0)

Aici este incarcat demo-ul nostru: [youtube link](https://youtu.be/nTvU5FMcFx0)
