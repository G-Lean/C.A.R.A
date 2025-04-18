extends Node
@onready var debug:RichTextLabel = $"../Debug"
@onready var animation:AnimationPlayer = $"../AnimationPlayer"
@onready var audio:AudioStreamPlayer = $"../AudioStreamPlayer"
@onready var send_button:Button = $"../Button"

@onready var wait_time:Timer = Timer.new()

var path_audio

func _ready() -> void:
	wait_time.one_shot = true
	wait_time.wait_time = 3
	wait_time.timeout.connect(_on_timeout)
	add_child(wait_time)
	debug.text = ""

func _on_server_msg_send() -> void:
	animation.play("wait")
	send_button.disabled = true


func _on_timeout() -> void:
		audio.stream = path_audio
		audio.playing = true 

func _on_server_msg_received(msg: String, emotion: String, audio_path: String) -> void:
	animation.stop()
	debug.text = msg
	$"../Emocion".text = "Emoción actual: " + emotion
	send_button.disabled = false
	if emotion != "unknown":
		path_audio = load_mp3(audio_path)
		wait_time.start()


func load_mp3(path):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var sound = AudioStreamMP3.new()
		sound.data = file.get_buffer(file.get_length())
		return sound
