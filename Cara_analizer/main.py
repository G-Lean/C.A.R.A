import asyncio
import websockets
from websockets.exceptions import ConnectionClosedError, WebSocketException
import emotions
import chatbot

is_initialized = False
Chatbot = chatbot.Chatbot()#instanciamos la clase Chatbot
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
                if msg.find("[Initial_promt]") != -1 and msg.find("[message]") != 0:
                    print("Bot is already initialized")
                    await ws.send("[Bot initialized]")
                else:
                    emotions.scan()
                    emotion = emotions.get_emotion()
                    if emotion != "unknown":
                        prompt = f"Estás viendo a una persona con el estado de ánimo '{emotion}'. Esta persona te dice: {msg}"
                        result = await asyncio.to_thread(Chatbot.message, prompt)
                        await ws.send(str(result) + f"++{emotion}")
                        print("Send response")
                    else:
                        await ws.send("Rostro no detectado" + f"++{emotion}")
            else:
                if msg.find("[API_KEY]") == -1:#Si el mensaje no posee la clave [API_KEY] y no se ha iniciado el bot
                    try_connect = await asyncio.to_thread(Chatbot.set_parameters, msg[15:])
                    await ws.send("[Bot initialized]")
                    print(try_connect)
                    is_initialized = True
                else:
                    api_ = msg.find("[API_KEY]")+len("[API_KEY]")
                    #Se busca la ubicacion de la clave y se suma la clave para buscarla desde esa ubicacion
                    bot_name = msg.find("[MODEL]")+len("[MODEL]")
                    await asyncio.to_thread(Chatbot.set_model, msg[api_:bot_name-len("[MODEL]")],msg[bot_name:])
                    await ws.send("[Bot model loaded]")

    except (ConnectionClosedError, WebSocketException, ConnectionResetError) as e:
        print(f"[Error] Conexión cerrada inesperadamente: {e}")
        is_initialized = False
    except Exception as e:
        print(f"[Error inesperado]: {e}")
        is_initialized = False
    finally:
        print("Closing connection with client.")
        is_initialized = False

# Main del servidor
async def main():
    print("Starting server...")
    asyncio.create_task(start_emotion_scanner())
    async with websockets.serve(server, "localhost", 5501):
        print("Server started on ws://localhost:5501")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
