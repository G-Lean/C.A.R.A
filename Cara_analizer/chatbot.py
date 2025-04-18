from langchain_ollama import OllamaLLM
from gtts import gTTS
import time

bot:str = "tinyllama" #puedes cambiar por la IA que hayas descargado
model = OllamaLLM(model = bot)
language = "es-ES"#Lenguaje del conversor de texto a audio

def message(msg: str):
    try:
        print("loading response")
        result = model.invoke(input=msg)
        return text_to_audio(str(result))
    except Exception as e:
        return (f"[ERROR Chatbot] the response could not be generated: {e}")


def text_to_audio(text:str):
    speech = gTTS(text = text,lang=language,slow=False)
    path_file = "../Sarah/audio/result.mp3"
    speech.save(path_file)
    #os.system(f"start {path_file}")
    print(f"{bot}: {text}")
    return text
