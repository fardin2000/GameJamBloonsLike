extends CharacterBody2D
class_name BaseEnemy

signal defeated(enemy)

# Base stats that may be modified by type or special properties
@export var base_health: int = 1
@export var base_speed: float = 100.0
@export var base_armor: int = 0
@export var base_damage: int = 1
@export var money_value: int = 1
@export var points_value: int = 1

# Current stats (modified by type and modifiers)
var health: int
var speed: float
var armor: int
var damage: int
var damage_resistance: float = 0.0
var is_immune_to_splash: bool = false
var can_split: bool = false

# Path following variables
@export var path: NodePath
var path_curve: Curve2D = null
var distance_along_path: float = 0.0

# Modifiers
var modifiers: Array[EnemyModifier] = []

func _ready() -> void:
	add_to_group("enemies")
	var path_node = get_node(path)
	if path_node:
		path_curve = path_node.curve
	else:
		push_error("Path2D node not found!")
	
	# Initialize stats
	initialize_stats()

func initialize_stats() -> void:
	health = base_health
	speed = base_speed
	armor = base_armor
	damage = base_damage
	
	# Apply modifiers
	for modifier in modifiers:
		modifier.apply(self)

func _physics_process(delta: float) -> void:
	if path_curve:
		distance_along_path += speed * delta
		global_position = path_curve.sample_baked(distance_along_path)
		# Rotate to face the direction of movement
		var next_pos = path_curve.sample_baked(distance_along_path + 1.0)
		rotation = (next_pos - global_position).angle()
	
	# Update modifiers
	for modifier in modifiers:
		modifier.update(self, delta)

func take_damage(amount: int) -> void:
	# Apply armor and damage resistance
	var damage_reduction = armor + (amount * damage_resistance)
	var actual_damage = max(1, amount - damage_reduction)
	health -= actual_damage
	
	if health <= 0:
		on_death()

func on_death() -> void:
	# Emit defeated signal before the enemy is freed
	emit_signal("defeated", self)
	
	# Override this in specific enemy types to handle death effects
	queue_free()

func add_modifier(modifier: EnemyModifier) -> void:
	modifiers.append(modifier)
	modifier.apply(self)

func remove_modifier(modifier: EnemyModifier) -> void:
	modifiers.erase(modifier)
	modifier.remove(self)

func has_modifier(modifier_type: String) -> bool:
	for modifier in modifiers:
		if modifier.type == modifier_type:
			return true
	return false 
