import os

def verifica_video(video):
    if os.path.isfile(video):
        print("Fisierul video exista in directorul curent.")
    else:
        print("Fisierul video nu a fost gasit in directorul curent.")

verifica_video('./Machine Learning/Face A.I/video.mp4')