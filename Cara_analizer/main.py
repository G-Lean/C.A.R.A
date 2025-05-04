import asyncio
import websockets
from websockets.exceptions import ConnectionClosedError, WebSocketException
import emotions
from chatbot import message

is_initialized = False

# Ejecuta emotions.scan() en segundo plano
async def start_emotion_scanner():
    await asyncio.to_thread(emotions.scan)

# WebSocket server handler
async def server(ws, path):
    global is_initialized
    print("CaraApp connected")
    try:
        async for msg in ws:
            if is_initialized:
                if  msg.find("[Initial_promt]") != -1 and msg.find("[message]") != 0:
                    print("Bot is already initialized")
                    await ws.send("[Bot initialized]")
                else:
                    emotions.scan()
                    emotion = emotions.get_emotion()
                    if emotion != "unknown":
                        prompt = f"Estás viendo a una persona con el estado de ánimo '{emotion}'. Esta persona te dice: {msg}"
                        result = await asyncio.to_thread(message, prompt)
                        await ws.send(str(result) + f"++{emotion}")
                        print("Send response")
                    else:
                        await ws.send("Rostro no detectado" + f"++{emotion}")
            else:
                initial_promt = await asyncio.to_thread(message, msg[14:])
                if initial_promt.find("[ERROR Chatbot]") == -1:
                    print("Bot initialized")
                    await ws.send("[Bot initialized]")
                    is_initialized = True
                else:
                    print(initial_promt)
                    await ws.send("[ERROR Chatbot]")
    except (ConnectionClosedError, WebSocketException, ConnectionResetError) as e:
        print(f"[Error] Conexión cerrada inesperadamente: {e}")
    except Exception as e:
        print(f"[Error inesperado]: {e}")
    finally:
        print("Closing connection with client.")

# Main del servidor
async def main():
    print("Starting server...")
    asyncio.create_task(start_emotion_scanner())
    async with websockets.serve(server, "localhost", 5501):
        print("Server started on ws://localhost:5501")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
