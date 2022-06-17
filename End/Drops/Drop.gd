extends RigidBody2D

export var color = ""

var stuck_drops = []

onready var anim_player = $AnimationPlayer


func _on_StickableArea_area_entered(area):
	if area.is_in_group("Stickable"):
		var drop = area.get_parent()
		stuck_drops.append(drop)


func _on_StickableArea_area_exited(area):
	if area.is_in_group("Stickable"):
		var drop = area.get_parent()
		var index = stuck_drops.find(drop)
		stuck_drops.remove(index)

