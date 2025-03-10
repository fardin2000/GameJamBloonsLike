extends "res://scenes/Enemy/base_enemy.gd"

func _ready():
	super._ready()
	# Yellow enemies are fast and tough
	speed = base_speed * 1.3
	health = base_health * 1.5
	damage_resistance = 0.2  # 20% damage resistance
	money_value = 4  # Worth more due to challenge 