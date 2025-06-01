@tool
extends Node
@onready var balloon_text:PackedScene = preload("res://Scenes/chat/balloon_text.tscn")
@onready var balloon_wait:PackedScene = preload("res://Scenes/chat/wait.tscn")

@onready var main_message:Node2D = $"../main_message"
@onready var balloon_container:VBoxContainer = $"../main_message/ScrollContainer/VBoxContainer"
@onready var message_bar = $"../main_message/message_bar"

@onready var menu:Node2D = $"../menu"
@onready var Debug:RichTextLabel = $"../menu/Debug/main_text"

@onready var scroll_container = $"../main_message/ScrollContainer"

var last_emotion:String

@export var on_menu:bool = true:
	set = _change_Scene
@export var bg_color:Color:
	set = _change_bg_color
	
var mouse_in = false
var link = ""

func _change_bg_color(value:Color) -> void:
	if has_node(".."):
		var background = $"../Modern_UI/Background"
		background.color = value
		bg_color = value

func _change_Scene(value):
	if has_node(".."):
		$"../menu".visible = value
		$"../main_message".visible = not value
		on_menu = value

func _on_server_msg_send(msg: String) -> void:
	if msg.left(16) == "[SET_PARAMETERS]": return
	if not on_menu:
		message_bar.disabled = true
		_generate_left_msg(msg)

func _on_server_msg_received(msg: String, emotion: String) -> void:
	if msg == "[Update parameters]": 
		print("Parameters updated")
		return
	var message:String = msg
	message_bar.disabled = false
	if msg.find("[ERROR Chatbot]") != -1 || msg.find("[Server disconnect]") != -1 || msg.find("[Bot initialized]") != -1:
		if not on_menu:
			on_menu = true
			print(msg)
			_generate_right_msg("")
	if on_menu:
		Debug.text = ""
		match msg:
			"[ERROR Chatbot]":
				Debug.text = '[ERROR] No se pudo iniciar el bot\n'
			"[Server disconnect]":
				Debug.text = '[ERROR] El "HELPER" no esta ejecutandose\n'
			"[Bot initialized]":
				Debug.text = 'BOT iniciado\n'
				on_menu = false
			"[Helper Connected]":
				var wait = Timer.new()
				wait.wait_time = 2
				wait.timeout.connect(WaitTimeOut)
				wait.one_shot = true
				add_child(wait)
				wait.start()
				
		Debug.text += (msg)
		if msg.length() > 50:
			Debug.text = ""
			var jump_line = 50
			var last_jump = 0
			var actual_letter:int = 0
			for letter in msg:
				if actual_letter > (jump_line + last_jump):
					Debug.text += "\n"
					last_jump += jump_line
				actual_letter += 1
				Debug.text += letter
		return
	$"../main_message/message_bar"._focus()
	last_emotion = emotion
	_generate_right_msg(message)
	

func _generate_left_msg(msg:String) -> void:
	var balloon_Scene:Control = balloon_text.instantiate()
	var wait_Scene:Control = balloon_wait.instantiate()
	balloon_Scene.user = menu._get_value("Parameters","User_name")
	balloon_Scene.user_color = menu._get_value("Parameters","User_color")
	balloon_Scene.text = msg.right(msg.length()-9)
	balloon_container.add_child(balloon_Scene)
	balloon_container.add_child(wait_Scene)

func _generate_right_msg(msg:String) -> void:
	var balloon_Scene:Control = balloon_text.instantiate()
	balloon_Scene.text = msg
	balloon_Scene.right = true
	balloon_Scene.emotion = last_emotion
	balloon_Scene.user = "CARA"
	balloon_container.add_child(balloon_Scene)
	var wait_exist = balloon_container.has_node("wait")
	if wait_exist:
		var wait:ColorRect =  balloon_container.get_node("wait")
		wait.queue_free()


func _on_v_box_container_sort_children() -> void:
	scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)
	
func WaitTimeOut():
	$"../menu/start_bot".disabled = false
	$"../side_settings".send_parameters()
