extends Control

func _ready():
	pause_mode=Node.PAUSE_MODE_PROCESS

func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state:= not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state

func _on_ResumeButton_button_up():
	var new_pause_state:= false
	get_tree().paused = new_pause_state
	visible = new_pause_state
