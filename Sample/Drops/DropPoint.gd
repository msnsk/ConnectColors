extends Node2D


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_inout":
		queue_free()
		print("DropPoint freed")
