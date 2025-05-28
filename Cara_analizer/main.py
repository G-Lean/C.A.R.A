import asyncio
import websockets
from websockets.exceptions import ConnectionClosedError, WebSocketException
import emotions
import chatbot

class WebSocketServer:
    def __init__(self):
        self.Chatbot:chatbot = chatbot.Chatbot()#instanciamos la clase Chatbot
        self.User_name:str = "User"
        self.Max_history:int = 30

    async def start_emotion_scanner(self):
        await asyncio.to_thread(emotions.scan)

    # WebSocket server handler
    async def server(self,ws, path):
        print("CaraApp connected")
        await ws.send("[Helper Connected]")
        try:
            async for msg in ws:
                if msg.startswith("[message]"):
                        emotions.scan()
                        emotion = emotions.get_emotion()
                        if emotion != "unknown":
                            prompt = f"Estás viendo a una persona con nombre u apodo '{self.User_name}' con el estado de ánimo '{emotion}'. Esta persona te dice: {msg}"
                            result = await asyncio.to_thread(self.Chatbot.message, prompt)
                            await ws.send(str(result) + f"++{emotion}")
                            print("Send response")
                        else:
                            await ws.send("Rostro no detectado" + f"++{emotion}")
                else:

                    if msg.startswith("[API_KEY]"):#Si el mensaje no posee la clave [API_KEY]
                        api_ = msg.find("[API_KEY]")+len("[API_KEY]")
                        #Se busca la ubicacion de la clave y se suma la clave para buscarla desde esa ubicacion
                        bot_name = msg.find("[MODEL]")+len("[MODEL]")
                        await asyncio.to_thread(self.Chatbot.set_model, msg[api_:bot_name-len("[MODEL]")],msg[bot_name:])
                        await ws.send("[Bot model loaded]")
                    elif msg.startswith("[SET_PARAMETERS]"):
                        try:
                            max_start = msg.find("[MAX_HISTORY]") + len("[MAX_HISTORY]")
                            user_start = msg.find("[USER_NAME]") + len("[USER_NAME]")
                            
                            self.Max_history = int(msg[max_start:user_start - len("[USER_NAME]")])
                            self.User_name = msg[user_start:]
                            
                            # Limpiar historial si se solicita
                            if "[CLEAR_HISTORY]" in msg:
                                await asyncio.to_thread(self.Chatbot.clear_history)
                            
                            await ws.send("[Update parameters]")
                        except ValueError:
                            await ws.send("[ERROR] MAX_HISTORY debe ser un número (ej: 20)")
                    else:
                        try_connect = await asyncio.to_thread(self.Chatbot.set_parameters, msg[15:],self.Max_history)
                        await ws.send("[Bot initialized]")
                        print(try_connect)

        except (ConnectionClosedError, WebSocketException, ConnectionResetError) as e:
            print(f"[Error] Conexión cerrada inesperadamente: {e}")
        except Exception as e:
            print(f"[Error inesperado]: {e}")
        finally:
            print("Closing connection with client.")

    
    # Main del servidor
    async def main(self):
        print("Starting server...")
        asyncio.create_task(self.start_emotion_scanner())
        async with websockets.serve(self.server, "localhost", 5501):
            print("Server started on ws://localhost:5501")
            await asyncio.Future()

if __name__ == "__main__":
    server = WebSocketServer()
    asyncio.run(server.main())