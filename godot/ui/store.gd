extends Control

signal tower_selected(tower_type)

# Dictionary to store tower data: key is button name, value is tower type string
var tower_buttons = {}

# Reference to the BuildManager
var build_manager
# Reference to the currently selected tower
var selected_tower: BaseTower = null
# Reference to the economy manager
var economy_manager: EconomyManager = null
# Reference to the round manager
var round_manager = null

func _ready():
	# Find the BuildManager
	build_manager = get_tree().get_first_node_in_group("BuildManager")
	if not build_manager:
		push_error("BuildManager not found!")
		return
	
	# Find the economy manager
	economy_manager = get_tree().get_first_node_in_group("EconomyManager")
	if not economy_manager:
		push_error("EconomyManager not found!")
	
	# Find the round manager
	round_manager = get_tree().get_first_node_in_group("RoundManager")
	if not round_manager:
		push_error("RoundManager not found!")
	
	# Connect all button signals
	_connect_buttons()
	
	# Add to groups for easier access
	add_to_group("Store")
	add_to_group("UI")
	
	# Configure UI to capture input
	_configure_ui_input()
	
	# Connect start button
	_connect_start_button()
	
	# Debug: print all descendant nodes to verify button detection
	print("Store hierarchy:")
	_print_node_hierarchy(self, 0)
	
	# Debug: print all buttons found
	print("All buttons in store:")
	_find_all_buttons(self)
	
	# Schedule delayed initialization of upgrade buttons
	# This ensures the UI is fully initialized before connecting signals
	get_tree().create_timer(0.5).timeout.connect(_delayed_setup)

# Delayed setup after main initialization
func _delayed_setup():
	print("Running delayed UI setup...")
	
	# Connect upgrade buttons after a delay
	_connect_upgrade_buttons()
	
	# Set upgrade panel to initially hidden
	var upgrade_store = $StoreContainer/UpgradeStore
	if upgrade_store:
		upgrade_store.visible = false

# Configure UI to properly handle input
func _configure_ui_input():
	# Set the upgrade store to stop mouse input propagation
	var upgrade_store = $StoreContainer/UpgradeStore
	if upgrade_store:
		print("Configuring UI mouse filters for UpgradeStore panel")
		upgrade_store.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# First set all direct children to stop
		for child in upgrade_store.get_children():
			if child is Control:
				child.mouse_filter = Control.MOUSE_FILTER_STOP
				print("Set mouse filter on ", child.name)
		
		# Make sure all buttons are properly configured
		var buttons = _find_all_buttons_in_node(upgrade_store)
		for button in buttons:
			_make_button_robust(button)
			print("Configured button: ", button.name)
			
		print("Found and configured ", buttons.size(), " buttons in the upgrade store")

# Find all buttons in a node
func _find_all_buttons_in_node(node):
	var buttons = []
	_find_buttons_recursive(node, buttons)
	return buttons

# Recursively find all buttons
func _find_buttons_recursive(node, buttons):
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		_find_buttons_recursive(child, buttons)

# Recursively set mouse filter on all Controls
func _set_mouse_filter_recursive(node, filter):
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = filter
		
		_set_mouse_filter_recursive(child, filter)

# Make sure buttons are still clickable
func _ensure_buttons_clickable(node):
	for child in node.get_children():
		if child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			
			# Make sure the button has a proper appearance
			if child.text.is_empty() and child.icon == null:
				# If the button has no text or icon, add a default appearance
				child.text = "Upgrade"
			
			print("Made button clickable: ", child.name)
		
		_ensure_buttons_clickable(child)

