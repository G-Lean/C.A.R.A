extends Node
@onready var debug:RichTextLabel = $"../Debug"
@onready var animation:AnimationPlayer = $"../AnimationPlayer"
@onready var audio:AudioStreamPlayer = $"../AudioStreamPlayer"
@onready var send_button:Button = $"../Button"

@onready var audio_path = "res://audio/result.mp3"

@onready var wait_time:Timer = Timer.new()


func _ready() -> void:
	wait_time.one_shot = true
	wait_time.wait_time = 3
	wait_time.timeout.connect(_on_timeout)
	add_child(wait_time)
	debug.text = ""

func _on_server_msg_send() -> void:
	animation.play("wait")
	send_button.disabled = true

func _on_server_msg_received(msg: String, emotion: String) -> void:
	animation.stop()
	debug.text = msg
	$"../Emocion".text = "Emoción actual: " + emotion
	send_button.disabled = false
	
	if emotion != "unknown":
		wait_time.start()
func _on_timeout() -> void:
		audio.stream = load(audio_path)
		audio.playing = true 
