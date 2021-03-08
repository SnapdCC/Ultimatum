extends actor

# these inputs cause movement when pressed
func _physics_process(delta: float) -> void:
	var direction = Vector2(
		# right is default 1, when both are pressed simutaniously no movement, when left is pressed -1 is registered
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		# down is default 1, when both are pressed simutaniously no movement, when up is pressed -1 is registered
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	# gives speed a value
	velocity = speed * direction
