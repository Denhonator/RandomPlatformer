extends KinematicBody2D

var vel =			Vector2(0,0)
var maxms =			2
var ms =			2
var maxSpeed =		50
var acc =			10
var jumpSpeed =		-150
var maxJumpReserve = 170
var aniCounter =	0
var aniSpeed =		1.3
var shotSpeed =		3
var shotSize =		1
var damage =		1
var health =		10
var shotAni =		0
var shotCooldown =	0.3
var shootDir =		0
var airCounter =	0
var xp =			0
var xpReward =		1
var stunDur =		0.5
var iframeDur =		1
var hitCounter =	5
var jumpReserve
var sprite
var projectileParent
var projectile
var shotSpawn = []
var shotCounter
var action = {"left":false,"right":false,"up":false,"down":false,"jump":false,"attack":false}
var rays = {}
var col
var gui

export(bool) var AI

enum Ani{
	IDLE = 0
	DUCK = 1
	SHOOT= 2
	RUN1 = 3
	RUN2 = 4
	UP   = 5
	DOWN = 6
	}

func _ready():
	jumpReserve = maxJumpReserve
	shotCounter = shotCooldown
	sprite = find_node("Sprite")
	projectile = preload("res://Projectile.tscn")
	projectileParent = get_node("/root/Main/Projectiles")
	col = find_node("CollisionShape2D")
	var shots = find_node("Shots")
	shotSpawn.append(shots.find_node("ShotRU"))
	shotSpawn.append(shots.find_node("ShotR"))
	shotSpawn.append(shots.find_node("ShotRD"))
	shotSpawn.append(shots.find_node("ShotLU"))
	shotSpawn.append(shots.find_node("ShotL"))
	shotSpawn.append(shots.find_node("ShotLD"))
	if AI:
		modulate = Color(0.4,0,0)
		for r in find_node("Rays").get_children():
			rays[r.get_name()]=r
		action["attack"] = true
		action["right"] = true
		rays["rightGround"].enabled = true
		rays["rightWall"].enabled = true
	else:
		gui = get_node("/root/Main/GUI")
	
func GetInput():
	if not AI:
		for key in action.keys():
			action[key] = Input.is_action_pressed(key)
	else:
		var ac = "right" if action["right"] else "left"
		if (action[ac] and not rays[ac+"Ground"].is_colliding() or rays[ac+"Wall"].is_colliding()):
			action["right"] = !action["right"]
			action["left"] = !action["left"]
			for key in rays.keys():
				rays[key].enabled = !rays[key].enabled
		
func _process(delta):
	if hitCounter < 10:
		hitCounter+=delta
		if hitCounter < iframeDur:
			visible = int(hitCounter*10)%2==0
		else:
			visible = true
	if hitCounter>stunDur:
		GetInput()
		if action["left"]:
			vel.x = -maxSpeed
		elif action["right"]:
			vel.x = maxSpeed
		else:
			vel.x = 0
			
		if action["up"]:
			shootDir = -1
		elif action["down"]:
			shootDir = 1
		else:
			shootDir = 0
		
	if shootDir == 1 and col.shape.extents.y==29:
		col.move_local_y(6)
		col.shape.extents.y = 23
	elif shootDir < 1 and col.shape.extents.y==23:
		col.move_local_y(-6)
		col.shape.extents.y = 29
		
	if shootDir and is_on_floor():
		ms = 0
	else:
		ms = maxms

	if action["jump"]:
		if is_on_floor() and jumpReserve==maxJumpReserve:
			vel.y = jumpSpeed
			jumpReserve-=1
		elif jumpReserve<maxJumpReserve and jumpReserve>0:
			jumpReserve -= maxJumpReserve/10
			vel.y -= maxJumpReserve/10
	else:
		jumpReserve = maxJumpReserve
	
	if not is_on_floor():
		vel.y = min(vel.y+10, 4*maxSpeed)
		airCounter+=delta
		if airCounter>5:
			queue_free()
	else:
		airCounter=0
	
	move_and_slide(Vector2(vel.x*ms,vel.y),Vector2(0,-1))
	
	if gui:
		gui.get_child(2).text = String(global_position.x).pad_decimals(0)
	
	if shotCounter < shotCooldown:
		shotCounter+=delta
	elif action["attack"]:
		Shoot()
	
	RunAni(vel.x,delta)

func Shoot():
	shotCounter = 0
	shotAni = 0.6
	var shot = projectile.instance()
	shot.vel.x = maxSpeed*(shotSpeed+0.1)/shotSize
	if shootDir:
		shot.vel.x/=2
		shot.vel.y = abs(shot.vel.x)*shootDir
	if sprite.flip_h:
		shot.vel.x = -shot.vel.x
	shot.scale*=shotSize
	shot.damage = damage
	shot.AI = AI
	shot.shooter = self
	if AI:
		shot.modulate = Color(0.4,0,0)
	var pos = shotSpawn[4+shootDir].global_position if sprite.flip_h else shotSpawn[1+shootDir].global_position
	shot.global_position = pos - Vector2(shotSize,0) if sprite.flip_h else pos + Vector2(shotSize,0)
	projectileParent.add_child(shot)
	
func GetHit(proj):
	if hitCounter>iframeDur:
		health-=proj.damage
		if not AI:
			gui.get_child(0).text = String(health).pad_decimals(0)+"HP"
			hitCounter = 0
			vel.y = jumpSpeed
			var d = global_position.x-proj.global_position.x
			vel.x = (d/abs(d))*maxms*10
		if health<=0:
			proj.shooter.xp+=xpReward
			if proj.shooter.gui:
				proj.shooter.gui.get_child(1).text = String(proj.shooter.xp).pad_decimals(0)+"XP"
			queue_free()

func RunAni(x, delta):
	shotAni = max(0,shotAni-delta)
	if x:
		sprite.flip_h = x<0
	if shootDir == -1:
		if shotAni or x:
			sprite.frame = Ani.UP
		else:
			sprite.frame = Ani.IDLE
	elif shootDir == 1:
		if shotAni or x:
			sprite.frame = Ani.DOWN
		else:
			sprite.frame = Ani.DUCK
	else:
		if x:
			aniCounter += delta*aniSpeed
			if aniCounter >= 1:
				aniCounter = 0
			if aniCounter > 0.5:
				sprite.frame = Ani.RUN2
			else:
				sprite.frame = Ani.RUN1
		else:
			if shotAni:
				sprite.frame = Ani.SHOOT
			else:
				sprite.frame = Ani.IDLE
