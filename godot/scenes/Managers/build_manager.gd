extends Node2D
class_name BuildManager

# BuildManager Variables
var build_mode: bool = false
var tower_preview: Node2D = null
var selected_tower_type: String = ""
var selected_tower: BaseTower = null

# Tower definitions
var tower_types = {
	"DartTower": {
		"scene": preload("res://scenes/Tower/DartTower.tscn"),
		"cost": 200,
		"description": "Basic tower that shoots darts at bloons. Can be upgraded for better pierce, speed, or range."
	}
	# Add more tower types here as they are created
}

# Reference to the store
var tower_store: Control = null

# Reference to the economy manager
var economy_manager: EconomyManager = null

func _enter_tree() -> void:
	add_to_group("BuildManager")

func _ready() -> void:
	# Find the tower store
	await get_tree().process_frame
	tower_store = get_tree().get_first_node_in_group("Store")
	
	# Find the economy manager
	economy_manager = get_tree().get_first_node_in_group("EconomyManager")
	
	print("BuildManager initialized. Found store: ", tower_store != null, ", economy manager: ", economy_manager != null)

func initiate_build_mode(tower_type: String) -> void:
	if not tower_types.has(tower_type):
		print("Tower type not found: ", tower_type)
		return
		
	# Check if player can afford the tower
	if economy_manager and not economy_manager.can_afford(tower_types[tower_type].cost):
		print("Cannot afford tower: ", tower_type, " (cost: ", tower_types[tower_type].cost, ")")
		return
		
	print("Initiating build mode with tower type: ", tower_type)
	build_mode = true
	selected_tower_type = tower_type
	
	# Deselect any currently selected tower
	deselect_tower()
	
	# Instance the preview tower from the selected type
	tower_preview = tower_types[tower_type].scene.instantiate()
	tower_preview.modulate = Color(1, 1, 1, 0.5)
	tower_preview.process_mode = Node.PROCESS_MODE_DISABLED  # Disable processing for preview
	tower_preview.set("is_preview", true)  # Use set() instead of direct assignment
	get_tree().current_scene.add_child(tower_preview)
	
	# Initialize the preview position to the current mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	var world_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	tower_preview.global_position = world_pos
	print("Initial tower preview position: ", world_pos)

# Input handling is done here, assuming BuildManager is always active.
func _unhandled_input(event: InputEvent) -> void:
	pass  # We'll use _input instead

# Process mouse input for better reliability
func _input(event: InputEvent) -> void:
	if build_mode:
		if event is InputEventMouseButton:
			print("Mouse button in build mode: ", event.button_index, " pressed: ", event.pressed)
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				print("Left click detected - trying to place tower")
				# Place tower on left click
				place_tower(tower_preview.global_position)
				cancel_build_mode()
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				# Cancel build mode on right click
				print("Right-click detected, cancelling build mode")
				cancel_build_mode()
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Skip if the input has already been handled (e.g. by UI)
		if event.is_echo() or get_viewport().is_input_handled():
			return
			
		# When not in build mode, check if we clicked on a tower
		var world_pos = get_viewport().get_canvas_transform().affine_inverse() * event.position
		
		# Check if we clicked on a tower using the Area2D overlap detection
		var towers = get_tree().get_nodes_in_group("Tower")
		var clicked_tower = null
		
		for tower in towers:
			# Check if the tower has a Sprite2D child
			var sprite = find_sprite_in_tower(tower)
			if sprite and is_point_inside_sprite(sprite, world_pos):
				clicked_tower = tower
				break
		
		if clicked_tower:
			select_tower(clicked_tower)
		else:
			# Only deselect if the click was not on a UI element
			if not _is_click_on_ui(event.global_position):
				deselect_tower()

# Helper function to find the sprite in a tower
func find_sprite_in_tower(tower: Node) -> Sprite2D:
	# First, check if it has a direct Sprite2D child
	for child in tower.get_children():
		if child is Sprite2D:
			return child
	
	# If not found, recursively check all children
	for child in tower.get_children():
		var result = find_sprite_in_tower(child)
		if result:
			return result
	
	return null

# Helper function to check if a point is inside a sprite
func is_point_inside_sprite(sprite: Sprite2D, point: Vector2) -> bool:
	var sprite_pos = sprite.global_position
	var sprite_size = sprite.texture.get_size() * sprite.scale
	
	# Convert the point to local coordinates
	var local_point = point - sprite_pos
	
	# Check if the point is inside the sprite's bounds
	return (
		abs(local_point.x) <= sprite_size.x / 2 and
		abs(local_point.y) <= sprite_size.y / 2
	)

