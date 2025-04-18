extends Node
@onready var message = $message
var socket = WebSocketPeer.new()#Creamos el sockete del Websocket
var url = "ws://localhost:5500"#Definimos la url del puerto 5500

signal msg_send
signal msg_received(msg:String,emotion:String,audio_path:String)
func _ready() -> void:
	var try_connect = socket.connect_to_url(url)#Intentamos conectarmos
	if try_connect != OK:
		set_process(false)#Desabilita el process en caso de no poder conectarse
		print("connection failed")
	else:
		print("connection success")

func _process(_delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var result = "Message from server: " + str(data_received())
			msg_received.emit(result.get_slice("++",0),result.get_slice("++",2),result.get_slice("++",1))
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) 

func data_received():
	if socket.get_available_packet_count() < 1:
		return null
	var packet = socket.get_packet()
	if socket.was_string_packet():
		return packet.get_string_from_utf8()
	return bytes_to_var(packet)

func send(msg:String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		msg_send.emit()
		return socket.send_text(msg)
	else:
		$Debug.text = "servidor desconectado"


func _on_button_pressed() -> void:
	if message.text != "":
		send(message.text)
		$AudioStreamPlayer.stop()
		$Emocion.text= "Emoción actual: "
	else:
		$Debug.text = "El mensaje esta vacio"
