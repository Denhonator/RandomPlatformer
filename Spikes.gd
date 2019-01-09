extends Area2D

var damage = 1
var shooter = null

func _on_Spikes_body_entered(body):
	if body.has_method("GetHit"):
		body.GetHit(self)