# Alternative input handling using _process for smoother movement
func _process(delta: float) -> void:
	if build_mode and tower_preview:
		# Update tower position to follow mouse in every frame
		var mouse_pos = get_viewport().get_mouse_position()
		var world_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
		tower_preview.global_position = world_pos

# Instantiate and permanently place the tower at the specified position.
func place_tower(pos: Vector2) -> void:
	# Check if player can afford the tower
	if economy_manager and not economy_manager.try_purchase_tower(selected_tower_type):
		print("Cannot afford tower: ", selected_tower_type)
		return
		
	print("Placing tower of type: ", selected_tower_type, " at position: ", pos)
	
	var tower = tower_types[selected_tower_type].scene.instantiate()
	tower.global_position = pos
	tower.process_mode = Node.PROCESS_MODE_INHERIT  # Enable processing for placed tower
	tower.set("is_preview", false)  # Use set() instead of direct assignment
	
	# Make sure the tower is in the Tower group for selection
	if not tower.is_in_group("Tower"):
		tower.add_to_group("Tower")
	
	# Connect tower selection signal if it exists
	if tower.has_signal("tower_selected"):
		tower.tower_selected.connect(_on_tower_selected)
	else:
		print("Warning: Tower does not have tower_selected signal")
	
	get_tree().current_scene.add_child(tower)
	print("Tower placed successfully")

# Cancel the build mode and remove any preview.
func cancel_build_mode() -> void:
	print("Cancelling build mode")
	build_mode = false
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null

# Get information about a tower type
func get_tower_info(tower_type: String) -> Dictionary:
	if tower_types.has(tower_type):
		return tower_types[tower_type]
	return {}

# Handle tower selection
func select_tower(tower: BaseTower) -> void:
	if build_mode:
		return
	
	# If we already had a selected tower, deselect it
	if selected_tower and selected_tower != tower:
		deselect_tower()
	
	selected_tower = tower
	
	# Highlight the selected tower
	if selected_tower:
		# Mark the tower as selected and show its range by setting _is_mouse_hovering
		selected_tower._is_mouse_hovering = true
		selected_tower.queue_redraw() # Added back to show range when selected
		
		# Update the tower store with the selected tower
		if tower_store:
			tower_store.select_tower(selected_tower)

func deselect_tower() -> void:
	if selected_tower:
		selected_tower._is_mouse_hovering = false
		selected_tower.queue_redraw() # Added back to hide range when deselected
		selected_tower = null
		
		# Clear the selection in the tower store
		if tower_store:
			tower_store.select_tower(null)

# Signal handler for tower selection
func _on_tower_selected(tower: BaseTower) -> void:
	select_tower(tower)

# Check if a click position is on a UI element
func _is_click_on_ui(global_position: Vector2) -> bool:
	# First, check if the click is on a store UI
	if tower_store and tower_store is Control and tower_store.visible:
		# Check if clicked directly on the store
		if tower_store.get_global_rect().has_point(global_position):
			print("Click detected on store UI")
			return true
		
		# Check upgrade panel (most important to handle correctly)
		var upgrade_panel = tower_store.get_node("StoreContainer/UpgradeStore")
		if upgrade_panel and upgrade_panel is Control and upgrade_panel.visible:
			if upgrade_panel.get_global_rect().has_point(global_position):
				print("Click detected on upgrade panel")
				return true
			
			# Also check all buttons in the upgrade panel
			var buttons = _find_all_buttons(upgrade_panel)
			for button in buttons:
				if button.visible and not button.disabled:
					if button.get_global_rect().has_point(global_position):
						print("Click detected on button: ", button.name)
						return true
	
	# Get the UI root (assuming CanvasLayer with UI)
	var ui_elements = get_tree().get_nodes_in_group("UI")
	for ui in ui_elements:
		if ui is Control and ui.visible and ui.get_global_rect().has_point(global_position):
			return true
	
	return false

# Find all buttons in a control
func _find_all_buttons(node) -> Array:
	var buttons = []
	_find_buttons_recursive(node, buttons)
	return buttons

# Recursively find all buttons in a control
func _find_buttons_recursive(node, buttons):
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		_find_buttons_recursive(child, buttons)
