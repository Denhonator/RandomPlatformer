extends StaticBody2D

var col
var vis
var original
var dir = 20
var length = 150
var goal = 4000
var noti
var enemy
var level = 1
var ecount = 0

func _ready():
	col = find_node("CollisionPolygon2D")
	vis = find_node("Polygon2D")
	noti = find_node("VisibilityNotifier2D")
	enemy = preload("res://Enemy.tscn")
	col.polygon = vis.polygon
	original = vis.polygon
	seed(OS.get_system_time_secs())
	
func Reset():
	col.polygon = original
	vis.polygon = original
	noti.position = original[1]
	
func ContinuePlatform(i):
	var index = vis.polygon.size()/2
	var prev = vis.polygon[index-1]
	if prev.x>=goal:
		return
	var pol = vis.polygon
	dir = rand_range(20,70) * dir/abs(dir)
	length = rand_range(150,300)
	if randi()%100>20:
		dir = -dir
	
	if dir<0:
		pol.insert(index,Vector2(prev.x,prev.y+dir))
		pol.insert(index+1,Vector2(prev.x+length,prev.y+dir))
		pol.insert(index+2,Vector2(prev.x+length,prev.y+dir+5))
		pol.insert(index+3,Vector2(prev.x+5,prev.y+dir+5))
		pol[index+4].x+=5
	else:
		pol[index-1].x+=5
		pol.insert(index,Vector2(prev.x+5,prev.y+dir))
		pol.insert(index+1,Vector2(prev.x+length,prev.y+dir))
		pol.insert(index+2,Vector2(prev.x+length,prev.y+dir+5))
		pol.insert(index+3,Vector2(prev.x,prev.y+dir+5))
		
	noti.position = pol[index+1]
		
	if pol.size()>80:
		pol.remove(pol.size()-1)
		pol.remove(0)
		pol.remove(pol.size()-1)
		pol.remove(0)
	
	if i%2==1:
		SpawnEnemy(prev.x>goal)
	if randi()%20>16-level:
		SpawnEnemy(false)

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
	for i in range(10):
		ContinuePlatform(i)
