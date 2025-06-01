extends Control


@export var user:String = "~User"
var user_color:Color = Color.WHITE
@export var text :String = ""
@export var right :bool = false
@export var emotion:String = "unknown"

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var user_name:Label = get_node("balloon_container/name")
	var main_text:TextEdit = get_node("balloon_container/main_text")
	user_name.modulate = user_color
	user_name.text = user
	user_name.position.x = main_text.position.x
	if right:
		user_name.modulate = Color(0.0, 1.0, 1.0)
		$balloon_container.scale.x = -1
		user_name.scale.x = -1
		user_name.position.x = main_text.position.x+50
		main_text.is_right = true
		main_text.emotion = emotion
	main_text.text = text
	main_text._setup()
	custom_minimum_size.y = main_text.size.y+user_name.size.y
