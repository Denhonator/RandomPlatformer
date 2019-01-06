extends CanvasLayer

var timer = 0

func _process(delta):
	timer+=delta
	get_child(3).text=String(timer).pad_decimals(0)