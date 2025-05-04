@tool
extends Node
@onready var balloon_text:PackedScene = preload("res://Scenes/chat/balloon_text.tscn")

@onready var main_message:Node2D = $"../main_message"
@onready var balloon_container:VBoxContainer = $"../main_message/ScrollContainer/VBoxContainer"

@onready var menu:Node2D = $"../menu"
@onready var Debug:TextEdit = $"../menu/Debug"
var last_emotion:String

@export var on_menu:bool = true:
	set = _change_Scene
@export var bg_color:Color:
	set = _change_bg_color
func _ready() -> void:
	set_deferred("on_menu",true)#Se espera a que carguen los nodos


func _change_bg_color(value:Color):
	var background = $"../Modern_UI/Background"
	if background != null:
		background.color = value
	bg_color = value
func _change_Scene(value):
	$"../menu".visible = value
	$"../main_message".visible = not value
	on_menu = value

func _on_server_msg_send(msg: String) -> void:
	print("sent message from the client")
	if not on_menu:
		_generate_message(msg,false)
	

func _on_server_msg_received(msg: String, emotion: String) -> void:
	print("message received from the serve")
	$"../menu/start_bot".disabled = false
	if on_menu:
		match msg:
			"[ERROR Chatbot]":
				Debug.text = "[ERROR] No se pudo iniciar el bot"
				return
			"[Server disconnect]":
				Debug.text = '[ERROR] El "HELPER" no esta ejecutandose'
				return
			"[Bot initialized]":
				Debug.text = 'BOT iniciado'
				on_menu = false
				return
	$"../main_message/message_bar"._focus()
	last_emotion = emotion
	_generate_message(msg,true)

func _generate_message(msg:String,is_right:bool):
	var balloon_Scene:Control = balloon_text.instantiate()
	balloon_Scene.text = msg
	balloon_Scene.right = is_right
	if is_right:
		balloon_Scene.right = true
		balloon_Scene.emotion = last_emotion
	balloon_container.add_child(balloon_Scene)
