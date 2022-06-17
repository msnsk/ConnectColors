extends Control


onready var timer_label = $TimerLabel
onready var score_label = $ScoreLabel
onready var combo_label = $ComboLabel
onready var count_down_label = $CountDownLabel
onready var pause_button = $PauseButton
onready var pulse_button = $PulseButton
onready var paused_screen = $PausedScreen
onready var end_screen = $EndScreen
onready var last_score_label = $EndScreen/LastScoreLabel
onready var confirmation_audio = $ConfirmationAudio
onready var pause_audio = $PauseAudio
onready var pulse_audio = $PulseAudio


func _ready():
	count_down_label.hide()
	paused_screen.hide()
	end_screen.hide()

func update_timer(time):
	timer_label.text = "Time: " + str(time)

func update_score(score):
	score_label.text = "Score: " + str(score)

func update_combo(combo):
	combo_label.text = "Combo: " + str(combo)

func update_count_down(text):
	count_down_label.text = str(text)

func _on_PulseButton_pressed():
	pulse_audio.play()

func _on_PauseButton_pressed():
	pause_audio.play()
	paused_screen.visible = !paused_screen.visible
	get_tree().paused = !get_tree().paused

func show_result(last_score):
	get_tree().paused = true
	last_score_label.text = "Last Score\n" + str(last_score)
	end_screen.show()


func _on_RestartButton_pressed():
	confirmation_audio.play()
	yield(confirmation_audio, "finished")
	get_tree().paused = false
	get_tree().change_scene("res://World/World.tscn")

func _on_QuitButton_pressed():
	confirmation_audio.play()
	yield(confirmation_audio, "finished")
	get_tree().quit()
