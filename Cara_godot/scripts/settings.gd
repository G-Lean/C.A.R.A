extends ColorRect


@onready var animation:AnimationPlayer = $settings_animation
@onready var menu = $"../menu"

@onready var User_UI:TextEdit = $VBoxContainer/User_name/User_name
@onready var lang_UI:OptionButton =$VBoxContainer/Lang/OptionButton

var open:bool = false

var user_name:String
var user_color:Color

var lang:String

var max_history:int
var clear_history:bool

func _ready() -> void:
	call_deferred("UpdateLangUI")

func setup() -> void:
	user_name = _get_parameters("User_name")
	user_color = _get_parameters("User_color")
	max_history = _get_parameters("Max_history")
	
	User_UI.text = user_name
	lang_UI.selected = 0 if lang == "es" else 1
	$VBoxContainer/Max_history/ProgressBar.value = max_history
	
	%Red.value = remap(user_color.r,0,1,0,255)
	%Green.value = remap(user_color.g,0,1,0,255)
	%Blue.value = remap(user_color.b,0,1,0,255)

func UpdateLangUI():
	lang = _get_parameters("Language")
	TranslationServer.set_locale(lang if lang == "es" else "en")
	
	$"../menu/Model_selector/HBoxContainer/Set_Api".text = tr("SetApi")
	$VBoxContainer/User_name.text = tr("User_name")
	$VBoxContainer/User_color.text = tr("User_color")
	$VBoxContainer/Lang.text = tr("Lang")
	$VBoxContainer/Max_history.text = tr("History")+":"
	$VBoxContainer/Clear_history.text = tr("Clear")
	$VBoxContainer/Apply.text = tr("Apply_Changes")
	

func _on_progress_bar_value_changed(value: float) -> void:
	$VBoxContainer/Max_history/ProgressBar/value.text = str(int(value))


func _on_red_value_changed(value: float) -> void:
	$VBoxContainer/User_color/VBoxContainer/Red/value.text = str(int(value))
func _on_green_value_changed(value: float) -> void:
	$VBoxContainer/User_color/VBoxContainer/Green/value.text = str(int(value))
func _on_blue_value_changed(value: float) -> void:
	$VBoxContainer/User_color/VBoxContainer/Blue/value.text = str(int(value))
func _physics_process(_delta: float) -> void:
	var R = remap(%Red.value,0,255,0,1)
	var G = remap(%Green.value,0,255,0,1)
	var B = remap(%Blue.value,0,255,0,1)
	$VBoxContainer/User_name/User_name.modulate = Color(R,G,B)


func _on_settings_button_pressed() -> void:
	if not open:
		setup()
		animation.play("config_open")
		open = true
		set_process(true)
	else:
		animation.play("config_close")
		open = false
		set_process(false)


func _on_apply_pressed() -> void:
	lang = lang_UI.get_item_text(lang_UI.selected)
	max_history = int($VBoxContainer/Max_history/ProgressBar.value)
	user_name = (User_UI.text.left(14)).replace("\n"," ")
	user_color = $VBoxContainer/User_name/User_name.modulate
	clear_history = $VBoxContainer/Clear_history.button_pressed
	
	_set_parameters("User_name",user_name)
	_set_parameters("User_color",user_color)
	_set_parameters("Language",lang)
	_set_parameters("Max_history",max_history)
	
	send_parameters()
	 
	$settings/eje/settings_button.emit_signal("pressed")
	$VBoxContainer/Apply.disabled = true
	
func send_parameters():
	setup()
	var msg = '[SET_PARAMETERS]'+'[MAX_HISTORY]'+str(max_history)+'[USER_NAME]'+str(user_name)
	if clear_history:
		msg+= "[CLEAR_HISTORY]"
		$VBoxContainer/Clear_history.button_pressed = false
	print("new parameters: "+msg)
	owner._send(msg)

func _get_parameters(key:String):
	return menu._get_value("Parameters",key)

func _set_parameters(key,value):
	return menu._set_value("Parameters",key,value)

func _on_settings_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "config_close":
		UpdateLangUI()
		$VBoxContainer/Apply.disabled = false
