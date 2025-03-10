extends "res://scenes/Enemy/base_enemy.gd"

func _ready():
	super._ready()
	# Blue enemies are faster but weaker
	speed = base_speed * 1.5
	health = base_health * 0.8
	points_value = 2  # Worth more points due to speed 