# Connect upgrade buttons for each path
func _connect_upgrade_buttons():
	# Make a direct reference to path 1 upgrade button
	var path1_button = $StoreContainer/UpgradeStore/VBoxContainer/Upgrade1/NextUpgrade/Button
	if path1_button:
		# Safe disconnection of previous signals
		if path1_button.pressed.get_connections().size() > 0:
			# Recreate the button to clear all signals
			var parent = path1_button.get_parent()
			var old_size = path1_button.size
			var old_position = path1_button.position
			var old_text = path1_button.text
			var old_icon = path1_button.icon
			var old_min_size = path1_button.custom_minimum_size
			
			path1_button.queue_free()
			path1_button = Button.new()
			path1_button.name = "Button"
			path1_button.size = old_size
			path1_button.position = old_position
			path1_button.text = old_text
			path1_button.icon = old_icon
			path1_button.custom_minimum_size = old_min_size
			parent.add_child(path1_button)
		
		# Make button more robust
		_make_button_robust(path1_button)
		
		# Connect signal with direct binding
		path1_button.pressed.connect(func(): _on_upgrade_path1_direct())
		print("Upgrade path 1 button connected successfully with size: ", path1_button.size)
	else:
		push_error("Could not find path 1 upgrade button!")
	
	# Make a direct reference to path 2 upgrade button
	var path2_button = $StoreContainer/UpgradeStore/VBoxContainer/Upgrade2/NextUpgrade/Button
	if path2_button:
		# Safe disconnection of previous signals
		if path2_button.pressed.get_connections().size() > 0:
			# Recreate the button to clear all signals
			var parent = path2_button.get_parent()
			var old_size = path2_button.size
			var old_position = path2_button.position
			var old_text = path2_button.text
			var old_icon = path2_button.icon
			var old_min_size = path2_button.custom_minimum_size
			
			path2_button.queue_free()
			path2_button = Button.new()
			path2_button.name = "Button"
			path2_button.size = old_size
			path2_button.position = old_position
			path2_button.text = old_text
			path2_button.icon = old_icon
			path2_button.custom_minimum_size = old_min_size
			parent.add_child(path2_button)
		
		# Make button more robust
		_make_button_robust(path2_button)
		
		# Connect signal with direct binding
		path2_button.pressed.connect(func(): _on_upgrade_path2_direct())
		print("Upgrade path 2 button connected successfully with size: ", path2_button.size)
	else:
		push_error("Could not find path 2 upgrade button!")
	
	# Make a direct reference to path 3 upgrade button
	var path3_button = $StoreContainer/UpgradeStore/VBoxContainer/Upgrade3/NextUpgrade/Button
	if path3_button:
		# Safe disconnection of previous signals
		if path3_button.pressed.get_connections().size() > 0:
			# Recreate the button to clear all signals
			var parent = path3_button.get_parent()
			var old_size = path3_button.size
			var old_position = path3_button.position
			var old_text = path3_button.text
			var old_icon = path3_button.icon
			var old_min_size = path3_button.custom_minimum_size
			
			path3_button.queue_free()
			path3_button = Button.new()
			path3_button.name = "Button"
			path3_button.size = old_size
			path3_button.position = old_position
			path3_button.text = old_text
			path3_button.icon = old_icon
			path3_button.custom_minimum_size = old_min_size
			parent.add_child(path3_button)
		
		# Make button more robust
		_make_button_robust(path3_button)
		
		# Connect signal with direct binding
		path3_button.pressed.connect(func(): _on_upgrade_path3_direct())
		print("Upgrade path 3 button connected successfully with size: ", path3_button.size)
	else:
		push_error("Could not find path 3 upgrade button!")
	
	# Connect sell button
	var sell_button = $StoreContainer/UpgradeStore/VBoxContainer/SellContainer/SellButton
	if sell_button:
		# Safe disconnection of previous signals
		if sell_button.pressed.get_connections().size() > 0:
			# Recreate the button to clear all signals
			var parent = sell_button.get_parent()
			var old_size = sell_button.size
			var old_position = sell_button.position
			var old_text = sell_button.text
			var old_icon = sell_button.icon
			var old_min_size = sell_button.custom_minimum_size
			
			sell_button.queue_free()
			sell_button = Button.new()
			sell_button.name = "SellButton"
			sell_button.size = old_size
			sell_button.position = old_position
			sell_button.text = old_text
			sell_button.icon = old_icon
			sell_button.custom_minimum_size = old_min_size
			parent.add_child(sell_button)
		
		# Make button more robust
		_make_button_robust(sell_button)
		
		# Connect signal with direct binding
		sell_button.pressed.connect(func(): _on_sell_tower_direct())
		print("Sell button connected successfully with size: ", sell_button.size)
	else:
		push_error("Could not find sell button!")

