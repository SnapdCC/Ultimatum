extends Control

func _process(delta):
	if Input.is_action_just_pressed("debug_icelevel"):
		get_tree().change_scene("res://UltimatumViewportManager.tscn")
	if Input.is_action_just_pressed("debug_mainmenu"):
		get_tree().change_scene("res://Screens/MainScreen.tscn")
	if Input.is_action_just_pressed("debug_limbolevel"):
		get_tree().change_scene("res://LimboViewportManager.tscn")
