extends actor

# variables
var face_right = true
var face_left = false
var holder = true

# these inputs cause movement when pressed
func _physics_process(delta: float) -> void:
	var direction = Vector2(
		# right is default 1, when both are pressed simutaniously no movement, when left is pressed -1 is registered
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		# down is default 1, when both are pressed simutaniously no movement, when up is pressed -1 is registered
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	# checks to see if the player is facing right or left
	if Input.is_action_just_released("move_right"):
		face_right = true
		face_left = false
	elif Input.is_action_just_released("move_left"):
		face_left = true
		face_right = false
	
	# eventual placement of code to make punch, kick, and guard "animations" appear
	if Input.is_action_pressed("punch"):
		holder = true
	elif Input.is_action_pressed("kick"):
		holder = true
	elif Input.is_action_pressed("guard"):
		holder = true
	
	# gives speed a value
	velocity = speed * direction
