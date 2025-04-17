from langchain_ollama import OllamaLLM
from gtts import gTTS
import time

model = OllamaLLM(model = "llama3.2")
language = "es-ES"

def message(msg: str):
    try:
        result = model.invoke(input=msg)
        text_to_audio(str(result))
    except Exception as e:
        print(f"[ERROR Chatbot] No se pudo generar respuesta: {e}")


def text_to_audio(text:str):
    speech = gTTS(text = text,lang=language,slow=False)
    path_file = "../Sarah/audio/result.mp3"
    speech.save(path_file)
    #os.system(f"start {path_file}")
    print(f"Llama3.2: {text}")
    return True

