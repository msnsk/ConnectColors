extends Node2D

const drop_scenes = [
	preload("res://Drops/BlueDrop.tscn"),
	preload("res://Drops/GreenDrop.tscn"),
	preload("res://Drops/OrangeDrop.tscn"),
	preload("res://Drops/RedDrop.tscn"),
	preload("res://Drops/YellowDrop.tscn")
]

export (int) var min_erasable = 3
export (int) var max_drops = 50

var is_playing = false
var is_holding = false
var pointed_drop
var active_color = ""
var held_drops = []

onready var spawner = $SpawnPath/Spawner
onready var drops = $Drops
onready var drops_line = $DropsLine
onready var pointer = $Pointer


func _ready():
	randomize()
	for _i in range(max_drops):
		spawn_drop()
		yield(get_tree().create_timer(0.025), "timeout")


func spawn_drop():
	var drop_scene = drop_scenes[randi() % drop_scenes.size()]
	var drop = drop_scene.instance()
	drop.position = spawner.global_position
	drops.add_child(drop)


func _process(_delta):
	update_drops_line()
	get_input()


func update_drops_line():
	if not held_drops.empty():
		var temp_array = PoolVector2Array()
		for drop in held_drops:
			temp_array.append(drop.position)
		drops_line.points = temp_array


func get_input():
	pointer.position = get_global_mouse_position()
	if Input.is_action_just_pressed("tap"):
		hold_drop()
		update_drops_connection()
	if Input.is_action_just_released("tap"):
		erase_drops()
		release_drops()


func hold_drop():
	if pointed_drop:
		is_holding = true


func update_drops_connection():
	if is_holding and pointed_drop:
		if held_drops.empty():
			active_color = pointed_drop.color
			connect_drop()
		elif pointed_drop.color == active_color:
			if held_drops.size() >= 2 and pointed_drop == held_drops[-2]:
				disconnect_drop()
			elif not pointed_drop in held_drops:
				connect_drop()


func connect_drop():
	pointed_drop.anim_player.play("flash")
	held_drops.append(pointed_drop)
	drops_line.add_point(pointed_drop.position)
	print("connected drops: ", drops_line.get_point_count())


func disconnect_drop():
	var canceled_drop = held_drops.pop_back()
	canceled_drop.anim_player.stop()
	canceled_drop.anim_player.play("idle")
	drops_line.remove_point(drops_line.get_point_count() - 1)
	print("connected drops: ", drops_line.get_point_count())


func erase_drops():
	if held_drops.size() < min_erasable:
		return
	var erased =  held_drops.duplicate()
	for drop in erased:
		drop.queue_free()
		spawn_drop()
		yield(get_tree().create_timer(0.1), "timeout")	
	print("connected drops: ", drops_line.get_point_count())


func release_drops(): 
	is_holding = false
	for drop in held_drops:
		drop.anim_player.stop()
		drop.anim_player.play("idle")
	held_drops.clear()
	drops_line.clear_points()


func _on_Pointer_area_entered(area):
	if area.is_in_group("Pointable"):
		pointed_drop = area.get_parent()
		if not held_drops.empty() and held_drops[-1] in pointed_drop.stuck_drops:
			update_drops_connection()


func _on_Pointer_area_exited(area):
	if area.is_in_group("Pointable"):
		pointed_drop = null
