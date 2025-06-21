extends Control
@onready var text_bar:TextEdit = $VBoxContainer/TextEdit
@onready var send_button:Button = $Send

@export var max_letters :int = 300
@export var disabled = false
signal send_message(msg:String)

const  base_min_height: float = 73.0
const  expanded_min_height: float = 224.0
var is_expanded: bool = false

var recording = false
func _on_send_pressed() -> void:
	$Record.save_audio()
	$Record.hide_audio()
	if not text_bar.text.replace("\n","").is_empty():
		send_message.emit("[message]"+text_bar.text.lstrip("\n").rstrip("\n"))
		text_bar.text = ""
		send_button.disabled = true

func _physics_process(_delta: float) -> void:
	var letters = len(text_bar.text)
	$max_letters.text = str(letters)+"/"+str(max_letters)
	
	if not send_button.disabled:
		if not Input.is_action_pressed("ctrl"):
			if Input.is_action_just_pressed("send"):
				text_bar.text = text_bar.text.trim_suffix("\n")
				send_button.emit_signal("pressed")

	if not disabled:
		if not text_bar.has_theme_color_override("font_color"):
			if letters > max_letters:
				text_bar.add_theme_color_override("font_color",Color(1,1,1,.5))
				send_button.disabled = true
		elif letters <= max_letters:
				text_bar.remove_theme_color_override("font_color")
				send_button.disabled = false
		send_button.disabled = text_bar.text.replace("\n","").is_empty() if (letters <= max_letters) else true
	else:
		send_button.disabled = true
	
	if recording: send_button.disabled = true
		
	var visible_lines = _get_visible_line_count()
	if visible_lines >= 7 && !is_expanded:
		is_expanded = true
		text_bar.custom_minimum_size.y = expanded_min_height
		text_bar.scroll_fit_content_height = false
	elif visible_lines < 7 && is_expanded:
		is_expanded = false
		text_bar.custom_minimum_size.y = base_min_height
		text_bar.scroll_fit_content_height = true

func _enable_button():
	disabled = true

func _focus():
	text_bar.grab_focus()

func _get_visible_line_count() -> int:
		var visible_lines = 0
		for i in range(text_bar.get_line_count()):
			visible_lines += text_bar.get_line_wrap_count(i) + 1
		return visible_lines

func _on_record_record(is_recording: bool) -> void:
	recording = is_recording
