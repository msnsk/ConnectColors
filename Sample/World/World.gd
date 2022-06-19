extends Node2D

const drop_scenes = [
	preload("res://Drops/BlueDrop.tscn"),
	preload("res://Drops/GreenDrop.tscn"),
	preload("res://Drops/OrangeDrop.tscn"),
	preload("res://Drops/RedDrop.tscn"),
	preload("res://Drops/YellowDrop.tscn")
]

const particles_scn = preload("res://Drops/DropParticles.tscn")
const drop_point_scn = preload("res://Drops/DropPoint.tscn")

export (int) var min_erasable = 3
export (int) var max_drops = 50
export (int) var play_time = 30

var count_down_time = 3
var score = 0
var combo = 0
var is_playing = false
var is_holding: = false
var pointed_drop: Node2D
var active_color = ""
var held_drops = []

onready var spawner = $SpawnPath/Spawner
onready var drops = $Drops
onready var drops_line = $DropsLine
onready var pointer = $Pointer
onready var combo_timer = $ComboTimer
onready var play_timer = $PlayTimer
onready var count_down_timer = $CountDownTimer
onready var erase_audio = $EraseAudio
onready  var touch_audio = $TouchAudio
onready var ui = $UILayer/UI
onready var pulse_button = $UILayer/UI/PulseButton


func _ready():
	randomize()
	set_process_input(false)
	set_process(false)
	pulse_button.connect("pressed", self, "_on_PulseButton_pressed")
	ui.update_timer(play_time)
	ui.update_score(score)
	ui.update_combo(combo)
	
	for _i in range(max_drops):
		spawn_drop()
		yield(get_tree().create_timer(0.025), "timeout")
	
	ui.get_node("CountDownLabel").show()
	count_down_timer.start()


func spawn_drop():
	var drop_scene = drop_scenes[randi() % drop_scenes.size()]
	var drop = drop_scene.instance()
	drop.position = spawner.global_position
	drops.add_child(drop)


func _process(_delta):
	get_input()
	update_drops_line()


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


func _on_PulseButton_pressed(): # Signal connected
	for drop in drops.get_children():
		if drop.is_in_group("Drops"):
			drop.random_impulse()


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
	touch_audio.play()
	held_drops.append(pointed_drop)
	drops_line.add_point(pointed_drop.position)
	pointed_drop.num_label.text = str(held_drops.size())
	print("connected drops: ", drops_line.get_point_count())


func disconnect_drop():
	var canceled_drop = held_drops.pop_back()
	canceled_drop.anim_player.stop()
	canceled_drop.anim_player.play("idle")
	drops_line.remove_point(drops_line.get_point_count() - 1)
	canceled_drop.num_label.text = ""
	print("connected drops: ", drops_line.get_point_count())


func erase_drops():
	if held_drops.size() < min_erasable:
		return
	
	combo_timer.paused = true
	combo += 1
	ui.update_combo(combo)
	
	var erased = held_drops.duplicate()
	var erased_num = held_drops.size()
	for drop in erased:
		var point = drop.point * combo * erased_num
		score += point
		ui.update_score(score)
		generate_particles(drop)
		generate_point(drop, point)
		drop.queue_free()
		erase_audio.play()
		spawn_drop()
		yield(get_tree().create_timer(0.1), "timeout")
	
	combo_timer.paused = false
	combo_timer.start(3)
	
	print("connected drops: ", drops_line.get_point_count())


func generate_particles(drop):
	var particles = particles_scn.instance()
	particles.position = drop.position
	call_deferred("add_child", particles)
	particles.emitting = true


func generate_point(drop, point):
	var drop_point = drop_point_scn.instance()
	drop_point.position = drop.position
	call_deferred("add_child", drop_point)
	drop_point.get_node("Label").text = str(point)
	drop_point.get_node("AnimationPlayer").play("fade_inout")


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


func _on_PlayTimer_timeout():
	play_time -= 1
	ui.update_timer(play_time)
	if play_time == 3:
		count_down_timer.start()
		ui.count_down_label.show()
	elif play_time == 0:
		play_timer.stop()


func _on_CountDownTimer_timeout():
	count_down_time -= 1
	if count_down_time > 0:
		ui.update_count_down(count_down_time)
	elif count_down_time == 0:
		if not is_playing:
			is_playing = true
			ui.update_count_down("Go!")
			set_process_input(true)
			set_process(true)
		else:
			is_playing = false
			ui.update_count_down("Time\nUp!")
			set_process_input(false)
			set_process(false)
	else:
		ui.get_node("CountDownLabel").hide()
		count_down_timer.stop()
		count_down_time = 3
		ui.update_count_down(count_down_time)
		if is_playing:
			play_timer.start()
			combo_timer.start()
		else:
			ui.show_result(score)


func _on_ComboTimer_timeout():
	print("combo timer timeout")
	combo = 0
	ui.update_combo(combo)

