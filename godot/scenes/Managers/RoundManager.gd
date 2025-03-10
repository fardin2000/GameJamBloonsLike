extends Node

const WaveResource = preload("res://resources/Wave.gd")

@export var waves: Array[WaveResource] = []
@export var spawner: Node2D  # Reference to the spawner node
@export var conversation_overlay: Control  # Reference to the ConversationOverlay

# Enemy type preloads
var enemy_types = {
	"red": preload("res://scenes/Enemy/red_enemy.tscn"),
	"blue": preload("res://scenes/Enemy/blue_enemy.tscn"),  # Faster enemy
	"green": preload("res://scenes/Enemy/green_enemy.tscn"),  # Tougher enemy
	"yellow": preload("res://scenes/Enemy/yellow_enemy.tscn"),  # Fast and tough
	"purple": preload("res://scenes/Enemy/purple_enemy.tscn")  # Special abilities
}

var current_wave_index: int = -1
var between_waves_timer: float = 0.0
var is_wave_in_progress: bool = false
var is_ready_for_first_wave: bool = false
var waiting_for_conversation: bool = false
var current_mission: int = 0  # 0 = tutorial, 1 = mission 1, etc.

signal wave_completed(wave_index: int)
signal all_waves_completed
signal wave_started(wave_index: int)
signal mission_transition_needed
signal ready_button_needed

func _ready() -> void:
	# Connect to conversation overlay signals if provided
	if conversation_overlay:
		print("RoundManager: Connecting conversation_completed signal")
		if conversation_overlay.has_signal("conversation_completed"):
			if not conversation_overlay.conversation_completed.is_connected(_on_conversation_completed):
				conversation_overlay.conversation_completed.connect(_on_conversation_completed)
				print("RoundManager: conversation_completed signal connected successfully")
		else:
			push_error("RoundManager: conversation_overlay does not have conversation_completed signal")
		conversation_overlay.visible = false
	else:
		push_error("RoundManager: conversation_overlay is null in _ready")

func _enter_tree() -> void:
	add_to_group("RoundManager")
	setup_tutorial()

func _process(delta: float) -> void:
	if not is_wave_in_progress and is_ready_for_first_wave and not waiting_for_conversation:
		between_waves_timer -= delta
		if between_waves_timer <= 0:
			start_next_wave()

func setup_tutorial() -> void:
	setup_tutorial_waves()

func setup_tutorial_waves() -> void:
	waves.clear()
	
	# Tutorial Wave 1: Simple red enemies to learn targeting
	var tutorial_wave1 = WaveResource.new()
	tutorial_wave1.enemies = [
		{
			"enemy_type": enemy_types.red,
			"count": 5,
			"delay": 2.0  # Slower spawn rate for learning
		} as Dictionary
	] as Array[Dictionary]
	tutorial_wave1.delay_after_wave = 8.0
	
	# Add LONGER conversation to the first tutorial wave (multiple clicks)
	tutorial_wave1.pre_wave_conversation = [
		{
			"character": "Commander",
			"text": "Welcome to your tower defense training session, recruit!"
		} as Dictionary,
		{
			"character": "Instructor",
			"text": "I'll be your instructor today. Our goal is to prepare you for the battlefield ahead."
		} as Dictionary,
		{
			"character": "Instructor", 
			"text": "The basics are simple: enemies will travel along the path, and your job is to stop them."
		} as Dictionary,
		{
			"character": "Recruit",
			"text": "What kind of enemies should I expect in this first wave?"
		} as Dictionary,
		{
			"character": "Instructor",
			"text": "Good question! We'll start with red enemies. They're slow and easy to hit - perfect for beginners."
		} as Dictionary,
		{
			"character": "Commander",
			"text": "Remember your training. Place towers strategically along the path and upgrade them when possible."
		} as Dictionary,
		{
			"character": "Instructor",
			"text": "Are you ready? Let's begin with Wave 1!"
		} as Dictionary
	] as Array[Dictionary]
	
	# Tutorial Wave 2: Mix of red and blue enemies to teach speed differences
	var tutorial_wave2 = WaveResource.new()
	tutorial_wave2.enemies = [
		{
			"enemy_type": enemy_types.red,
			"count": 4,
			"delay": 1.5
		} as Dictionary,
		{
			"enemy_type": enemy_types.blue,
			"count": 2,
			"delay": 1.0
		} as Dictionary,
		{
			"enemy_type": enemy_types.red,
			"count": 2,
			"delay": 1.0,
			"modifiers": ["camo"]
		} as Dictionary
	] as Array[Dictionary]
	tutorial_wave2.delay_after_wave = 8.0
	
	# Add SHORT conversation to the second tutorial wave (single click)
	tutorial_wave2.pre_wave_conversation = [
		{
			"character": "Instructor",
			"text": "Wave 2 incoming! Be prepared for blue enemies - they move faster than the red ones. And watch for camouflaged enemies that some towers can't detect!"
		} as Dictionary
	] as Array[Dictionary]
	
	# Tutorial Wave 3: Introduce green tough enemies and special modifiers
	var tutorial_wave3 = WaveResource.new()
	tutorial_wave3.enemies = [
		{
			"enemy_type": enemy_types.red,
			"count": 6,
			"delay": 1.0
		} as Dictionary,
		{
			"enemy_type": enemy_types.green,
			"count": 2,
			"delay": 1.5
		} as Dictionary,
		{
			"enemy_type": enemy_types.blue,
			"count": 3,
			"delay": 0.8,
			"modifiers": ["regen"]
		} as Dictionary
	] as Array[Dictionary]
	tutorial_wave3.delay_after_wave = 10.0
	
	# Add MEDIUM LENGTH conversation to the third tutorial wave
	tutorial_wave3.pre_wave_conversation = [
		{
			"character": "Commander",
			"text": "Great work on the first two waves!"
		} as Dictionary,
		{
			"character": "Instructor",
			"text": "Wave 3 will be more challenging. We're introducing green enemies - they're more resilient to damage."
		} as Dictionary,
		{
			"character": "Recruit",
			"text": "What about those blue enemies with the strange glow?"
		} as Dictionary,
		{
			"character": "Instructor",
			"text": "Those have the 'regen' modifier - they'll recover health if you don't destroy them quickly. You'll need more firepower or specialized towers to handle them effectively."
		} as Dictionary
	] as Array[Dictionary]

	waves = [tutorial_wave1, tutorial_wave2, tutorial_wave3]

