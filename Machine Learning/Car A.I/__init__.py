import cv2
import logging
import numpy as np
import json
import os
import re
from azure.functions import HttpRequest, HttpResponse
from google.cloud import vision

def main(req: HttpRequest) -> HttpResponse:
    try:
        # Obține fișierul imagine din corpul cererii HTTP
        req_body = req.get_body()
        
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'vision-ai-api-text-recognition-a40d339e497f.json'
        client = vision.ImageAnnotatorClient()

        # Citirea imaginii direct din corpul cererii
        image_array = np.frombuffer(req_body, np.uint8)
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
        
        if image is None:
            logging.error('Failed to decode the image')
            return HttpResponse('Failed to decode the image', status_code=400)
        
        # Detectăm numărul de înmatriculare și returnăm textul în răspuns
        license_plate_text = detect_license_plate(image, client)

        # Pregătim răspunsul JSON cu textul detectat
        response_data = {
            "license_plate_text": license_plate_text
        }

        return HttpResponse(json.dumps(response_data), status_code=200)

    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return HttpResponse(f"Error: {e}", status_code=500)

def extract_license_plate(text):
    # Expresie regulată pentru a găsi numere de înmatriculare în text
    pattern = r'(?:RO\s*)?([A-Z]{1,2}[\s-]?\d{2,3}[\s-]?[A-Z]{2,3})'
    
    # Caută potrivirile în text
    matches = re.findall(pattern, text)
    
    # Returnează prima potrivire (presupunând că este numărul de înmatriculare)
    if matches:
        plate_number = matches[0]
        # Eliminăm orice caracter care nu este literă sau cifră
        plate_number = re.sub(r'[^A-Za-z0-9]', '', plate_number)
        return plate_number
    
    return "No license plate number found"

def detect_license_plate(image, client):
    cascade_path = os.path.join(os.path.dirname(__file__), 'haarcascade_russian_plate_number.xml')
    license_plate_detector = cv2.CascadeClassifier(cascade_path)
    plates = license_plate_detector.detectMultiScale(cv2.cvtColor(image, cv2.COLOR_BGR2GRAY), 1.2)
    
    # Dacă am detectat cel puțin un număr de înmatriculare
    if len(plates) > 0:
        for (x, y, w, h) in plates:
            # Cropăm imaginea pentru a obține numărul de înmatriculare
            license_plate_crop = image[y:y+h, x:x+w]
            
            # Convertim imaginea cropată în format acceptat de Google Vision
            _, buffer = cv2.imencode('.jpg', license_plate_crop)
            content = buffer.tobytes()
            image_vision = vision.Image(content=content)
            
            # Detectăm textul din imaginea cu numărul de înmatriculare folosind Google Vision
            response = client.text_detection(image=image_vision)
            texts = response.text_annotations
            
            # Returnăm primul text detectat (presupunând că este numărul de înmatriculare)
            if texts:
                detected_text = texts[0].description
                print(f"Detected text: {detected_text}")
                return extract_license_plate(detected_text)

    # Dacă nu am detectat niciun număr de înmatriculare, returnăm un mesaj corespunzător
    return "No license plate detected"

