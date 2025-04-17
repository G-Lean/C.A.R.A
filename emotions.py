import cv2
from deepface import DeepFace
import time

# Inicializar
face_cascade = cv2.CascadeClassifier("haarcascade/haarcascade_frontalface_default.xml")
font = cv2.FONT_HERSHEY_SIMPLEX
cap = cv2.VideoCapture(0)
color = (255, 255, 255)
is_scan = True
actual_emotion: str = "Desconocido"

def scan():
    global actual_emotion, is_scan
    last_analysis_time = 0
    analysis_interval = 5  # analizar cada 5 segundos

    while True:
        ret, img = cap.read()
        if not ret:
            print("No se pudo acceder a la cámara.")
            break

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.2, 5)

        # Si hay rostros detectados y ha pasado suficiente tiempo
        if is_scan and len(faces) > 0 and time.time() - last_analysis_time > analysis_interval:
            try:
                analysis = DeepFace.analyze(img, actions=["emotion"], enforce_detection=False)
                emotion = analysis[0]["dominant_emotion"]
                actual_emotion = emotion
                last_analysis_time = time.time()
                print(f"Emoción detectada: {emotion}")
            except Exception as e:
                print(f"Error en DeepFace: {e}")

        # Dibujar rectángulos y texto si ya hay una emoción detectada
       # for (x, y, w, h) in faces:
        #    cv2.rectangle(img, (x, y), (x + w, y + h), color, 2)
         #   if actual_emotion:
          #      cv2.putText(img, f"Emocion: {actual_emotion}", (x, y + h + 25), font, 0.6, color, 2)

        #cv2.imshow("Detección de Emociones", img)

        # Salida 
        if is_scan:
            break

def get_emotion():
    global actual_emotion
    return actual_emotion

def close():
    global is_scan
    print("Cerrando recursos de emociones...")
    try:
        cap.release()
        cv2.destroyAllWindows()
        is_scan = False
    except:
        pass

