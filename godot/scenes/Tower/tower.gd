extends Area2D
class_name BaseTower

signal tower_selected(tower: BaseTower)
signal upgrade_purchased(tower: BaseTower, path: String, level: int)

@export var range: float = 150.0
@export var attack_cooldown: float = 1.0
@export var projectile_scene: PackedScene = preload("res://scenes/Tower/Projectile.tscn")  # preload the projectile scene in the inspector
@export var is_preview: bool = false  # Make is_preview accessible from outside

@onready var collision_shape = $CollisionShape2D
var cooldown_timer: float = 0.0
var target: Node2D = null

# Upgrade paths (3 paths with 5 upgrades each, like in Bloons TD)
var upgrade_paths = {
	"path1": {
		"level": 0,
		"max_level": 5,
		"upgrades": []
	},
	"path2": {
		"level": 0,
		"max_level": 5,
		"upgrades": []
	},
	"path3": {
		"level": 0,
		"max_level": 5,
		"upgrades": []
	}
}

# Base stats that can be modified by upgrades
var base_stats = {
	"damage": 1,
	"pierce": 1,  # Number of enemies a projectile can hit
	"attack_speed": 1.0,  # Multiplier for attack speed
	"range_multiplier": 1.0,
	"special_effects": []  # Array of special effects granted by upgrades
}

# Economy manager reference
var economy_manager: EconomyManager = null

func _ready() -> void:
	# Update the collision shape radius based on the 'range' variable.
	if collision_shape:
		if collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = range
	
	add_to_group("Tower")
	initialize_upgrades()
	queue_redraw()  # Force redraw to show the preview circle
	
	# Enable input processing for tower selection
	if not is_preview:
		input_pickable = true
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		input_event.connect(_on_input_event)
		
		# Find the economy manager
		await get_tree().process_frame
		economy_manager = get_tree().get_first_node_in_group("EconomyManager")

func _process(delta: float) -> void:
	if is_preview:
		queue_redraw()  # Keep redrawing while in preview mode
		return
	
	cooldown_timer -= delta
	
	# Always try to find the nearest target
	target = find_target()
	
	# If we have a target and cooldown is over, fire
	if target and cooldown_timer <= 0.0:
		attack(target)
		cooldown_timer = attack_cooldown / base_stats.attack_speed

func _draw() -> void:
	# Draw a semi-transparent circle to visualize the tower's range.
	if is_preview:
		draw_circle(Vector2.ZERO, range * base_stats.range_multiplier, Color(0, 1, 0, 0.3))
	elif _is_mouse_hovering:  # Now we use this variable to detect tower selection, not just hovering
		draw_circle(Vector2.ZERO, range * base_stats.range_multiplier, Color(1, 1, 1, 0.2))

var _is_mouse_hovering := false

func _on_mouse_entered() -> void:
	_is_mouse_hovering = true
	# We don't queue_redraw() here because we don't want to show range on hover

func _on_mouse_exited() -> void:
	_is_mouse_hovering = false
	# We don't queue_redraw() here because we don't want to hide range if tower is selected

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("tower_selected", self)

func find_target() -> Node2D:
	# Find the nearest enemy in range
	var nearest_enemy: Node2D = null
	var nearest_distance: float = range * base_stats.range_multiplier
	
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var distance = global_position.distance_to(body.global_position)
			if distance <= nearest_distance:
				nearest_distance = distance
				nearest_enemy = body
	
	return nearest_enemy

func attack(enemy: Node2D) -> void:
	# Instance a projectile and launch it toward the target.
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.max_range = range * base_stats.range_multiplier  # Set the max range
	projectile.set_target(enemy)  # This now just sets initial direction
	projectile.damage = base_stats.damage
	projectile.pierce = base_stats.pierce
	# Assuming the Main scene is the root; adjust as needed.
	get_tree().current_scene.add_child(projectile)

