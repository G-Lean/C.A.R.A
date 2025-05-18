@tool
extends Node
@onready var balloon_text:PackedScene = preload("res://Scenes/chat/balloon_text.tscn")
@onready var balloon_wait:PackedScene = preload("res://Scenes/chat/wait.tscn")

@onready var main_message:Node2D = $"../main_message"
@onready var balloon_container:VBoxContainer = $"../main_message/ScrollContainer/VBoxContainer"

@onready var menu:Node2D = $"../menu"
@onready var Debug:TextEdit = $"../menu/Debug"
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
	if not on_menu:
		_generate_left_msg(msg)

func _on_server_msg_received(msg: String, emotion: String) -> void:
	$"../menu/start_bot".disabled = false
	if on_menu:
		Debug.text = ""
		match msg:
			"[ERROR Chatbot]":
				Debug.text = "[ERROR] No se pudo iniciar el bot"
			"[Server disconnect]":
				Debug.text = '[ERROR] El "HELPER" no esta ejecutandose'
			"[Bot initialized]":
				Debug.text = 'BOT iniciado'
				on_menu = false
		Debug.text += ("\n"+msg).trim_prefix("\n")
		return
	$"../main_message/message_bar"._focus()
	last_emotion = emotion
	_generate_right_msg(msg)
	

func _generate_left_msg(msg:String) -> void:
	var balloon_Scene:Control = balloon_text.instantiate()
	var wait_Scene:Control = balloon_wait.instantiate()
	balloon_Scene.user = menu._get_value("Parameters","User_name")
	balloon_Scene.text = msg
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
