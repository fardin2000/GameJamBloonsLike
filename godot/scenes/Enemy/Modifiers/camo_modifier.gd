extends EnemyModifier
class_name CamoModifier

func _init() -> void:
	type = "camo"

func apply(enemy: BaseEnemy) -> void:
	# Make the enemy slightly transparent to indicate camo status
	enemy.modulate.a = 0.7
	
func remove(enemy: BaseEnemy) -> void:
	# Restore normal visibility
	enemy.modulate.a = 1.0 