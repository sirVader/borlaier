extends Control


onready var scene_controller: Node = get_node("/root/SceneController")


func _ready() -> void:
	EnvVar.can_pause = false
	if EnvVar.first_time_played:
		$VBoxContainer/VBoxContainer/ContinueGame.text = "Start new game"
	else:
		$VBoxContainer/VBoxContainer/ContinueGame.text = "Continue game"


func _on_ContinueGame_pressed() -> void:
	EnvVar.can_pause = true
	if EnvVar.first_time_played:
		# Set lobby or intro
		scene_controller.change_scene(false, self, self.filename, "res://Scenes/Levels/Level0.tscn")
	elif not EnvVar.first_time_played:
		scene_controller.change_scene(false, self, self.filename, EnvVar.latest_level_path)


func _on_Settings_pressed() -> void:
	pass # Replace with function body.


func _on_QuitToDesktop_pressed() -> void:
	get_tree().quit()
