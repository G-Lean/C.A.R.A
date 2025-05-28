extends Node2D
var config = ConfigFile.new()
var FolderFilePath = OS.get_config_dir()+"/CARA"
var SaveFilePath:String = OS.get_config_dir()+"/CARA/model.ini"

var ApiKeys = {
"Mistral Small 3.1":"",
"ChatGPT-4o":"",
"DeepSeek R1":"",
}
var model_in_use = "Mistral Small 3.1"
func _ready() -> void:
	_create_file()
	config.load(SaveFilePath)
	ApiKeys["Mistral Small 3.1"] = _get_value("Mistral Small 3.1","ApiKey")
	ApiKeys["ChatGPT-4o"] = _get_value("ChatGPT-4o","ApiKey")
	ApiKeys["DeepSeek R1"] = _get_value("DeepSeek R1","ApiKey")
	%OptionButton.select(_get_value("Parameters","Last_Selected"))
	model_in_use = %OptionButton.get_item_text(%OptionButton.selected)
	print(model_in_use)
	print(ApiKeys)

func _create_file() -> void:
	if not FileAccess.file_exists(SaveFilePath):
		DirAccess.make_dir_absolute(FolderFilePath)
		config.set_value("Mistral Small 3.1","ApiKey","")
		config.set_value("Mistral Small 3.1","Dir","mistralai/mistral-small-3.1-24b-instruct:free")
		config.set_value("ChatGPT-4o","ApiKey","")
		config.set_value("ChatGPT-4o","Dir","openai/gpt-4.1")
		config.set_value("DeepSeek R1","ApiKey","")
		config.set_value("DeepSeek R1","Dir","deepseek/deepseek-r1")
		config.set_value("Parameters","Last_Selected",0)
		config.set_value("Parameters","User_name","User")
		config.set_value("Parameters","User_color",Color.WHITE)
		config.set_value("Parameters","Language","es-ES")
		config.set_value("Parameters","Max_history",30)
		config.save(SaveFilePath)
		print("Make model.ini")

func _set_value(Section,Key,Value) -> void:
	_create_file()
	config.set_value(Section,Key,Value)
	config.save(SaveFilePath)

func _get_value(Section,Key):
	return config.get_value(Section,Key)

func _on_option_button_item_selected(index: int) -> void:
	var model = %OptionButton.get_item_text(index)
	model_in_use = model
	_set_value("Parameters","Last_Selected",index)

func _on_set_api_pressed() -> void:
	$Model_selector/HBoxContainer/API.show()
	$Model_selector/HBoxContainer/Accept.show()
	$Model_selector/HBoxContainer/Deny.show()
	$Model_selector/HBoxContainer/Set_Api.hide()

func _on_accept_pressed() -> void:
	var model = %OptionButton.get_item_text(%OptionButton.selected)
	var key = $Model_selector/HBoxContainer/API.text
	ApiKeys[model] = key
	_set_value(model,"ApiKey",key)
	$Model_selector/HBoxContainer/Deny.emit_signal("pressed")
	
func _on_deny_pressed() -> void:
	$Model_selector/HBoxContainer/API.hide()
	$Model_selector/HBoxContainer/Accept.hide()
	$Model_selector/HBoxContainer/Deny.hide()
	$Model_selector/HBoxContainer/Set_Api.show()
	$Model_selector/HBoxContainer/API.text = ""
	
func _on_git_link_pressed() -> void:
	OS.shell_open("https://github.com/G-Lean/C.A.R.A")
func _on_api_link_pressed() -> void:
	OS.shell_open( "https://openrouter.ai/")
