extends "res://scenes/Enemy/base_enemy.gd"

func _ready():
	super._ready()
	# Green enemies are tough but slow
	speed = base_speed * 0.8
	health = base_health * 2.0
	money_value = 3  # Worth more money due to toughness 