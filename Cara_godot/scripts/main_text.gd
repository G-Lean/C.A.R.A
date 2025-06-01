extends TextEdit
var is_right
var emotion :String
var new_text:String:
	set = _show_text#Se ejecuta _show_text cada que se modifica la variable

var max_characters :int= 20

func _show_text(new:String) -> void:
	var text_content = $text
	var hour:Label = $hour
	var time = Time.get_time_dict_from_system()#Obtenemos la hora local
	
	hour.text = ("%02d:%02d" % [time.hour, time.minute])

	text = new
	var new_size_x = get_minimum_size().x 
	text = ""
	size.x = new_size_x+30 if new_size_x < 800 else 830.0
	
	text_content.size.x = size.x-10
	text_content.text = new
	var new_size_y = text_content.get_minimum_size().y+10
	size.y = new_size_y
	
func _setup() -> void:
	var emotion_label:Label = get_node("emotion")
	emotion_label.text = emotion
	emotion = emotion.to_upper()
	var save_text = text#Se guarda el texto para poder reiniciar el tamaño
	text = ""
	custom_minimum_size = Vector2(70,40)#Tamaño base del texto
	new_text = save_text#Se agrega el texto nuevo
	if is_right:#Se ajusta para cuando esta de lado derecho
		emotion_label.scale.x = -1
		$hour.scale.x = -1
		$text.scale.x = -1
		$hour.position.x = 25
		$text.position.x = size.x-10
		emotion_label.position.x = 60

	match emotion:#Control del color de las emociones
		"UNKNOWN":
			emotion_label.visible = false
		"SAD":#Triste
			emotion_label.modulate = Color(0, 0, 1)#Azul
		"ANGRY":#Enojado
			emotion_label.modulate = Color(1, 0, 0)#Rojo
		"DISGUST":#Asco
			emotion_label.modulate = Color(0, 1, 0,0.5)#Verde
		"HAPPY":#Feliz
			emotion_label.modulate = Color(1, 1, 0,0.5)#Amarillo
		"SURPRISE":#Sorpresa
			emotion_label.modulate = Color(1, 0, 1)#Rosa
		"FEAR":#Miedo
			emotion_label.modulate = Color(0.6, 0, 0.7)#Morado
	emotion_label.text = tr(emotion)
	var traduction = tr("Detected")
	emotion_label.tooltip_text = traduction
	if traduction != emotion:#Comparamos si estaba en inlges o español
		emotion_label.position.x = 70#Movemos la posicion si estaba en español
	
