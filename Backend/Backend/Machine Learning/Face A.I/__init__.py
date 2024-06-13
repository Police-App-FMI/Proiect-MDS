import logging
import json
import os
import cv2
import numpy as np
import tflite_runtime.interpreter as tflite
from cv2 import dnn_superres
from azure.functions import HttpRequest, HttpResponse

# Initialize TFLite model and other resources
base_dir = os.path.dirname(os.path.abspath(__file__))
tflite_model_path = os.path.join(base_dir, 'model.tflite')
interpreter = tflite.Interpreter(model_path=tflite_model_path)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

face_cascade_path = os.path.join(base_dir, 'haarcascade_frontalface_alt.xml')
face_cascade = cv2.CascadeClassifier(face_cascade_path)

class_names = ['Courteney_Cox', 'arnold_schwarzenegger', 'bhuvan_bam', 'hardik_pandya', 'Mihai_Stefanescu',
               'David_Schwimmer', 'Matt_LeBlanc', 'Simon_Helberg', 'scarlett_johansson', 'Pankaj_Tripathi',
               'Bogdan_Rosetti', 'Matthew_Perry', 'sylvester_stallone', 'Rares_Baciu', 'messi', 'Jim_Parsons',
               'random_person', 'Lisa_Kudrow', 'mohamed_ali', 'brad_pitt', 'ronaldo', 'virat_kohli', 'angelina_jolie',
               'Kunal_Nayya', 'manoj_bajpayee', 'Sachin_Tendulka', 'Jennifer_Aniston', 'dhoni', 'pewdiepie',
               'aishwarya_rai', 'Johnny_Galeck', 'ROHIT_SHARMA', 'suresh_raina']

# Create DnnSuperResImpl object
sr = dnn_superres.DnnSuperResImpl_create()
sr.readModel(os.path.join(base_dir, 'FSRCNN_x4.pb'))
sr.setModel('fsrcnn', 4)

def predict_frame(frame):
    resized_frame = cv2.resize(frame, (96, 96))  # Resize image to 96x96
    img_array = np.array(resized_frame, dtype=np.float32)  # Convert frame to float32 array
    img_array = np.expand_dims(img_array, axis=0) / 255.0

    interpreter.set_tensor(input_details[0]['index'], img_array)
    interpreter.invoke()
    prediction = interpreter.get_tensor(output_details[0]['index'])

    prediction_index = round(float(prediction[0]))
    predicted_class = class_names[prediction_index]

    return predicted_class

def upscale_image(image):
    if image is None:
        return None

    upscaled_image = sr.upsample(image)
    return upscaled_image

def crop_face(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=2, flags=2, minSize=(20, 20))

    if len(faces) == 0:
        return None
    
    (x, y, w, h) = faces[0]
    face_roi = image[y:y + h, x:x + w]
    
    return face_roi

def predict_image(image):
    face_roi = crop_face(image)
    
    if face_roi is None:
        return "Fata nu a fost detectata."
    
    predicted_label = predict_frame(face_roi)
    return predicted_label

def main(req: HttpRequest) -> HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_body()

        # Read the image from the request body
        image_array = np.frombuffer(req_body, np.uint8)
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
        
        if image is None:
            logging.error('Failed to decode the image')
            return HttpResponse('Failed to decode the image', status_code=400)
        
        logging.info('Image successfully decoded')
        prediction = predict_image(image)

        response_data = {
            "prediction": prediction
        }

        return HttpResponse(json.dumps(response_data), status_code=200)

    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return HttpResponse(f"Error: {e}", status_code=500)

