import asyncio
import websockets
import emotions
from chatbot import message  # Asegúrate de que chatbot.py esté en el mismo directorio o el path correcto

# Ejecuta emotions.scan() en segundo plano
async def start_emotion_scanner():
    await asyncio.to_thread(emotions.scan)

# WebSocket server handler
async def server(ws, path):
    print("Client connected")
    async for msg in ws:
        print(f"msg from client: {msg}")
        emotion = emotions.get_emotion()
        print(f"Detected emotion: {emotion}")

        # Llama al chatbot con mensaje y emoción
        prompt = f"Eres una IA de reconocimiento de emociones. Estás viendo a una persona con el estado de ánimo '{emotion}'. Esta persona te dice: {msg}"
        await asyncio.to_thread(message, prompt)

        await ws.send(emotion if emotion else "No emotion detected")

# Main del servidor
async def main():
    print("Starting server...")

    # Lanzar el escáner en segundo plano
    asyncio.create_task(start_emotion_scanner())

    async with websockets.serve(server, "localhost", 5500):
            print("Server started on ws://localhost:5500")
            await asyncio.Future()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Detenido por el usuario con Ctrl+C.")
