extends Resource
class_name EnemyModifier

# The type of modifier (e.g. "camo", "regen", etc.)
var type: String = ""

# Called when the modifier is first applied to an enemy
func apply(enemy: BaseEnemy) -> void:
	pass

# Called when the modifier is removed from an enemy
func remove(enemy: BaseEnemy) -> void:
	pass

# Called every frame to update the modifier's effect
func update(enemy: BaseEnemy, delta: float) -> void:
	pass 
