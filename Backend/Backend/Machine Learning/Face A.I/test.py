import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import load_img, img_to_array
import os

base_dir = os.path.dirname(os.path.abspath(__file__))

train_dir = os.path.join(base_dir, 'Dataset', 'Train')
test_dir = os.path.join(base_dir, 'Dataset', 'Test')

model_path = os.path.join(base_dir, 'trained_face_recognition_model.h5')
model = load_model(model_path)

class_names = sorted(os.listdir(train_dir))

confidence_threshold = 0.6

def predict_image(image_path):
    img = load_img(image_path, target_size=(128, 128))
    img_array = img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0) / 255.0

    prediction = model.predict(img_array)
    max_confidence = np.max(prediction)
    predicted_class = class_names[np.argmax(prediction)]

    if max_confidence < confidence_threshold:
        return "Necunoscut"
    return predicted_class


for root, dirs, files in os.walk(test_dir):
    for file in files:
        if file.lower().endswith(('png', 'jpg', 'jpeg')):
            image_path = os.path.join(root, file)
            predicted_class = predict_image(image_path)
            print(f'Imaginea: {image_path} - Predicție: {predicted_class}')
