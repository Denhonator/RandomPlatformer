extends StaticBody2D

onready var col = find_node("CollisionPolygon2D")
onready var vis = find_node("Polygon2D")
var original
var dir = 20
var length = 150
var goal = 4000
onready var noti = find_node("VisibilityNotifier2D")
onready var enemy = preload("res://Enemy.tscn")
var level = 1
var ecount = 0
onready var spikes = preload("res://Spikes.tscn")
var newSpikes = null

func _ready():
	col.polygon = vis.polygon
	original = vis.polygon
	seed(OS.get_system_time_secs())
	
func Reset():
	col.polygon = original
	vis.polygon = original
	noti.position = original[1]
	
func ContinuePlatform(i):
	var index = vis.polygon.size()-3
	var prev = vis.polygon[index]
	if prev.x>=goal:
		return
	var pol = vis.polygon
	if newSpikes:
		dir = -dir
		newSpikes = null
		i = 1
	else:
		dir = rand_range(20,70) * dir/abs(dir)
		if randi()%100>20:
			dir = -dir
		length = rand_range(150,300)
		
	if dir > 0 and randi()%100>50:
		length = 80+level*10
		newSpikes = spikes.instance()
		newSpikes.damage = level*3
	
	if dir<0:	#up
		pol.insert(index+1,Vector2(prev.x,prev.y+dir))
		pol.insert(index+2,Vector2(prev.x+length,prev.y+dir))
	else:		#down
		pol[index].x+=5
		pol.insert(index+1,Vector2(prev.x+5,prev.y+dir))
		pol.insert(index+2,Vector2(prev.x+length,prev.y+dir))
	pol[pol.size()-2].x+=length
		
	noti.position = pol[index+2]
		
	if pol.size()>80:
		pol.remove(pol.size()-1)
		pol.remove(0)
		pol.remove(pol.size()-1)
		pol.remove(0)
	
	if randi()%20>16-level:
		SpawnEnemy(false)
	elif newSpikes:
		newSpikes.position = pol[index+1]
		get_parent().add_child(newSpikes)
	elif i%2==1:
		SpawnEnemy(prev.x>goal)

	vis.polygon = pol
	col.polygon = pol
	
func SpawnEnemy(boss):
	var e = enemy.instance()
	e.Randomize(level, ecount)
	if boss:
		e.Randomize(level, ecount)
	e.position = noti.position + Vector2(-20,-50)
	get_parent().add_child(e)
	ecount+=1

func _on_VisibilityNotifier2D_screen_entered():
	for i in range(5):
		ContinuePlatform(i)