# Virtual method to be overridden by specific tower types
func initialize_upgrades() -> void:
	pass

# Returns true if the upgrade was successful
func upgrade_path(path_number: int) -> bool:
	var path_key = "path" + str(path_number)
	if not upgrade_paths.has(path_key):
		return false
		
	var path = upgrade_paths[path_key]
	if path.level >= path.max_level:
		return false
		
	# Check if other paths are at max allowed level based on this upgrade
	for other_path in upgrade_paths.keys():
		if other_path != path_key and upgrade_paths[other_path].level >= 2:
			return false
	
	# Apply the upgrade using our comprehensive apply_upgrade method
	return try_upgrade(path_key)

# Save tower data
func save_data() -> Dictionary:
	return {
		"upgrade_paths": upgrade_paths,
		"base_stats": base_stats
	}

# Load tower data
func load_data(data: Dictionary) -> void:
	if data.has("upgrade_paths"):
		upgrade_paths = data.upgrade_paths
	if data.has("base_stats"):
		base_stats = data.base_stats

# Get the cost of the next upgrade for a path
func get_upgrade_cost(path: String) -> int:
	if not upgrade_paths.has(path):
		return 0
		
	var path_info = upgrade_paths[path]
	var current_level = path_info.level
	
	# Check if we've reached max level for this path
	if current_level >= path_info.max_level:
		return 0
		
	# Get the cost from the specific upgrade definition
	if path_info.upgrades.size() > current_level:
		var upgrade = path_info.upgrades[current_level]
		if upgrade.has("cost"):
			return upgrade.cost
	
	# Fall back to default cost if not defined
	return 100

# Try to purchase an upgrade for a specific path
func try_upgrade(path: String) -> bool:
	print("Tower.try_upgrade called for path: ", path)
	
	if not upgrade_paths.has(path):
		print("Error: Invalid upgrade path: ", path)
		return false
		
	var path_info = upgrade_paths[path]
	var current_level = path_info.level
	
	# Check if we've reached max level for this path
	if current_level >= path_info.max_level:
		print("Error: Max level reached for path: ", path)
		return false
	
	# Check if other paths are at max allowed level based on this upgrade
	for other_path in upgrade_paths.keys():
		if other_path != path and upgrade_paths[other_path].level >= 2:
			print("Error: Cannot upgrade path ", path, " because path ", other_path, " is already at level ", upgrade_paths[other_path].level)
			return false
		
	# Get the cost from the specific upgrade
	var cost = get_upgrade_cost(path)
	print("Upgrade cost: $", cost)
	
	# Try to purchase the upgrade
	if economy_manager:
		print("Economy manager found, checking if can afford upgrade")
		if economy_manager.can_afford(cost):
			print("Can afford upgrade, attempting to purchase")
			if economy_manager.try_purchase_upgrade(self, path, current_level + 1, cost):
				print("Purchase successful, applying upgrade")
				# Apply the upgrade
				apply_upgrade(path)
				return true
			else:
				print("Purchase failed")
				return false
		else:
			print("Cannot afford upgrade (cost: $", cost, ", money: $", economy_manager.get_money(), ")")
			return false
	else:
		print("Error: No economy manager found")
		return false

# Apply an upgrade to a specific path
func apply_upgrade(path: String) -> void:
	if not upgrade_paths.has(path):
		return
		
	var path_info = upgrade_paths[path]
	path_info.level += 1
	
	# Apply the upgrade effects
	# This is a virtual method to be overridden by specific tower types
	_apply_upgrade_effects(path, path_info.level)
	
	# Emit the upgrade purchased signal
	emit_signal("upgrade_purchased", self, path, path_info.level)
	
	# Update the tower's appearance (if needed)
	queue_redraw()

# Virtual method to be overridden by specific tower types
func _apply_upgrade_effects(path: String, level: int) -> void:
	# Override this in specific tower types to apply effects based on the path and level
	pass
