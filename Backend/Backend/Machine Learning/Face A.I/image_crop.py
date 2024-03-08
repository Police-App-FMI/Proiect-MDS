import re
import numpy as np
import cv2
import json
import time
import os

path = "cropped"
files = os.listdir("original")

count = 1
cascade = cv2.CascadeClassifier('haarcascade_AI.xml')

for i in range(len(files)):
    image = cv2.imread("original/" + files[i])
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = cascade.detectMultiScale(gray, 1.3, 4)
    for (x, y, w, h) in faces:
        color = image[y: y + h, x: x + w]
        cv2.imwrite(path+"/" + str(count) + ".jpg", color)
        count = count + 1