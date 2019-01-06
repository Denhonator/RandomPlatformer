extends Node2D

var area
var vel = Vector2(0,0)
var damage = 0
var life = 3
var AI = false
var onScreen = false
var shooter = null

func _ready():
	area = find_node("Area")
	
func _process(delta):
	area.translate(vel*delta)
	if not onScreen:
		life-=delta
		if life<=0:
			queue_free()

func _on_area_entered(area):
	pass

func _on_body_entered(body):
	if body.has_method("GetHit"):
		if AI!=body.AI:
			body.GetHit(self)
		else:
			return
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	onScreen = false

func _on_VisibilityNotifier2D_screen_entered():
	onScreen = true
