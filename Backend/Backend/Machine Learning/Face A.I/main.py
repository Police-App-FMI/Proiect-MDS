import os
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt

# Directorul cu datele de antrenare
train_dir = 'C:/Users/baciu/Documents/GitHub/Proiect-MDS/Backend/Backend/Machine Learning/Face A.I/Dataset/Train'


# Parametrii pentru preprocesarea imaginilor
batch_size = 32
image_size = (128, 128)

# Generator de date pentru antrenare
train_datagen = ImageDataGenerator(rescale=1./255, validation_split=0.2)

# Generator pentru datele de antrenare
train_generator = train_datagen.flow_from_directory(
    train_dir,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='categorical',
    subset='training'
)

# Generator pentru datele de validare
validation_generator = train_datagen.flow_from_directory(
    train_dir,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='categorical',
    subset='validation'
)

# Definim modelul
model = models.Sequential([
    layers.Conv2D(32, (3, 3), activation='relu', input_shape=(128, 128, 3)),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(128, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Flatten(),
    layers.Dense(512, activation='relu'),
    layers.Dense(len(train_generator.class_indices), activation='softmax')
])

# Compilăm modelul
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Antrenăm modelul
history = model.fit(
    train_generator,
    epochs=25,
    validation_data=validation_generator
)

# Salvăm modelul antrenat
model.save('trained_face_recognition_model.h5')

# Afișăm acuratețea și pierderea pe grafic
acc = history.history['accuracy']
val_acc = history.history['val_accuracy']
loss = history.history['loss']
val_loss = history.history['val_loss']

epochs_range = range(10)

plt.figure(figsize=(8, 8))
plt.subplot(1, 2, 1)
plt.plot(epochs_range, acc, label='Acuratețe antrenare')
plt.plot(epochs_range, val_acc, label='Acuratețe validare')
plt.legend(loc='lower right')
plt.title('Acuratețea antrenării și validării')

plt.subplot(1, 2, 2)
plt.plot(epochs_range, loss, label='Pierdere antrenare')
plt.plot(epochs_range, val_loss, label='Pierdere validare')
plt.legend(loc='upper right')
plt.title('Pierdere antrenare și validare')
plt.show()
