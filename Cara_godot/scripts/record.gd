extends Control
@onready var micro_sprite :CompressedTexture2D= preload("res://Sprites/msg_bar icons/micro.png")
@onready var recording_sprite :CompressedTexture2D= preload("res://Sprites/msg_bar icons/recording.png")

@onready var record_button :Button= $Record
@onready var micro :AudioStreamPlayer= $microphone
@onready var preview :AudioStreamPlayer= $preview
@onready var time_slider: HSlider = $"../VBoxContainer/audio/HBoxContainer/time"
signal Record(is_recording:bool)

var effect :AudioEffectRecord
var recording :AudioStreamWAV
func _ready() -> void: 
	hide_audio()
	record_button.icon = micro_sprite
	effect = AudioServer.get_bus_effect(1,0)

func _physics_process(_delta: float) -> void:
	if preview.playing:
		time_slider.set_value_no_signal(preview.get_playback_position())
		_update_preview()

func _on_record_pressed() -> void:
	match record_button.icon:
		micro_sprite:
			effect.set_recording_active(true)
			record_button.icon = recording_sprite
			hide_audio()
			$preview.stream = null
			Record.emit(true)
		recording_sprite:
			if effect.is_recording_active():
				recording = effect.get_recording()
				print("Audio Duration: "+str(recording.get_length())+" seconds")
				effect.set_recording_active(false)
				Record.emit(false)
			record_button.icon = micro_sprite
			$"../VBoxContainer/audio".show()
			var data = recording.get_data()
			print("Audio Size: " +str(data.size()) + " bytes")
			preview.stream = recording
			time_slider.value = 0
			_update_preview()
			
func _update_preview() -> void:
	if preview.stream != null:
		#time_slider.max_value =("%.2f" % preview.stream.get_length()).to_float()
		time_slider.max_value = preview.stream.get_length()
		var duration :int= int(time_slider.value)
		if not preview.playing: 
			duration = int(time_slider.max_value)
		var minute :String= str(duration/60)
		var second :String= str(duration%60)

		if minute.to_int() < 10:
			minute = "0"+minute
		if second.to_int() < 10:
			second = "0"+second
		if time_slider.max_value/60 > 99:
			minute = "99"
			second = "59"
		$"../VBoxContainer/audio/HBoxContainer/Cancel/duration".text = minute +":"+ second

func _on_play_pressed() -> void:
	if not preview.playing:
		time_slider.step = time_slider.max_value*0.01
		preview.play(time_slider.value)

func _on_pause_pressed() -> void:
	preview.stop()
	_update_preview()

func _on_cancel_pressed() -> void:
	hide_audio()

func _on_time_value_changed(_value: float) -> void:
	preview.stop()

func save_audio(save_path:String = OS.get_config_dir()+"/CARA/Audio"):
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
		print("make audio path")
	if preview.stream != null:
		recording.save_to_wav(save_path+"/audio")
		print("Saved Audio File: " + save_path)

func hide_audio():
	$"../VBoxContainer/audio".hide()
	$preview.stream = null
