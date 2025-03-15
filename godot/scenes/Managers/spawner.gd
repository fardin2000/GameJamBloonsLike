extends Node2D

const WaveResource = preload("res://resources/Wave.gd")
const CamoModifier = preload("res://scenes/Enemy/Modifiers/camo_modifier.gd")
const RegenModifier = preload("res://scenes/Enemy/Modifiers/regen_modifier.gd")

var current_group_index: int = 0
var enemies_spawned_in_group: int = 0
var spawn_timer: float = 0.0
var current_wave: WaveResource = null
var active_enemies = []
var wave_in_progress = false
var total_enemies_in_current_wave = 0
var enemies_defeated_in_current_wave = 0
var current_wave_index = 0

# Get a reference to the Path2D node in your Main scene.
@onready var path_node: Node2D = get_node("../Path2D")

signal wave_completed(wave_index)
signal wave_enemies_defeated()
signal enemy_spawned(enemy)

func _enter_tree() -> void:
	add_to_group("Spawner")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if current_wave == null:
		return
		
	if current_group_index >= current_wave.enemies.size():
		check_wave_completion()
		return
		
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_enemy_in_current_group()

func start_wave(wave: WaveResource, wave_index: int = 0) -> void:
	wave_in_progress = true
	current_wave = wave
	current_group_index = 0
	enemies_spawned_in_group = 0
	spawn_timer = 0.0
	current_wave_index = wave_index
	enemies_defeated_in_current_wave = 0
	
	# Calculate total enemies
	total_enemies_in_current_wave = 0
	for enemy_group in current_wave.enemies:
		total_enemies_in_current_wave += enemy_group.get("count", 1)

func spawn_enemy_in_current_group() -> void:
	var current_group = current_wave.enemies[current_group_index]
	
	var enemy = current_group.get("enemy_type", preload("res://scenes/Enemy/red_enemy.tscn")).instantiate()
	enemy.path = path_node.get_path()
	
	# Apply modifiers if specified
	if current_group.has("modifiers"):
		for modifier_type in current_group["modifiers"]:
			match modifier_type:
				"camo":
					enemy.add_modifier(CamoModifier.new())
				"regen":
					enemy.add_modifier(RegenModifier.new())
	
	# Connect signal to track defeated enemies
	enemy.connect("defeated", _on_enemy_defeated)
	
	get_tree().current_scene.add_child(enemy)
	active_enemies.append(enemy)
	
	# Emit signal that an enemy was spawned
	emit_signal("enemy_spawned", enemy)
	
	enemies_spawned_in_group += 1
	spawn_timer = current_group.get("delay", 1.0)
	
	if enemies_spawned_in_group >= current_group.get("count", 1):
		current_group_index += 1
		enemies_spawned_in_group = 0
		
		# Check if all enemies in this wave have been spawned
		if current_group_index >= current_wave.enemies.size():
			emit_signal("wave_completed", current_wave_index)

func check_wave_completion() -> void:
	# Check if there are any remaining enemies in the scene
	var remaining_enemies = get_tree().get_nodes_in_group("enemies")
	if remaining_enemies.is_empty():
		current_wave = null
		wave_in_progress = false
		emit_signal("wave_enemies_defeated")

func _on_enemy_defeated(enemy) -> void:
	active_enemies.erase(enemy)
	enemies_defeated_in_current_wave += 1
	
	# Check if all enemies in the current wave have been defeated
	if wave_in_progress and enemies_defeated_in_current_wave >= total_enemies_in_current_wave:
		check_wave_completion()
