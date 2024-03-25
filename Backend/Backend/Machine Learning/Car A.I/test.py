import os

def verifica_video(video):
    if os.path.isfile(video):
        print("Fisierul jpg exista in directorul curent.")
    else:
        print("Fisierul jpg nu a fost gasit in directorul curent.")

verifica_video('./Machine Learning/Car A.I/picture.jpg')