# Make a button more robust by ensuring it has proper size and input handling
func _make_button_robust(button):
	# Ensure button has a minimum size
	if button.custom_minimum_size.x < 30 or button.custom_minimum_size.y < 30:
		button.custom_minimum_size = Vector2(30, 30)
	
	# Make sure button has visibility
	button.modulate = Color(1, 1, 1, 1)
	
	# Set button to stop mouse input but be clickable
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Set proper focus properties
	button.focus_mode = Control.FOCUS_CLICK
	
	# Add default text if needed
	if button.text.is_empty() and button.icon == null:
		button.text = "Upgrade"
		
	# Force button to update
	button.update_minimum_size()
	
	# Print button details for debugging
	print("Button ", button.name, " configured - Size: ", button.size, ", Min size: ", button.custom_minimum_size)

# Direct handler for path 1 upgrade - more reliable
func _on_upgrade_path1_direct():
	print("Path 1 upgrade button direct pressed")
	get_viewport().set_input_as_handled()
	
	if not selected_tower:
		push_error("No tower selected!")
		return
	
	print("Upgrading path 1 of tower: ", selected_tower.get_class())
	var success = selected_tower.try_upgrade("path1")
	
	if success:
		print("Path 1 upgrade SUCCESS")
		update_upgrade_ui()
	else:
		print("Path 1 upgrade FAILED")

# Direct handler for path 2 upgrade - more reliable
func _on_upgrade_path2_direct():
	print("Path 2 upgrade button direct pressed")
	get_viewport().set_input_as_handled()
	
	if not selected_tower:
		push_error("No tower selected!")
		return
	
	print("Upgrading path 2 of tower: ", selected_tower.get_class())
	var success = selected_tower.try_upgrade("path2")
	
	if success:
		print("Path 2 upgrade SUCCESS")
		update_upgrade_ui()
	else:
		print("Path 2 upgrade FAILED")

# Direct handler for path 3 upgrade - more reliable
func _on_upgrade_path3_direct():
	print("Path 3 upgrade button direct pressed")
	get_viewport().set_input_as_handled()
	
	if not selected_tower:
		push_error("No tower selected!")
		return
	
	print("Upgrading path 3 of tower: ", selected_tower.get_class())
	var success = selected_tower.try_upgrade("path3")
	
	if success:
		print("Path 3 upgrade SUCCESS")
		update_upgrade_ui()
	else:
		print("Path 3 upgrade FAILED")

# Direct handler for selling - more reliable
func _on_sell_tower_direct():
	print("Sell button direct pressed")
	get_viewport().set_input_as_handled()
	
	if not selected_tower:
		push_error("No tower selected!")
		return
	
	print("Selling tower: ", selected_tower.get_class())
	
	# Calculate sell price
	var sell_price = calculate_sell_price()
	
	# Add money to player's account
	if economy_manager:
		economy_manager.add_money(sell_price)
		print("Tower sold for $", sell_price)
	
	# Remove the tower from the scene
	selected_tower.queue_free()
	
	# Deselect the tower
	select_tower(null)

# Find and print all buttons in the store (not just Tower* ones)
func _find_all_buttons(node):
	for child in node.get_children():
		if child is Button:
			print("- Button found: ", child.name)
		_find_all_buttons(child)

