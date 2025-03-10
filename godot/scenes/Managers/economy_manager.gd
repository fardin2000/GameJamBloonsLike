extends Node
class_name EconomyManager

signal money_changed(new_amount)
signal purchase_failed(item_type, cost)
signal purchase_successful(item_type, cost)

# Starting money amount
@export var starting_money: int = 650

# Current player money
var money: int = starting_money

# Reference to build manager
var build_manager: BuildManager = null

func _enter_tree() -> void:
	add_to_group("EconomyManager")

func _ready() -> void:
	# Find the build manager
	await get_tree().process_frame
	build_manager = get_tree().get_first_node_in_group("BuildManager")
	print("EconomyManager initialized. Found build manager: ", build_manager != null)
	
	# Connect to all existing enemies
	_connect_to_enemies()
	
	# Connect to the round manager to detect when new enemies are spawned
	var round_manager = get_tree().get_first_node_in_group("RoundManager")
	if round_manager and round_manager.has_signal("enemy_spawned"):
		round_manager.enemy_spawned.connect(_on_enemy_spawned)

# Connect to all existing enemies
func _connect_to_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_signal("defeated") and not enemy.defeated.is_connected(_on_enemy_defeated):
			enemy.defeated.connect(_on_enemy_defeated)

# Handle new enemy spawned
func _on_enemy_spawned(enemy: BaseEnemy) -> void:
	if enemy.has_signal("defeated") and not enemy.defeated.is_connected(_on_enemy_defeated):
		enemy.defeated.connect(_on_enemy_defeated)

# Handle enemy defeated - add money to player
func _on_enemy_defeated(enemy: BaseEnemy) -> void:
	add_money(enemy.money_value)

# Add money to player
func add_money(amount: int) -> void:
	money += amount
	emit_signal("money_changed", money)
	print("Player money increased by ", amount, ". New total: ", money)

# Check if player can afford an item
func can_afford(cost: int) -> bool:
	return money >= cost

# Try to purchase a tower
func try_purchase_tower(tower_type: String) -> bool:
	if not build_manager:
		print("Error: Build manager not found!")
		return false
	
	var tower_info = build_manager.get_tower_info(tower_type)
	if tower_info.is_empty():
		print("Error: Tower type not found: ", tower_type)
		return false
	
	var cost = tower_info.cost
	
	if can_afford(cost):
		money -= cost
		emit_signal("money_changed", money)
		emit_signal("purchase_successful", tower_type, cost)
		print("Tower purchased: ", tower_type, " for ", cost, ". Money remaining: ", money)
		return true
	else:
		emit_signal("purchase_failed", tower_type, cost)
		print("Cannot afford tower: ", tower_type, " (cost: ", cost, ", money: ", money, ")")
		return false

# Try to purchase a tower upgrade
func try_purchase_upgrade(tower: BaseTower, upgrade_path: String, level: int, cost: int) -> bool:
	print("EconomyManager.try_purchase_upgrade called for path: ", upgrade_path, ", level: ", level, ", cost: $", cost)
	
	if can_afford(cost):
		print("Can afford upgrade, deducting $", cost, " from player money")
		money -= cost
		emit_signal("money_changed", money)
		emit_signal("purchase_successful", "upgrade_" + upgrade_path + "_" + str(level), cost)
		print("Upgrade purchased for path ", upgrade_path, " level ", level, " for ", cost, ". Money remaining: ", money)
		return true
	else:
		print("Cannot afford upgrade (cost: $", cost, ", money: $", money, ")")
		emit_signal("purchase_failed", "upgrade_" + upgrade_path + "_" + str(level), cost)
		return false

# Get current money
func get_money() -> int:
	return money

# Reset money to starting amount
func reset_money() -> void:
	money = starting_money
	emit_signal("money_changed", money) 