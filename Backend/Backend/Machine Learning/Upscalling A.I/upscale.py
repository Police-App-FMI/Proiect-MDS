import cv2
from cv2 import dnn_superres

# Creareăm obiect DnnSuperResImpl
sr = dnn_superres.DnnSuperResImpl.create()

# Deschiderea imaginii
image = cv2.imread('./Machine Learning/Upscalling A.I/picture.jpg')
# Deschiderea videoclipului
cap = cv2.VideoCapture('./Machine Learning/Upscalling A.I/video.mp4')
if image is not None:
    # Încărcăm modelul FSRCNN pre-antrenat
    sr.readModel('./Machine Learning/Upscalling A.I/FSRCNN_x4.pb')
    # Setăm modelul și scale-ul
    sr.setModel('fsrcnn', 4)
    # Executăm algoritmul de upscalling
    upsacled = sr.upsample(image)
    # Salvăm imaginea în memorie
    cv2.imwrite('./Machine Learning/Upscalling A.I/picture_upscaled.jpg', upsacled)
    print("True")
elif cap.isOpened():
    # Încărcăm modelul ESPC pre-antrenat (Deoarece este mai rapid ca EDSR)
    sr.readModel('./Machine Learning/Upscalling A.I/ESPCN_x4.pb')
    # Setăm modelul și scale-ul
    sr.setModel('espcn', 4)
    # Obținem primul cadru
    ret, frame = cap.read()
    # Upscaling-ul primului cadru
    result = sr.upsample(frame)
    # Obținem dimensiunile cadrului upscalat
    height, width, _ = result.shape
    # Obținem codul de patru caractere pentru codec
    fourcc = cv2.VideoWriter.fourcc(*'mp4v')
    # Creăm un obiect VideoWriter cu dimensiunile cadrului upscalat şi pe 24 frame rate (setat implicit de noi)
    out = cv2.VideoWriter('./Machine Learning/Upscalling A.I/video_upscaled.mp4', fourcc, 24.0, (width, height))
    # Scriem primul cadru upscalat în fișierul de ieșire
    out.write(result)
    # Exragem nr. total de frame-uri
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    for i in range(total_frames):
        ret, frame = cap.read()
        if ret:
            # Upscaling-ul cadrului
            result = sr.upsample(frame)
            # Scriem cadrul upscalat în fișierul de ieșire
            out.write(result)
    # Închidem fișierele
    cap.release()
    out.release()
    print("True")
else:
    print("False")