func setup_mission_one_waves() -> void:
	waves.clear()
	
	# Mission 1 Wave 1: Mix of enemies to test player's learning
	var wave1 = WaveResource.new()
	wave1.enemies = [
		{
			"enemy_type": enemy_types.red,
			"count": 10,
			"delay": 0.8
		} as Dictionary,
		{
			"enemy_type": enemy_types.blue,
			"count": 5,
			"delay": 0.6
		} as Dictionary,
		{
			"enemy_type": enemy_types.green,
			"count": 3,
			"delay": 1.0
		} as Dictionary
	] as Array[Dictionary]
	wave1.delay_after_wave = 5.0
	
	# Add conversation to mission 1 wave 1
	wave1.pre_wave_conversation = [
		{
			"character": "Commander",
			"text": "This is your first real mission. The enemies are more numerous and varied now."
		} as Dictionary,
		{
			"character": "Commander",
			"text": "You'll be facing red, blue, and even some green enemies. The green ones are tough, so prepare accordingly."
		} as Dictionary,
		{
			"character": "Advisor",
			"text": "Remember your training. Position your defenses strategically and upgrade when possible."
		} as Dictionary
	] as Array[Dictionary]
	
	# Mission 1 Wave 2: Introduce yellow enemies and more modifiers
	var wave2 = WaveResource.new()
	wave2.enemies = [
		{
			"enemy_type": enemy_types.blue,
			"count": 12,
			"delay": 0.6
		} as Dictionary,
		{
			"enemy_type": enemy_types.yellow,
			"count": 4,
			"delay": 0.8
		} as Dictionary,
		{
			"enemy_type": enemy_types.green,
			"count": 5,
			"delay": 0.7,
			"modifiers": ["regen"]
		} as Dictionary,
		{
			"enemy_type": enemy_types.blue,
			"count": 6,
			"delay": 0.5,
			"modifiers": ["camo"]
		} as Dictionary
	] as Array[Dictionary]
	wave2.delay_after_wave = 5.0

	# Mission 1 Wave 3: Complex wave with all enemy types
	var wave3 = WaveResource.new()
	wave3.enemies = [
		{
			"enemy_type": enemy_types.yellow,
			"count": 8,
			"delay": 0.4
		} as Dictionary,
		{
			"enemy_type": enemy_types.purple,
			"count": 3,
			"delay": 1.0
		} as Dictionary,
		{
			"enemy_type": enemy_types.green,
			"count": 6,
			"delay": 0.3,
			"modifiers": ["regen", "fortified"]
		} as Dictionary,
		{
			"enemy_type": enemy_types.blue,
			"count": 15,
			"delay": 0.2,
			"modifiers": ["camo", "fast"]
		} as Dictionary,
		{
			"enemy_type": enemy_types.yellow,
			"count": 4,
			"delay": 0.5,
			"modifiers": ["camo", "regen"]
		} as Dictionary
	] as Array[Dictionary]
	wave3.delay_after_wave = 10.0
	
	waves = [wave1, wave2, wave3]

