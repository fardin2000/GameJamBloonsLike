extends BaseEnemy
class_name RedEnemy

func _ready() -> void:
	base_health = 1
	base_speed = 100.0
	base_armor = 0
	base_damage = 1
	super._ready() 