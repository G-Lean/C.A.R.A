import asyncio
import websockets
from websockets.exceptions import ConnectionClosedError, WebSocketException
import re
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
                    data = dict(re.findall(r"\[(\w+)\](.*?)(?=\[\w+\]|$)", msg))

                    if "API_KEY" in data and "MODEL" in data:
                        await asyncio.to_thread(self.Chatbot.set_model, data["API_KEY"], data["MODEL"])
                        await ws.send("[Bot model loaded]")

                    elif "MAX_HISTORY" in data or "USER_NAME" in data or "CLEAR_HISTORY" in msg:
                        try:
                            if "MAX_HISTORY" in data:
                                self.Max_history = int(data["MAX_HISTORY"])
                            if "USER_NAME" in data:
                                self.User_name = data["USER_NAME"]
                            if "CLEAR_HISTORY" in msg:
                                await asyncio.to_thread(self.Chatbot.clear_history)

                            await ws.send("[Update parameters]")
                        except ValueError:
                            await ws.send("[ERROR] cannot update parameters")

                    else:
                        try_connect = await asyncio.to_thread(self.Chatbot.set_parameters, msg[15:], self.Max_history)
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