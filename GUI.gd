extends CanvasLayer

var timer = 0
var bind = 0
onready var HP = find_node("HP")
onready var XP = find_node("XP")
onready var level = find_node("Level")
onready var distance = find_node("Distance")
onready var time = find_node("Time")
onready var menu = find_node("Menu")
onready var health = find_node("Health")
onready var damage = find_node("Damage")
onready var movement = find_node("Movement")
onready var shotSpeed = find_node("ShotSpeed")
onready var shotRange = find_node("Range")
onready var firerate = find_node("Firerate")
onready var player = get_node("/root/Main/Player/Body")
var healthxp = 4
var damagexp = 4
var movementxp = 4
var shotSpeedxp = 4
var shotRangexp = 4
var fireratexp = 4
var action = ["left","right","up","down","attack","jump","roll"]
var bindCooldown = 0

func _ready():
	SetMenu(true)
	UpdateTexts()
	
func UpdateTexts():
	HP.text = String(player.health)+"HP"
	health.text = "Health: "+String(healthxp)
	damage.text = "Damage: "+String(damagexp)
	movement.text = "Movement: "+String(movementxp)
	shotSpeed.text = "Shot Speed: "+String(shotSpeedxp)
	shotRange.text = "Range: "+String(shotRangexp)
	firerate.text = "Firerate: "+String(fireratexp)
	XP.text = String(player.xp)+"XP"
	HP.text = String(player.health)+"HP"

func _process(delta):
	if bindCooldown>0:
		bindCooldown-=delta
	if not menu.visible:
		timer+=delta
		time.text=String(timer).pad_decimals(0)
	
func _input(event):
	if event is InputEventKey and event.pressed and bindCooldown<=0:
		if event.scancode==KEY_ESCAPE:
			SetMenu(!menu.visible)
		elif bind:
			var ac = action[bind-1]
			InputMap.erase_action(ac)
			InputMap.add_action(ac)
			InputMap.action_add_event(ac,event)
			bind+=1
			if bind>action.size():
				bind = 0
			UpdateText()
			
func SetMenu(b):
	menu.visible = b
	get_tree().paused = b
	bind = 0

func UpdateText():
	if bind==0:
		menu.get_child(0).text = "Bind Keys"
	else:
		menu.get_child(0).text = "Push key for "+action[bind-1]

func _on_BindKeys_pressed():
	bind = 1
	UpdateText()
	
func SetBind(b):
	bind = b
	bindCooldown = 0.2

func _on_Resume_pressed():
	SetMenu(false)

func _on_Health_pressed():
	if player.xp<healthxp:
		return
	player.xp-=healthxp
	player.health += healthxp
	healthxp += 2
	UpdateTexts()

func _on_Damage_pressed():
	if player.xp<damagexp:
		return
	player.xp-=damagexp
	player.damage += damagexp/20.0
	damagexp += 2
	UpdateTexts()

func _on_Movement_pressed():
	if player.xp<movementxp:
		return
	player.xp-=movementxp
	player.rollCooldown -= movementxp/100.0
	player.maxSpeed += float(movementxp)
	movementxp += 2
	UpdateTexts()

func _on_ShotSpeed_pressed():
	if player.xp<shotSpeedxp:
		return
	player.xp-=shotSpeedxp
	player.shotSpeed += shotSpeedxp/20.0
	shotSpeedxp += 2
	UpdateTexts()

func _on_Range_pressed():
	if player.xp<shotRangexp:
		return
	player.xp-=shotRangexp
	player.shotRange += 3.0*shotRangexp
	shotRangexp += 2
	UpdateTexts()

func _on_Firerate_pressed():
	if player.xp<fireratexp:
		return
	player.xp-=fireratexp
	player.shotCooldown -= fireratexp/200.0
	fireratexp += 2
	UpdateTexts()
