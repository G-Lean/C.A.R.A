extends Control
@onready var control = $control

var promt_file:String = "res://promts/promt.txt"
var socket = WebSocketPeer.new()#Creamos el sockect del Websocket
var url = "ws://localhost:5501"#Definimos la url del puerto 5501

signal msg_send(msg:String)
signal msg_received(msg:String,emotion:String)
func _ready() -> void:
	var try_connect = socket.connect_to_url(url)#Intentamos conectarmos
	if try_connect != OK:
		set_process(false)#Desabilita el process en caso de no poder conectarse
		print("connection failed")
	else:
		set_process(true)
		print("connection successful")

func _process(_delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var result = str(data_received())
			msg_received.emit(result.get_slice("++",0),result.get_slice("++",1))
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		control.on_menu = true
		$menu/start_bot.disabled = false
		$menu/Debug/main_text.text = "WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1]
		set_process(false) 

func data_received():
	if socket.get_available_packet_count() < 1:
		return null
	var packet = socket.get_packet()
	if socket.was_string_packet():
		return packet.get_string_from_utf8()
	return bytes_to_var(packet)

func _send(msg:String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		msg_send.emit(msg)
		return socket.send_text(msg)
	else:
		print("Server disconnect")
		msg_received.emit("[Server disconnect]","unknown")
		return

func _on_message_bar_send_message(msg: String):
	return _send(msg)

func _on_start_bot_pressed() -> void:
	if control.on_menu:
		$menu/start_bot.disabled = true
		var state = socket.get_ready_state()
		if state == WebSocketPeer.STATE_CLOSED:#Reintenta conectarse al servidor
			_ready()
			print("WebSocket open")
		
		var model = $menu.model_in_use 
		var api = $menu.ApiKeys[model]
		model = $menu._get_value(model,"Dir")
		if api != "":
			_send("[API_KEY]"+api+"[MODEL]"+model)
		else:
			msg_received.emit("[API_IS_NULL]","unknown")
			return
		
		var File = FileAccess.open(promt_file,FileAccess.READ)#Accedemos al archivo del promt
		var File_content = File.get_as_text()#Obtenemos el contenido del archivo de texto
		_send("[Initial_promt]"+File_content)