func start_next_wave() -> void:
	print("RoundManager: start_next_wave called")
	current_wave_index += 1
	if current_wave_index >= waves.size():
		if current_mission == 0:  # If we're in tutorial
			print("RoundManager: Tutorial complete, transitioning to mission 1")
			emit_signal("mission_transition_needed")  # Signal to transition to Mission 1
			return
		emit_signal("all_waves_completed")
		return
		
	var current_wave = waves[current_wave_index]
	print("RoundManager: Starting wave ", current_wave_index + 1)
	
	# Check if the wave has a conversation to display
	if current_wave.has_conversation() and conversation_overlay:
		_start_wave_conversation(current_wave)
	else:
		_start_wave_spawning(current_wave)

func _start_wave_conversation(wave: WaveResource) -> void:
	print("RoundManager: Starting wave conversation")
	waiting_for_conversation = true
	
	if conversation_overlay:
		if conversation_overlay.has_method("start_conversation"):
			print("RoundManager: Calling start_conversation with %d dialogue entries" % wave.pre_wave_conversation.size())
			conversation_overlay.start_conversation(wave.pre_wave_conversation)
		else:
			push_error("RoundManager: conversation_overlay does not have start_conversation method")
			# Fallback - skip conversation and start wave directly
			waiting_for_conversation = false
			_start_wave_spawning(wave)
	else:
		push_error("RoundManager: conversation_overlay is null in _start_wave_conversation")
		# Fallback - if overlay is missing, just start the wave
		waiting_for_conversation = false
		_start_wave_spawning(wave)

func _on_conversation_completed() -> void:
	print("RoundManager: Conversation completed signal received")
	waiting_for_conversation = false
	
	if current_wave_index >= 0 and current_wave_index < waves.size():
		var current_wave = waves[current_wave_index]
		print("RoundManager: About to call _start_wave_spawning for wave", current_wave_index + 1)
		call_deferred("_start_wave_spawning", current_wave)  # Use call_deferred to avoid potential state issues
	else:
		push_error("RoundManager: Invalid wave index after conversation: %d" % current_wave_index)

func _start_wave_spawning(wave: WaveResource) -> void:
	print("RoundManager: _start_wave_spawning called for wave with", wave.enemies.size(), "enemy types")
	
	if is_wave_in_progress:
		print("RoundManager: Warning - wave already in progress when trying to start spawning")
	
	is_wave_in_progress = true
	
	if spawner == null:
		push_error("RoundManager: spawner is null in _start_wave_spawning")
		# Try to find the spawner as a fallback
		spawner = get_tree().get_first_node_in_group("Spawner")
		if spawner == null:
			push_error("RoundManager: Could not find spawner through group either")
			return
	
	# Debug the spawner connection
	print("RoundManager: Spawner =", spawner, "has_method('start_wave') =", spawner.has_method("start_wave"))
	
	# Start the wave
	spawner.start_wave(wave)
	print("RoundManager: Emitting wave_started signal for wave", current_wave_index + 1)
	emit_signal("wave_started", current_wave_index)
	
	# Set a safety timer in case spawner doesn't work
	_setup_safety_timer()

# Safety timer to make sure the wave eventually completes even if spawning fails
func _setup_safety_timer() -> void:
	var safety_timer = Timer.new()
	add_child(safety_timer)
	safety_timer.wait_time = 10.0  # 10 seconds safety timeout
	safety_timer.one_shot = true
	safety_timer.timeout.connect(_on_safety_timer_timeout)
	safety_timer.start()
	print("RoundManager: Started safety timer for wave", current_wave_index + 1)

func _on_safety_timer_timeout() -> void:
	if is_wave_in_progress:
		print("RoundManager: Safety timer triggered - wave didn't complete normally")
		on_wave_enemies_defeated()  # Force wave completion

