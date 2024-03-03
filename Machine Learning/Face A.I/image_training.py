import numpy as np
import pandas as pd
import os
import cv2
import gc

from tqdm import tqdm
from sklearn.model_selection import train_test_split
from keras import layers, callbacks, utils, applications, optimizers
from keras.models import Sequential, Model, load_model
import tensorflow as tf

files = os.listdir("C:\\Users\\baciu\\Documents\\GitHub\\Proiect-MDS\\Machine Learning\\Face A.I\\dataset")

images = []
label = []
path = "C:\\Users\\baciu\\Documents\\GitHub\\Proiect-MDS\\Machine Learning\\Face A.I\\dataset\\"

for i in range(len(files)):
    files_sub = os.listdir(path + files[i])
    for j in tqdm(range(len(files_sub))):
        try:
            image = cv2.imread(path + files[i] + "\\" + files_sub[j])
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            image = cv2.resize(image, (96, 96))
            images.append(image)
            label.append(i)
        except:
            pass

gc.collect()

images = np.array(images) / 255.0
label = np.array(label)

X_train, X_test, Y_train, Y_test = train_test_split(images, label, test_size=0.15)

model = Sequential()
pretrained_model = tf.keras.applications.EfficientNetB0(input_shape = (96, 96, 3), include_top = False,
                                                        weights = "imagenet")

model.add(pretrained_model)
model.add(layers.GlobalAveragePooling2D())

model.add(layers.Dropout(0.3))
model.add(layers.Dense(1))

model.summary()

model.compile(optimizer = "adam", loss="mean_squared_error", metrics=["mae"])

ckp_path = "trained_model/model"
model_checkpoint = tf.keras.callbacks.ModelCheckpoint(filepath = ckp_path, monitor = "val_mae", mode = "auto",
                                                      save_best_only = True, save_weights_only = True)

reduce_learning_rate = tf.keras.callbacks.ReduceLROnPlateau(factor = 0.9, monitor = "val_mae", mode = "auto",
                                                            cooldown = 0, patience = 5, verbose = 1, min_lr = 1e-6)

Epoch = 300
Batch_Size = 64
history = model.fit(X_train, Y_train, validation_data = (X_test, Y_test), batch_size = Batch_Size, epochs = Epoch, callbacks=[model_checkpoint, reduce_learning_rate])

model.load_weights(ckp_path)

converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)

prediction_val = model.predict(X_test, batch_size = 64)
print(model.score(X_test, Y_test))