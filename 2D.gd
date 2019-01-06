extends Node

onready var player = get_node("Player/Body")
onready var platform = get_node("Level/Platform")

func _on_Area2D_body_entered(body):
	if body.get_name()=="Body":
		platform.level+=1
		find_node("GUI").level.text = "LV"+String(platform.level)
		player.position = Vector2(0,0)
		player.projs = 0
		platform.Reset()
		for n in platform.get_parent().get_children():
			if n!=platform:
				n.queue_free()
		for p in get_node("Projectiles").get_children():
			p.queue_free()
