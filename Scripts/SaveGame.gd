extends Node

onready var scene_controller: Node = get_node("/root/SceneController")

const SAVE_FILE: String = "res://DEBUG/borlaier_game.save"
const SAVE_FILE_DIR: String = "res://DEBUG"
# Use user://borlaier_game.save

var game_data: Dictionary = {}


func _ready() -> void:
	load_data()



func save_data() -> void:
	for node in scene_controller.get_children():
		if node.is_in_group("Level"):
			scene_controller.get_level_variables(node)
	
	QuestController.get_quest_variables()
	get_game_data()
	var dir: Directory = Directory.new()
	if not dir.dir_exists(SAVE_FILE_DIR):
		dir.make_dir(SAVE_FILE_DIR)
	
	var file: File = File.new()
	file.open(SAVE_FILE, File.WRITE)
	file.store_var(game_data)
	file.close()
	print("Game data saved")


func load_data() -> void:
	var file: File = File.new()
	if not file.file_exists(SAVE_FILE):
		save_data()
	file.open(SAVE_FILE, File.READ)
	game_data = file.get_var()
	file.close()
	
	set_game_data()
	QuestController.set_quest_variables()


func reset_data() -> void:
	var dir: Directory = Directory.new()
	if dir.file_exists(SAVE_FILE):
		dir.remove(SAVE_FILE)
	else:
		print("Can't delet file. Doesn't exist!")


func get_game_data() -> void:
	game_data = {
		# Player data
		"Player_health": PlayerGlobals.health,
		"Player_has_gun": PlayerGlobals.has_gun,
		"Player_talking": PlayerGlobals.talking,
		"Player_coins": PlayerGlobals.coins,
		"Player_magazine_size": PlayerGlobals.magazine_size,
		"Player_bullets_in_mag": PlayerGlobals.bullets_in_mag,
		"Player_bullets_left": PlayerGlobals.bullets_left,
		"Player_grenades_left": PlayerGlobals.grenades_left,
		"Player_holding_grenade": PlayerGlobals.holding_grenade,
		"Player_current_weapon": PlayerGlobals.current_weapon,
		"Player_elevator_floor_access": PlayerGlobals.elevator_floor_access,
		
		# Envviroment data
		"EnvVar_first_time_played": EnvVar.first_time_played,
		"EnvVar_latest_level_path": EnvVar.latest_level_path,
		"EnvVar_minigame_load_scene_path": EnvVar.minigame_load_scene_path,
		"EnvVar_kbgs_minigame_first_time": EnvVar.kbgs_minigame_first_time,
		"EnvVar_kbgs_minigame_won": EnvVar.kbgs_minigame_won,
		"EnvVar_elevator_next_level": EnvVar.elevator_next_level,
		"EnvVar_elevator_current_level_number": EnvVar.elevator_current_level_number,
		"EnvVar_elevator_old_level_number": EnvVar.elevator_old_level_number,
		"EnvVar_elevator_oldest_level_number": EnvVar.elevator_next_level,
		"EnvVar_elevator_button_number_pressed": EnvVar.elevator_button_number_pressed,
		"EnvVar_elevator_moving": EnvVar.elevator_moving,
		
		# Level data
		"LevelVar_elevator_variables": scene_controller.elevator_variables,
		"LevelVar_level0_variables": scene_controller.level0_variables,
		"LevelVar_level1_variables": scene_controller.level1_variables,
		"LevelVar_level2_variables": scene_controller.level2_variables,
		
		"Quest_FatMan_dialogic": QuestController.FatMan_dialogic,
		"Quest_FatMan1_dict": QuestController.FatMan1_dict,
		"Quest_FatMan2_dict": QuestController.FatMan2_dict
		}


func set_game_data() -> void:
	PlayerGlobals.health = game_data["Player_health"]
	PlayerGlobals.has_gun = game_data["Player_has_gun"]
	PlayerGlobals.talking = game_data["Player_talking"]
	PlayerGlobals.coins = game_data["Player_coins"]
	PlayerGlobals.magazine_size = game_data["Player_magazine_size"]
	PlayerGlobals.bullets_in_mag = game_data["Player_bullets_in_mag"]
	PlayerGlobals.bullets_left = game_data["Player_bullets_left"]
	PlayerGlobals.grenades_left = game_data["Player_grenades_left"]
	PlayerGlobals.holding_grenade = game_data["Player_holding_grenade"]
	PlayerGlobals.current_weapon = game_data["Player_current_weapon"]
	PlayerGlobals.elevator_floor_access = game_data["Player_elevator_floor_access"]
	
	EnvVar.first_time_played = game_data["EnvVar_first_time_played"]
	EnvVar.latest_level_path = game_data["EnvVar_latest_level_path"]
	EnvVar.minigame_load_scene_path = game_data["EnvVar_minigame_load_scene_path"]
	EnvVar.kbgs_minigame_first_time = game_data["EnvVar_kbgs_minigame_first_time"]
	EnvVar.kbgs_minigame_won = game_data["EnvVar_kbgs_minigame_won"]
	EnvVar.elevator_next_level = game_data["EnvVar_elevator_next_level"]
	EnvVar.elevator_current_level_number = game_data["EnvVar_elevator_current_level_number"]
	EnvVar.elevator_old_level_number = game_data["EnvVar_elevator_old_level_number"]
	EnvVar.elevator_oldest_level_number = game_data["EnvVar_elevator_oldest_level_number"]
	EnvVar.elevator_button_number_pressed = game_data["EnvVar_elevator_button_number_pressed"]
	EnvVar.elevator_moving = game_data["EnvVar_elevator_moving"]
	
	scene_controller.elevator_variables = game_data["LevelVar_elevator_variables"]
	scene_controller.level0_variables = game_data["LevelVar_level0_variables"]
	scene_controller.level1_variables = game_data["LevelVar_level1_variables"]
	scene_controller.level2_variables = game_data["LevelVar_level2_variables"]
	
	QuestController.FatMan_dialogic = game_data["Quest_FatMan_dialogic"]
	QuestController.FatMan1_dict = game_data["Quest_FatMan1_dict"]
	QuestController.FatMan2_dict = game_data["Quest_FatMan2_dict"]