func on_ready_button_pressed() -> void:
	print("RoundManager: Ready button pressed")
	print("RoundManager: is_ready_for_first_wave:", is_ready_for_first_wave)
	print("RoundManager: waiting_for_conversation:", waiting_for_conversation)
	print("RoundManager: current_wave_index:", current_wave_index)
	is_ready_for_first_wave = true
	start_next_wave()

func on_wave_enemies_defeated() -> void:
	print("Wave ", current_wave_index + 1, " completed")
	is_wave_in_progress = false
	var current_wave = waves[current_wave_index]
	between_waves_timer = current_wave.delay_after_wave
	emit_signal("wave_completed", current_wave_index)

func transition_to_mission_one() -> void:
	current_mission = 1
	current_wave_index = -1
	is_wave_in_progress = false
	is_ready_for_first_wave = false
	waiting_for_conversation = false
	setup_mission_one_waves()
	is_ready_for_first_wave = true
	start_next_wave()

# Example of creating waves with different enemy types and modifiers
func create_example_waves() -> void:
	var red_enemy = preload("res://scenes/Enemy/red_enemy.tscn")
	
	# Wave 1: Simple red bloons with SHORT conversation
	var wave1 = WaveResource.new()
	wave1.enemies = [
		{
			"enemy_type": red_enemy,
			"count": 10,
			"delay": 1.0
		} as Dictionary
	] as Array[Dictionary]
	wave1.delay_after_wave = 5.0
	wave1.pre_wave_conversation = [
		{
			"character": "System",
			"text": "Wave 1: 10 red enemies approaching!"
		} as Dictionary
	] as Array[Dictionary]
	
	# Wave 2: Red bloons with some camo and MEDIUM conversation
	var wave2 = WaveResource.new()
	wave2.enemies = [
		{
			"enemy_type": red_enemy,
			"count": 5,
			"delay": 1.0
		} as Dictionary,
		{
			"enemy_type": red_enemy,
			"count": 3,
			"delay": 0.5,
			"modifiers": ["camo"]
		} as Dictionary
	] as Array[Dictionary]
	wave2.delay_after_wave = 5.0
	wave2.pre_wave_conversation = [
		{
			"character": "Advisor",
			"text": "Our scouts report another wave approaching."
		} as Dictionary,
		{
			"character": "Advisor",
			"text": "This time they have some camouflaged units. Make sure your defenses can detect them!"
		} as Dictionary,
		{
			"character": "System",
			"text": "Wave 2: 5 standard enemies and 3 camouflaged enemies incoming!"
		} as Dictionary
	] as Array[Dictionary]
	
	# Wave 3: Mixed red bloons with regen and camo and LONGER conversation
	var wave3 = WaveResource.new()
	wave3.enemies = [
		{
			"enemy_type": red_enemy,
			"count": 10,
			"delay": 0.5
		} as Dictionary,
		{
			"enemy_type": red_enemy,
			"count": 5,
			"delay": 0.3,
			"modifiers": ["regen"]
		} as Dictionary,
		{
			"enemy_type": red_enemy,
			"count": 3,
			"delay": 0.2,
			"modifiers": ["camo", "regen"]
		} as Dictionary
	] as Array[Dictionary]
	wave3.delay_after_wave = 10.0
	wave3.pre_wave_conversation = [
		{
			"character": "Commander",
			"text": "Final test wave approaching! This is the most challenging yet."
		} as Dictionary,
		{
			"character": "Advisor",
			"text": "Intelligence reports show a mix of standard, regenerating, and camouflaged enemies."
		} as Dictionary,
		{
			"character": "Technician",
			"text": "I've analyzed the data. Some enemies have multiple modifiers - they can both regenerate AND are camouflaged."
		} as Dictionary,
		{
			"character": "Commander",
			"text": "This is a perfect test of your tactical skills. Position your defenses carefully."
		} as Dictionary,
		{
			"character": "Recruit",
			"text": "What about upgrading my existing towers?"
		} as Dictionary,
		{
			"character": "Advisor",
			"text": "Excellent thinking! Upgrading key towers might be more effective than building new ones at this stage."
		} as Dictionary,
		{
			"character": "System",
			"text": "Wave 3 beginning in 3... 2... 1..."
		} as Dictionary
	] as Array[Dictionary]

	waves = [wave1, wave2, wave3]

# Example method to add a conversation to a tutorial wave
func add_conversation_to_tutorial_wave(wave_index: int, conversation_data: Array) -> void:
	if wave_index >= 0 and wave_index < waves.size():
		waves[wave_index].pre_wave_conversation = conversation_data 