# Print full node hierarchy for debugging
func _print_node_hierarchy(node, indent):
	var spaces = ""
	for i in range(indent):
		spaces += "  "
	
	print(spaces + "- " + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		_print_node_hierarchy(child, indent + 1)

# Connect to all tower buttons' pressed signals
func _connect_buttons():
	var buttons = get_tower_buttons()
	print("Found ", buttons.size(), " tower buttons")
	
	for button in buttons:
		print("Connecting button: ", button.name)
		button.pressed.connect(_on_tower_button_pressed.bind(button))

# Get all tower buttons in the store (searching all descendants)
func get_tower_buttons():
	var buttons = []
	_find_tower_buttons(self, buttons)
	return buttons

# Recursively find all buttons that start with "Tower"
func _find_tower_buttons(node, buttons):
	for child in node.get_children():
		if child is Button and child.name.begins_with("Tower"):
			buttons.append(child)
		_find_tower_buttons(child, buttons)

# Alternative way to manually connect a specific button by name
func connect_button(button_name, tower_type):
	var button = _find_button_by_name(self, button_name)
	if button:
		print("Manually connecting button: ", button.name, " to tower type: ", tower_type)
		# Disconnect any existing connections first to avoid duplicates
		if button.pressed.is_connected(_on_tower_button_pressed):
			button.pressed.disconnect(_on_tower_button_pressed)
		
		# Connect the button press signal
		button.pressed.connect(func(): _on_specific_tower_button_pressed(button_name, tower_type))
		return true
	else:
		push_error("Could not find button: " + button_name)
		return false

# Handler for manually connected buttons
func _on_specific_tower_button_pressed(button_name, tower_type):
	print("Specific button pressed: ", button_name, " with tower type: ", tower_type)
	
	if build_manager:
		print("Initiating build mode with tower type: ", tower_type)
		build_manager.initiate_build_mode(tower_type)
		emit_signal("tower_selected", tower_type)
	else:
		push_error("BuildManager not available for tower placement")

# Assign a tower type to a specific button
func assign_tower_to_button(button_name, tower_type):
	print("Assigning tower type '", tower_type, "' to button '", button_name, "'")
	
	# First try direct node path
	if has_node(button_name):
		tower_buttons[button_name] = tower_type
		print("Tower assigned successfully to button: " + button_name)
		return
	
	# If not found directly, search all descendants
	var button = _find_button_by_name(self, button_name)
	if button:
		tower_buttons[button_name] = tower_type
		print("Tower assigned successfully to found button: " + button_name)
	else:
		push_error("Button %s not found in store UI" % button_name)
		print("Available buttons: ", get_tower_buttons_names())

# Get a list of all connected tower button names
func get_tower_buttons_names():
	var names = []
	for button in get_tower_buttons():
		names.append(button.name)
	return names

# Recursively search for a button by name
func _find_button_by_name(node, button_name):
	if node.name == button_name and node is Button:
		return node
	
	for child in node.get_children():
		var result = _find_button_by_name(child, button_name)
		if result:
			return result
	
	return null

# Handle tower button press event
func _on_tower_button_pressed(button):
	print("Button pressed: ", button.name)
	
	var tower_type = tower_buttons.get(button.name)
	print("Tower type for button: ", tower_type)
	
	if not tower_type:
		push_error("No tower assigned to button: " + button.name)
		print("Current button assignments: ", tower_buttons)
		return
	
	# Start build mode with the selected tower type
	if build_manager:
		print("Initiating build mode with tower type: ", tower_type)
		build_manager.initiate_build_mode(tower_type)
		emit_signal("tower_selected", tower_type)
	else:
		push_error("BuildManager not available for tower placement")

# Cancel building mode (can be called from outside, e.g. escape key pressed)
func cancel_build_mode():
	if build_manager:
		build_manager.cancel_build_mode()

# Called by BuildManager when a tower is selected in the game world
func select_tower(tower):
	# Set the currently selected tower
	selected_tower = tower
	
	# Get the upgrade store panel
	var upgrade_store = $StoreContainer/UpgradeStore
	
	if tower:
		# Show the upgrade panel if a tower is selected
		upgrade_store.visible = true
		
		# Update the upgrade UI elements
		update_upgrade_ui()
	else:
		# Hide the upgrade panel if no tower is selected
		upgrade_store.visible = false

# Update the upgrade UI to reflect the currently selected tower
func update_upgrade_ui():
	print("Updating upgrade UI...")
	
	if not selected_tower:
		print("Cannot update UI: No tower selected")
		return
	
	# Update tower name
	var tower_name_label = $StoreContainer/UpgradeStore/VBoxContainer/TowerName
	if tower_name_label:
		tower_name_label.text = selected_tower.get_class()
		print("Tower name updated: ", tower_name_label.text)
	
	# Update path 1 upgrade information
	update_path_ui("path1", 1)
	
	# Update path 2 upgrade information
	update_path_ui("path2", 2)
	
	# Update path 3 upgrade information
	update_path_ui("path3", 3)
	
	# Update sell information
	var sell_price_label = $StoreContainer/UpgradeStore/VBoxContainer/SellContainer/IconAndPrice/SellPrice
	if sell_price_label:
		# Calculate sell price (typically 80% of total investment)
		var sell_price = calculate_sell_price()
		sell_price_label.text = "$" + str(sell_price)
		print("Sell price updated: ", sell_price_label.text)
	
	print("UI update complete.")

# Calculate the sell price for the selected tower (80% of total investment)
func calculate_sell_price():
	if not selected_tower:
		return 0
	
	var base_cost = 0
	
	# Get the tower type from the tower's class
	var tower_type = selected_tower.get_class()
	
	# Find the base cost from the BuildManager
	if build_manager:
		var tower_info = build_manager.get_tower_info(tower_type)
		if not tower_info.is_empty():
			base_cost = tower_info.cost
	
	# Add up upgrade costs
	var upgrade_cost = 0
	for path in ["path1", "path2", "path3"]:
		var path_level = selected_tower.upgrade_paths[path].level
		for i in range(path_level):
			var upgrade = selected_tower.upgrade_paths[path].upgrades[i]
			upgrade_cost += upgrade.cost
	
	# Apply 80% refund rate
	return int((base_cost + upgrade_cost) * 0.8)

# Update the UI for a specific upgrade path
func update_path_ui(path: String, path_number: int):
	print("Updating UI for path ", path_number, "...")
	
	# Check if the tower has this path information
	if not selected_tower.upgrade_paths.has(path):
		push_error("Selected tower does not have upgrade path: " + path)
		return
	
	var path_info = selected_tower.upgrade_paths[path]
	var current_level = path_info.level
	print("Current level for path ", path_number, ": ", current_level)
	print("Upgrade path has ", path_info.upgrades.size(), " upgrades defined")
	
	# Get container references
	var path_container = $StoreContainer/UpgradeStore/VBoxContainer.get_node("Upgrade" + str(path_number))
	if not path_container:
		push_error("Could not find upgrade container for path " + str(path_number))
		return
	
	# Get references to UI elements
	var next_name_label = path_container.get_node_or_null("NextUpgrade/NextUpgradeName")
	var next_cost_label = path_container.get_node_or_null("NextUpgrade/Cost")
	var next_button = path_container.get_node_or_null("NextUpgrade/Button")
	var prev_name_label = path_container.get_node_or_null("PrevUpgrade/PrevUpgradeName")
	var owned_label = path_container.get_node_or_null("PrevUpgrade/Owned")
	
	if not next_name_label or not next_cost_label or not next_button or not prev_name_label or not owned_label:
		push_error("Could not find all UI elements for path " + str(path_number))
		return
	
	# Get the previous and next upgrade containers
	var prev_container = path_container.get_node_or_null("PrevUpgrade")
	var next_container = path_container.get_node_or_null("NextUpgrade")
	
	if not prev_container or not next_container:
		push_error("Could not find previous or next upgrade containers for path " + str(path_number))
		return
	
	# Update UI for the previous upgrade (the one we own)
	if current_level > 0 and path_info.upgrades.size() >= current_level:
		var current_upgrade = path_info.upgrades[current_level - 1]
		prev_name_label.text = current_upgrade.name
		owned_label.visible = true
		prev_container.visible = true
		print("Path ", path_number, " has previous upgrade: ", current_upgrade.name)
	else:
		prev_name_label.text = "None"
		owned_label.visible = false
		prev_container.visible = false
		print("Path ", path_number, " has no previous upgrades")
	
	# Update UI for the next upgrade (the one we can buy)
	if current_level < path_info.max_level and path_info.upgrades.size() > current_level:
		var next_upgrade = path_info.upgrades[current_level]
		next_name_label.text = next_upgrade.name
		next_cost_label.text = "$" + str(next_upgrade.cost)
		print("Path ", path_number, " next upgrade: ", next_upgrade.name, " (Cost: $", next_upgrade.cost, ")")
		
		# Enable or disable the button based on affordability
		var can_afford = economy_manager and economy_manager.can_afford(next_upgrade.cost)
		next_button.disabled = not can_afford
		print("Can afford upgrade: ", can_afford, " (Button ", "enabled" if not next_button.disabled else "disabled", ")")
		
		next_container.visible = true
	else:
		# Max level reached, hide next upgrade section
		next_container.visible = false
		print("Path ", path_number, " at max level or no more upgrades defined")
	
	# Update unlocked level indicators
	for i in range(1, 6):  # There are 5 potential upgrades
		var light = path_container.get_node_or_null("UpgradeLights/Unlock" + str(i))
		if light:
			if i <= current_level:
				light.color = Color.YELLOW  # Unlocked
			else:
				light.color = Color(0.08, 0.08, 0.08)  # Locked
		else:
			push_error("Could not find level indicator " + str(i) + " for path " + str(path_number))
	
	print("UI update for path ", path_number, " complete.")

# Direct access to the tower_buttons dictionary for debugging
func get_tower_buttons_dict():
	return tower_buttons

# Override default input handling to make sure button clicks are detected
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if we have the upgrade store visible and a tower selected
		var upgrade_store = $StoreContainer/UpgradeStore
		if selected_tower and upgrade_store and upgrade_store.visible:
			# Check if clicked on any upgrade buttons
			var buttons = _find_all_buttons_in_node(upgrade_store)
			for button in buttons:
				# Check if the button is visible and not disabled
				if button.visible and not button.disabled:
					# Use the built-in get_global_rect method
					if button.get_global_rect().has_point(event.global_position):
						print("Button click detected on: ", button.name)
						# Manually trigger the pressed signal
						button.emit_signal("pressed")
						get_viewport().set_input_as_handled()
						return

# Connect the start button to start waves
func _connect_start_button():
	var start_button = $StoreContainer/TowerStore/VBoxContainer/Button
	if start_button:
		print("Found start button, connecting it")
		
		# Disconnect any existing connections
		for connection in start_button.pressed.get_connections():
			start_button.pressed.disconnect(connection["callable"])
		
		# Connect to our start wave function
		start_button.pressed.connect(_on_start_button_pressed)
	else:
		push_error("Could not find start button!")

# Handler for start button press
func _on_start_button_pressed():
	print("Start button pressed!")
	if round_manager:
		print("Starting next wave")
		var result = round_manager.start_next_wave()
		
		if result:
			print("Wave started successfully")
		else:
			print("Failed to start wave - might already be in progress")
	else:
		push_error("Cannot start wave: RoundManager not found!")
