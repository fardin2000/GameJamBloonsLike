extends Node2D

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay
@onready var build_manager = $BuildManager
@onready var round_manager = $RoundManager
@onready var spawner = $Spawner
@onready var camera = $Camera2D
@onready var store = $UI/Store
@onready var economy_manager = $EconomyManager
@onready var conversation_overlay = $UI/ConversationOverlay

var camera_pan_speed: float = 500.0
var is_panning_camera: bool = false
var target_camera_position: Vector2

func _ready() -> void:
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)
	
	# Set up the conversation overlay
	if conversation_overlay:
		print("ingame_scene: Found conversation_overlay, connecting to round_manager")
		if round_manager:
			round_manager.conversation_overlay = conversation_overlay
			conversation_overlay.visible = false
			print("ingame_scene: Successfully connected conversation_overlay to round_manager")
		else:
			push_error("ingame_scene: round_manager is null when connecting conversation_overlay")
	else:
		push_error("ingame_scene: conversation_overlay is null - check if $UI/ConversationOverlay path is correct")
		# Try to find it with a more generic search
		var potential_overlay = get_tree().get_first_node_in_group("ConversationOverlay")
		if potential_overlay:
			print("ingame_scene: Found conversation overlay via group instead, connecting it")
			round_manager.conversation_overlay = potential_overlay
			potential_overlay.visible = false
	
	# Connect wave system signals
	spawner.wave_enemies_defeated.connect(round_manager.on_wave_enemies_defeated)
	round_manager.wave_started.connect(_on_wave_started)
	round_manager.wave_completed.connect(_on_wave_completed)
	round_manager.all_waves_completed.connect(_on_all_waves_completed)
	round_manager.mission_transition_needed.connect(_on_mission_transition_needed)
	
	# Wait for one frame to ensure all nodes are fully initialized
	call_deferred("_setup_towers")
	
	# Create some example waves for testing
	# round_manager.create_example_waves()
	
	# Connect economy signals if needed
	if economy_manager:
		print("Economy manager initialized with starting money: ", economy_manager.get_money())
		# You can add specific connections here if needed
	else:
		push_error("Economy manager not found!")

# Set up tower assignments after everything is initialized
func _setup_towers() -> void:
	# Set up tower assignments in the store
	if store:
		print("Setting up tower assignments...")
		
		# Try both methods to make sure one works
		
		# Method 1: Use the assign_tower_to_button method (uses dictionary lookup)
		store.assign_tower_to_button("TowerBear", "DartTower")
		
		# Method 2: Use the direct connection method (more reliable for finding buttons)
		store.connect_button("TowerBear", "DartTower")
		
		# You can add more towers here as needed
		# store.connect_button("TowerSniper", "SniperTower")
	else:
		push_error("Store not found!")

func _process(delta: float) -> void:
	if is_panning_camera:
		var direction = (target_camera_position - camera.position).normalized()
		camera.position += direction * camera_pan_speed * delta
		
		if camera.position.distance_to(target_camera_position) < 10:
			camera.position = target_camera_position
			is_panning_camera = false

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())

func _on_wave_started(wave_index: int) -> void:
	print("Wave ", wave_index + 1, " started!")
	
func _on_wave_completed(wave_index: int) -> void:
	print("Wave ", wave_index + 1, " completed!")
	
func _on_all_waves_completed() -> void:
	print("All waves completed! Moving to next area...")
	# Pan camera to the right for next level
	target_camera_position = camera.position + Vector2(1280, 0)  # Assuming 1280x720 resolution
	is_panning_camera = true

func _on_mission_transition_needed() -> void:
	print("Mission transition needed!")
	# Implement mission transition logic here
