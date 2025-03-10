extends "res://scenes/Enemy/base_enemy.gd"

func _ready():
	super._ready()
	# Purple enemies have special abilities
	speed = base_speed * 1.2
	health = base_health * 1.8
	is_immune_to_splash = true  # Immune to splash damage
	can_split = true  # Splits into two enemies when destroyed
	money_value = 5  # Worth more due to special abilities

func on_death():
	if can_split:
		# Spawn two smaller purple enemies
		var enemy1 = duplicate()
		var enemy2 = duplicate()
		enemy1.scale *= 0.7
		enemy2.scale *= 0.7
		enemy1.health = health * 0.5
		enemy2.health = health * 0.5
		enemy1.can_split = false
		enemy2.can_split = false
		get_parent().add_child(enemy1)
		get_parent().add_child(enemy2)
		enemy1.global_position = global_position + Vector2(10, 0)
		enemy2.global_position = global_position + Vector2(-10, 0)
	super.on_death() 
