extends CanvasLayer

var timer = 0
onready var HP = find_node("HP")
onready var XP = find_node("XP")
onready var level = find_node("Level")
onready var distance = find_node("Distance")
onready var time = find_node("Time")

func _process(delta):
	timer+=delta
	time.text=String(timer).pad_decimals(0)