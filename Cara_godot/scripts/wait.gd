extends ColorRect
func _ready() -> void:
	hide()
	$AnimatedSprite2D.play("wait")

func _on_timer_timeout() -> void:
	show()
