extends Node2D

onready var area = get_child(0)
onready var proj = preload("res://Projectile.tscn")
var vel = Vector2(0,0)
var damage = 0
var life = 1
var AI = false
var onScreen = false
var shooter = null
var shotRange
var explode = 0
var gravity = 0
var lastVel
var xp = true

func _process(delta):
	lastVel = vel*delta
	area.translate(lastVel)
	vel.y += gravity
	if not onScreen:
		life-=delta
		if life<=0:
			Destroy()
	if abs(area.position.x)+abs(area.position.y)>=shotRange:
		Destroy()

func _on_area_entered(area):
	pass

func _on_body_entered(body):
	if body.has_method("GetHit"):
		if AI!=body.AI:
			body.GetHit(self)
		else:
			return
	Destroy()
	
func Destroy():
	if explode:
		var angle = 0
		area.translate(-2*lastVel)
		for i in range(explode+1):
			var n = proj.instance()
			n.global_position = area.global_position
			n.damage = damage
			n.vel = Vector2(cos(angle),sin(angle))*100
			n.shotRange = shotRange/8
			n.shooter = shooter
			n.AI = AI
			n.modulate = modulate
			n.xp = false
			get_parent().add_child(n)
			angle += 2*PI/(explode+1)
	if shooter.get_ref():
		shooter.get_ref().projs-=1
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	onScreen = false

func _on_VisibilityNotifier2D_screen_entered():
	onScreen = true
