extends Control
@onready var text_bar:TextEdit = $TextEdit

@export var max_letters :int = 300
@export var disabled = false
signal send_message(msg:String)


func _on_button_pressed() -> void:
	if text_bar.text != "" :
		send_message.emit(text_bar.text)
		text_bar.text = ""
		$Button.disabled = true

func _physics_process(_delta: float) -> void:
	var letters = len(text_bar.text)
	$max_letters.text = str(letters)+"/"+str(max_letters)
	if not disabled:
		if not text_bar.has_theme_color_override("font_color"):
			if letters > max_letters:
				text_bar.add_theme_color_override("font_color",Color(1,1,1,.5))
				$Button.disabled = true
		elif letters <= max_letters:
				text_bar.remove_theme_color_override("font_color")
				$Button.disabled = false
		$Button.disabled = (text_bar.text == "") if (letters <= max_letters) else true
	else:
		$Button.disabled = true
func _enable_button():
	disabled = true

func _focus():
	text_bar.grab_focus()
