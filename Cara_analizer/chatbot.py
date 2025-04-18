from langchain_ollama import OllamaLLM
from gtts import gTTS
import os
import platform

bot: str = "tinyllama"  # Puedes cambiar por la IA que hayas descargado
model = OllamaLLM(model=bot)
language = "es-ES"  # Lenguaje del conversor de texto a audio

def message(msg: str):
    try:
        print("loading response")
        result = model.invoke(input=msg)
        return text_to_audio(str(result)) 
    except Exception as e:
        return f"[ERROR Chatbot] the response could not be generated: {e}"

def text_to_audio(text: str):
    documents_folder = get_documents_folder()
    cara_audio_folder = os.path.join(documents_folder, "Cara_audio")
    os.makedirs(cara_audio_folder, exist_ok=True)  # Crea la carpeta si no existe

    path_file = os.path.join(cara_audio_folder, "result.mp3")
    speech = gTTS(text=text, lang=language, slow=False)
    speech.save(path_file)

    print(f"{bot}: {text}")
    print(f"[INFO] Audio guardado en: {path_file}")
    return text + f"++{path_file}"

def get_documents_folder():
    user_os = platform.system()

    if user_os == "Windows":
        return os.path.join(os.environ["USERPROFILE"], "Documents")
    elif user_os in ["Linux", "Darwin"]:  # Darwin = macOS
        return os.path.join(os.environ["HOME"], "Documents")
    else:
        raise Exception("Sistema operativo no soportado")
