# C.A.R.A. – Captura y Análisis de Rasgos y Ánimo 

**C.A.R.A.** es un sistema de inteligencia artificial que analiza las emociones humanas en tiempo real mediante reconocimiento facial y permite mantener una conversación contextual con el usuario según su estado de ánimo.

#  Tecnologías utilizadas
###  Backend (Python)
- DeepFace – Para analizar emociones faciales.

- OpenCV – Detección facial y procesamiento de imagen.

- gTTS – Síntesis de voz.

- websockets – Comunicación cliente-servidor.

- LangChain + Ollama – LLM local.(Requiere que hayas instalado y ejecutado Ollama antes)

###  Frontend (Godot)
Interfaz construida con Godot Engine.

Visualiza el estado del usuario según las emociones detectadas.

Comunicación vía WebSocket con el backend para recibir respuestas de la IA.

#  ¿Cómo funciona?
El backend escanea rostros usando la cámara.

Analiza la emoción dominante usando DeepFace.

La emoción se combina con el mensaje del usuario para generar una respuesta empática usando una IA previamente descargada con Ollama.

La respuesta es sintetizada en voz y enviada al frontend.

La interfaz Godot muestra la respuesta de la IA

## APP Screenshot

![Godot](https://github.com/G-Lean/C.A.R.A/blob/main/screenshots/Godot_basic.jpg)

