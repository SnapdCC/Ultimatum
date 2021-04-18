extends Sprite

export(String, FILE, "*.tscn,*.scn") var file_path setget set_file_path

func set_file_path(p_value):
	if typeof(p_value) == TYPE_STRING and p_value.get_extension() in ["tscn", "scn"]:
		var d = Directory.new()
		if not d.file_exists(p_value):
			return
		file_path = p_value


func _on_SceneTransition_area_entered(area):
	pass # Replace with function body.
	get_tree().change_scene(file_path)
