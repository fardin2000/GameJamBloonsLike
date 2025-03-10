extends BaseTower
class_name DartTower

func _init() -> void:
	# Set initial stats for dart tower
	base_stats = {
		"damage": 1,
		"pierce": 1,
		"attack_speed": 1.0,
		"range_multiplier": 1.0,
		"special_effects": []
	}

func initialize_upgrades() -> void:
	# Path 1 - Sharpness upgrades (Define costs in each upgrade)
	upgrade_paths.path1.upgrades = [
		{
			"name": "Sharp Darts",
			"description": "Darts can pop 2 bloons each",
			"cost": 100,
			"effects": {"pierce": 2}
		},
		{
			"name": "Razor Sharp Darts",
			"description": "Darts can pop 3 bloons each",
			"cost": 200,
			"effects": {"pierce": 3}
		},
		{
			"name": "Spike-o-pult",
			"description": "Converts tower to a spike ball thrower",
			"cost": 400,
			"effects": {"pierce": 5, "damage": 2}
		},
		{
			"name": "Juggernaut",
			"description": "Huge spiked balls do extra damage",
			"cost": 1500,
			"effects": {"pierce": 8, "damage": 4}
		},
		{
			"name": "Ultra-Juggernaut",
			"description": "Splits into smaller juggernauts on impact",
			"cost": 3000,
			"effects": {"pierce": 12, "damage": 6, "special_effects": ["split"]}
		}
	]
	
	# Path 2 - Speed upgrades
	upgrade_paths.path2.upgrades = [
		{
			"name": "Quick Shots",
			"description": "Shoots darts 20% faster",
			"cost": 100,
			"effects": {"attack_speed": 1.2}
		},
		{
			"name": "Very Quick Shots",
			"description": "Shoots darts even faster",
			"cost": 200,
			"effects": {"attack_speed": 1.5}
		},
		{
			"name": "Triple Darts",
			"description": "Throws three darts at once",
			"cost": 400,
			"effects": {"attack_speed": 1.5, "special_effects": ["triple_shot"]}
		},
		{
			"name": "Super Monkey Fan Club",
			"description": "Special ability: Temporarily shoots like a Super Monkey",
			"cost": 2000,
			"effects": {"attack_speed": 2.0, "special_effects": ["smfc_ability"]}
		},
		{
			"name": "Plasma Monkey Fan Club",
			"description": "Special ability is even more powerful",
			"cost": 5000,
			"effects": {"attack_speed": 2.5, "special_effects": ["pmfc_ability"]}
		}
	]
	
	# Path 3 - Range upgrades
	upgrade_paths.path3.upgrades = [
		{
			"name": "Long Range Darts",
			"description": "Increases attack range by 20%",
			"cost": 100,
			"effects": {"range_multiplier": 1.2}
		},
		{
			"name": "Enhanced Eyesight",
			"description": "Further increases range and can detect camo",
			"cost": 200,
			"effects": {"range_multiplier": 1.4, "special_effects": ["camo_detection"]}
		},
		{
			"name": "Crossbow",
			"description": "Converts to a powerful crossbow",
			"cost": 400,
			"effects": {"range_multiplier": 1.6, "damage": 2}
		},
		{
			"name": "Sharp Shooter",
			"description": "Deadly precision and crit hits",
			"cost": 2000,
			"effects": {"range_multiplier": 1.8, "damage": 3, "special_effects": ["crit"]}
		},
		{
			"name": "Crossbow Master",
			"description": "The legendary Crossbow Master",
			"cost": 5000,
			"effects": {"range_multiplier": 2.0, "damage": 5, "special_effects": ["crit", "rapid_fire"]}
		}
	]

# Override the _apply_upgrade_effects method from BaseTower
func _apply_upgrade_effects(path: String, level: int) -> void:
	var upgrade = upgrade_paths[path].upgrades[level - 1]
	var effects = upgrade.effects
	
	# Apply stat changes
	for stat in effects.keys():
		if stat != "special_effects":
			base_stats[stat] = effects[stat]
	
	# Apply special effects
	if effects.has("special_effects"):
		for effect in effects.special_effects:
			if not base_stats.special_effects.has(effect):
				base_stats.special_effects.append(effect)
	
	# Update visuals based on upgrades
	update_appearance()
	
	print("Applied ", upgrade.name, " upgrade to DartTower (cost: ", upgrade.cost, ")")

func update_appearance() -> void:
	# Update the tower's appearance based on its upgrades
	# This would involve changing sprites/models based on the highest upgrade level
	var sprite = $Sprite2D
	if not sprite:
		print("Warning: Sprite2D not found for appearance update")
		return
	
	# Example color changes based on highest upgrade path
	var path1_level = upgrade_paths.path1.level
	var path2_level = upgrade_paths.path2.level
	var path3_level = upgrade_paths.path3.level
	
	if path1_level >= 3:  # Spike-o-pult and above
		sprite.modulate = Color(0.8, 0.4, 0.4)  # Reddish
	elif path2_level >= 3:  # Triple Darts and above
		sprite.modulate = Color(0.4, 0.8, 0.4)  # Greenish
	elif path3_level >= 3:  # Crossbow and above
		sprite.modulate = Color(0.4, 0.4, 0.8)  # Bluish 
	else:
		sprite.modulate = Color(1, 1, 1)  # Default color
	
	# Update collision shape for new range
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = range * base_stats.range_multiplier
	
	# Force redraw to update the range visualization
	queue_redraw() 
