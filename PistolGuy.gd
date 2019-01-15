extends KinematicBody2D

var vel =			Vector2(0,0)
var maxms =			2
var ms =			2
var acc =			10
var jumpSpeed =		-150
var maxJumpReserve = 170
var aniCounter =	0
var aniSpeed =		1.3
var shotAni =		0
var shootDir =		0
var xp =			100
var xpReward =		1
var stunDur =		0.5
var iframeDur =		1
var hitCounter =	5
var maxProj =		3
var projs =			0
var rollDur =		0.5
var rollCooldown =	1
var special =		10
var specialCooldown = 0.7
var specialCounter = 0.7
var rollCounter
var jumpReserve
var sprite
var projectileParent
var projectile
var shotSpawn = []
var shotCounter
var action = {"left":false,"right":false,"up":false,"down":false,"jump":false,"attack":false,"roll":false,"special":false}
var rays = {}
var col
var gui
var aiReaction = 4
onready var hpbar = find_node("HPBar")
onready var audio = find_node("Audio")

export(bool) var AI
export(int) var maxSpeed
export(float) var shotSpeed
export(float) var damage
export(int) var health
export(float) var shotCooldown
export(float) var shotRange

enum Ani{
	IDLE = 0
	DUCK = 1
	SHOOT= 2
	RUN1 = 3
	RUN2 = 4
	UP   = 5
	DOWN = 6
	LOW  = 7
	ROLL1= 8
	ROLL2= 9
	ROLL3= 10
	THROW= 11
	}

func _ready():
	jumpReserve = maxJumpReserve
	shotCounter = shotCooldown
	rollCounter = -rollCooldown
	sprite = find_node("Sprite")
	projectile = preload("res://Projectile.tscn")
	projectileParent = get_node("/root/Main/Projectiles")
	col = find_node("CollisionShape2D")
	var shots = find_node("Shots")
	shotSpawn.append(shots.find_node("ShotRU"))
	shotSpawn.append(shots.find_node("ShotR"))
	shotSpawn.append(shots.find_node("ShotRD"))
	shotSpawn.append(shots.find_node("ShotRLO"))
	shotSpawn.append(shots.find_node("ShotLU"))
	shotSpawn.append(shots.find_node("ShotL"))
	shotSpawn.append(shots.find_node("ShotLD"))
	shotSpawn.append(shots.find_node("ShotLLO"))
	if hpbar:
		hpbar.max_value = health
	if AI:
		for r in find_node("Rays").get_children():
			rays[r.get_name()]=r
			rays[r.get_name()].enabled = r.get_name().substr(0,4)=="left"
		action["attack"] = true
		action["left"] = true
	gui = get_node("/root/Main/GUI")
		
func Randomize(power, count):
	xpReward = power
	if count%2==1 and randi()%10>2:
		maxSpeed = 0
	else:
		maxSpeed += randi()%11-5
	for i in range(power):
		var r = randi()%5
		if r==0:
			shotSpeed+=2
		elif r==1:
			damage+=1
		elif r==2:
			health+=power+1
		elif r==3:
			shotCooldown=max(0.1,shotCooldown-0.1)
		elif r==4:
			shotRange+=50

func GetInput():
	if not AI:
		for key in action.keys():
			action[key] = Input.is_action_pressed(key)
	elif not aiReaction:
		aiReaction = 4
		var ac = "right" if action["right"] else "left"
		action["up"] = rays[ac+"Up"].is_colliding() and rays[ac+"Up"].get_collider() and rays[ac+"Up"].get_collider().get_name()=="Body"
		action["down"] = rays[ac+"Down"].is_colliding() and rays[ac+"Down"].get_collider() and rays[ac+"Down"].get_collider().get_name()=="Body"
		if (maxSpeed and (action[ac] and not rays[ac+"Ground"].is_colliding() or rays[ac+"Wall"].is_colliding())
			or not maxSpeed and gui.playerref.get_ref() and ((gui.player.global_position.x>global_position.x and action["left"]) or (gui.player.global_position.x<global_position.x and action["right"]))):
				action["right"] = !action["right"]
				action["left"] = !action["left"]
				for key in rays.keys():
					rays[key].enabled = !rays[key].enabled
	else:
		aiReaction-=1
		
func Jumping():
	if action["jump"] and not action["roll"]:
		if is_on_floor() and jumpReserve==maxJumpReserve:
			vel.y = jumpSpeed
			jumpReserve-=1
		elif jumpReserve<maxJumpReserve and jumpReserve>0:
			jumpReserve -= maxJumpReserve/10
			vel.y -= maxJumpReserve/10
	else:
		jumpReserve = maxJumpReserve
		
func Rolling(delta):
	if action["roll"] and rollCounter<=-rollCooldown:
		rollCounter=rollDur
		vel.x = -maxSpeed*1.5 if sprite.flip_h else maxSpeed*1.5
		move_local_y(-20)
		vel.y = -10
	elif rollCounter>=-rollCooldown:
		rollCounter-=delta
		
