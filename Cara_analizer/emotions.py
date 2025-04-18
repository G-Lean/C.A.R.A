import cv2
from deepface import DeepFace
import time

# Inicializar
face_cascade = cv2.CascadeClassifier("haarcascade/haarcascade_frontalface_default.xml")
font = cv2.FONT_HERSHEY_SIMPLEX
cap = cv2.VideoCapture(0)
color = (255, 255, 255)
actual_emotion: str = "unknown"

def scan():
    global actual_emotion
    last_analysis_time = 0
    analysis_interval = 5  # analizar cada 5 segundos

    ret, img = cap.read()
    if not ret:
        print("the camera cannot be accessed.")
        return

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.2, 5)

    # Si hay rostros detectados y ha pasado suficiente tiempo
    if len(faces) > 0 and time.time() - last_analysis_time > analysis_interval:
        try:
            analysis = DeepFace.analyze(img, actions=["emotion"], enforce_detection=False)
            emotion = analysis[0]["dominant_emotion"]
            actual_emotion = emotion
            last_analysis_time = time.time()
            print(f"Emotion detected: {emotion}")
        except Exception as e:
            print(f"Error in DeepFace: {e}")


def get_emotion():
    global actual_emotion
    new_emotion = actual_emotion
    actual_emotion = "unknown"
    return new_emotion

def close():
    print("closing emotions resource...")
    try:
        cap.release()
        cv2.destroyAllWindows()
    except:
        pass
scan()