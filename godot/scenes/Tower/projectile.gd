extends Area2D

var speed: float = 400.0
var damage: int = 1
var pierce: int = 1
var direction: Vector2 = Vector2.ZERO
var origin_pos: Vector2
var max_range: float = 150.0  # This should match the tower's range
var hit_targets: Array = []

func _ready() -> void:
	origin_pos = global_position

func set_target(enemy: Node2D) -> void:
	# Calculate initial direction towards the target
	direction = (enemy.global_position - global_position).normalized()

func _process(delta: float) -> void:
	# Move in the set direction
	global_position += direction * speed * delta
	
	# Check if we've gone too far from origin
	if global_position.distance_to(origin_pos) > max_range:
		queue_free()
		return
	
	# Check for collisions with enemies
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies") and not hit_targets.has(body):
			hit_target(body)
			if hit_targets.size() >= pierce:
				queue_free()
				return

func hit_target(enemy: Node2D) -> void:
	# Apply damage to the enemy
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	hit_targets.append(enemy)
	# Note: We don't search for new targets anymore - projectile continues on its path
