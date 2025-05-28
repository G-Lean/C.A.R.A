from openai import OpenAI

class Chatbot():
    def __init__(self):
        self.api_key:str = ""
        self.conversation_history = [] #Aqui guardaremos la memoria del bot
        self.MAX_HISTORY:int = 20 # solo guarda los últimos mensajes para evitar sobrecargar el bot
        self.instructions:str = ""
        self.client = None#Variable global del cliente
        self.model:str = "mistralai/mistral-small-3.1-24b-instruct:free"
        
    def set_parameters(self,instructions, max_history: int = 20) -> str:
        self.instructions = instructions
        self.MAX_HISTORY = max_history
        return self.connect()
    
    def set_model(self,api_key,model = "mistralai/mistral-small-3.1-24b-instruct:free") -> None:
        self.api_key = api_key
        self.model = model

    def connect(self) -> str:
        try:
            self.client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=self.api_key,
            )
            return "bot connection successful"
        except Exception as e:
            return f"[ERROR Chatbot] could not connect to the bot: {e}"

    def message(self,msg: str) -> str:
        try:
            #Si el historial de la conversacion pasa el maximo permitido le borramos solo hasta el limite
            if len(self.conversation_history) >= self.MAX_HISTORY:
                self.conversation_history = self.conversation_history[-self.MAX_HISTORY // 2:]
            # Añade el mensaje del usuario al historial de mensajes
            self.conversation_history.append({"role": "user", "content": msg})

            messages = [{"role": "system", "content": self.instructions}] + self.conversation_history

            response = self.client.chat.completions.create(
                model= self.model,
                messages=messages
            )

            reply = response.choices[0].message.content

            # Añade la respuesta del bot al historial de mensajes
            self.conversation_history.append({"role": "assistant", "content": reply})

            return reply

        except Exception as e:
            print(e)
            return f"[ERROR Chatbot] the response could not be generated: {e}"

    def clear_history(self) -> None:
        #Limpia el historial del bot
        self.conversation_history = []
        print("History Cleared")