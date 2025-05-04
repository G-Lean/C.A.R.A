from langchain_ollama import OllamaLLM

bot: str = "deepseek-r1"  
#Se escoje el modelo
model = OllamaLLM(model=bot,model_kwargs={"max_tokens": 200})
#Se limitan a 200 tokens maximos para las respuestas del bot

def message(msg: str) ->str:
    print("loading response")
    try:
        result = model.invoke(input=msg)
        return result
    except Exception as e:
        return f"[ERROR Chatbot] the response could not be generated: {e}"

