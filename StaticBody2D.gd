extends StaticBody2D

var col
var vis
var dir = 0
var length = 150
var noti
var enemy

func _ready():
	col = find_node("CollisionPolygon2D")
	vis = find_node("Polygon2D")
	noti = find_node("VisibilityNotifier2D")
	enemy = preload("res://Enemy.tscn")
	col.polygon = vis.polygon
	seed(OS.get_system_time_secs())
	
func ContinuePlatform(i):
	var index = vis.polygon.size()/2
	var prev = vis.polygon[index-1]
	var pol = vis.polygon
	dir = rand_range(30,70)
	length = rand_range(150,300)
	if randi()%101>15:
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
		
	if pol.size()>80:
		pol.remove(pol.size()-1)
		pol.remove(0)
		pol.remove(pol.size()-1)
		pol.remove(0)

	noti.position = pol[index+2]
	if i%2==0:
		var e = enemy.instance()
		e.global_position = noti.global_position + Vector2(0,-200)
		get_parent().add_child(e)
	vis.polygon = pol
	col.polygon = pol

func _on_VisibilityNotifier2D_screen_entered():
	for i in range(10):
		ContinuePlatform(i)
