extends EnemyModifier
class_name RegenModifier

var regen_rate: float = 1.0  # Health per second
var regen_timer: float = 0.0
var regen_interval: float = 1.0  # Time between heals

func _init() -> void:
	type = "regen"

func apply(enemy: BaseEnemy) -> void:
	# Add a visual effect or indicator for regen status
	enemy.modulate = Color(1.0, 0.8, 0.8)  # Slight pink tint

func remove(enemy: BaseEnemy) -> void:
	# Remove visual effects
	enemy.modulate = Color.WHITE

func update(enemy: BaseEnemy, delta: float) -> void:
	regen_timer += delta
	if regen_timer >= regen_interval:
		regen_timer = 0.0
		if enemy.health < enemy.base_health:
			enemy.health += regen_rate 