func Movement(delta):
	if hitCounter>stunDur and rollCounter<=0:
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
			if action["right"] or action["left"]:
				shootDir = 1
			else:
				shootDir = 2
		else:
			shootDir = 0

	if shootDir and is_on_floor() and rollCounter<=0:
		ms = 0
	else:
		ms = maxms
		
	if not AI:
		gui.distance.text = String(global_position.x/40).pad_decimals(0)+"m"
		
func Hitbox():
	if sprite.frame==Ani.DOWN or sprite.frame==Ani.DUCK:
		col.position.y = 10
		col.scale.y = 0.76
	elif rollCounter>0:
		col.position.y = 23
		col.scale.y = 0.3
	else:
		col.position.y = 3
		col.scale.y = 1

func _process(delta):
	if hitCounter < 10:
		hitCounter+=delta
		if hitCounter < iframeDur:
			visible = int(hitCounter*10)%2==0
		else:
			visible = true
	
	Movement(delta)
	Jumping()
	Rolling(delta)
	
	if not is_on_floor():
		var mult = 4 if action["down"] and vel.y>0 and vel.y<200 else 1
		vel.y = min(vel.y+10*mult, 200*mult)
		if global_position.y>800:
			queue_free()
	
	move_and_slide(Vector2(vel.x*ms,vel.y),Vector2(0,-1))
	
	if shotCounter < shotCooldown:
		shotCounter += delta
	elif action["attack"]:
		Shoot(false)
		shotCounter = 0
	if specialCounter < specialCooldown:
		specialCounter += delta
	elif action["special"] and special>=5:
		Shoot(true)
		special = max(0,special-5)
		if gui:
			gui.special.text = String(special)
		specialCounter = 0
	
	var lookdir = 0
	if action["left"]:
		lookdir = -1
	elif action["right"]:
		lookdir = 1
	RunAni(lookdir,delta)
	Hitbox()

func Shoot(bomb):
	if projs>=maxProj or hitCounter<stunDur:
		return
	shotAni = 0.6
	var shot = projectile.instance()
	var pos = shotSpawn[5+shootDir].global_position if sprite.flip_h else shotSpawn[1+shootDir].global_position
	if bomb:
		shot.explode = 10
		shot.gravity = 2.5
		shot.shotRange = 600
		shot.scale *= 2
		shot.vel.x = 80+abs(vel.x)
		shot.vel.y = -180+vel.y/3
		pos = shotSpawn[4].global_position if sprite.flip_h else shotSpawn[0].global_position
	else:
		shot.vel.x = 50*(shotSpeed+0.1)/damage
		if abs(shootDir)==1:	#diagonal
			shot.vel.x/=2
			shot.vel.y = abs(shot.vel.x)*shootDir
		shot.shotRange = shotRange
		shot.scale += Vector2(damage-1,damage-1)*0.35
	if sprite.flip_h:
		shot.vel.x = -shot.vel.x
	shot.vel /= shot.scale
	shot.damage = damage
	shot.AI = AI
	shot.shooter = weakref(self)
	if AI:
		shot.modulate = Color(0.4,0,0)
	shot.global_position = pos - Vector2(damage,0) if sprite.flip_h else pos + Vector2(damage,0)
	projectileParent.add_child(shot)
	audio.pitch_scale = rand_range(1/damage-0.05,1/damage+0.05)
	audio.play()
	projs+=1
	
func SetSpecial(val):
	special = val
	if not AI:
		gui.special.text = String(val)
	
func GetHit(proj):
	if hitCounter>iframeDur and health>0:
		var ref = null if not proj.shooter else proj.shooter.get_ref()
		health-=proj.damage
		if proj.xp and ref and ref.has_method("SetSpecial"):
			ref.SetSpecial(ref.special+1)
		if hpbar:
			hpbar.value = health
		if not AI:
			gui.HP.text = String(health).pad_decimals(0)+"HP"
			hitCounter = 0
			vel.y = jumpSpeed
			var d = global_position.x-proj.global_position.x
			vel.x = (d/abs(d))*maxms*10
		if health<=0:
			if ref:
				ref.xp+=xpReward
				if gui:
					gui.XP.text = String(ref.xp).pad_decimals(0)+"XP"
			queue_free()

func RunAni(x, delta):
	shotAni = max(0,shotAni-delta)
	if x:
		sprite.flip_h = x<0
	if not maxSpeed:
		x = 0
	if rollCounter > 0:
		var third = rollDur/3
		if rollCounter>2*third:
			sprite.frame = Ani.ROLL1
		elif rollCounter>third:
			sprite.frame = Ani.ROLL2
		else:
			sprite.frame = Ani.ROLL3
		return
	elif specialCounter<0.4:
		sprite.frame = Ani.THROW
		return
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
	elif shootDir == 2:
		if shotAni or x:
			sprite.frame = Ani.LOW
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
