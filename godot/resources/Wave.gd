extends Resource
class_name Wave

# Array of dictionaries containing enemy counts and delays
# Format: [{"enemy_type": preload("path_to_enemy.tscn"), "count": 5, "delay": 1.0}, ...]
@export var enemies: Array[Dictionary] = []

# Delay before the next wave starts
@export var delay_after_wave: float = 5.0

# Conversation data to display before the wave starts
# Format: [{"character": "Character Name", "text": "Dialogue text"}, ...]
@export var pre_wave_conversation: Array[Dictionary] = []

# Whether this wave has been completed
var is_completed: bool = false

# Whether this wave has a conversation
func has_conversation() -> bool:
	return not pre_wave_conversation.is_empty()
