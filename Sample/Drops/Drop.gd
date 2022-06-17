extends RigidBody2D

export var color = ""
export var point = 10

var stuck_drops = []

onready var anim_player = $AnimationPlayer
onready var num_label = $ConnectedNumber/NumberLabel


func _ready():
	randomize()


func random_impulse():
	apply_impulse(Vector2(rand_range(-24, 24), 0), Vector2.UP * 80)
	apply_torque_impulse(800)


func _on_StickableArea_area_entered(area):
	if area.is_in_group("Stickable"):
		var drop = area.get_parent()
		stuck_drops.append(drop)


func _on_StickableArea_area_exited(area):
	if area.is_in_group("Stickable"):
		var drop = area.get_parent()
		var index = stuck_drops.find(drop)
		stuck_drops.remove(index)

