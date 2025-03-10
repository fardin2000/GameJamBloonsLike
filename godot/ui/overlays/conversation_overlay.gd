extends Control

signal conversation_completed

@onready var character_name_label = $Panel/ChatBox/CharacterName
@onready var speech_text_label = $Panel/ChatBox/SpeechText

var conversation_data = []
var current_dialogue_index = 0
var is_conversation_active = false

func _ready() -> void:
	# Add to group for easier access
	add_to_group("ConversationOverlay")
	print("ConversationOverlay: Ready, added to ConversationOverlay group")
	
	# Initially hide the overlay
	self.visible = false

# Function to start a conversation with the given data
func start_conversation(data: Array) -> void:
	print("ConversationOverlay: Start conversation called with %d entries" % data.size())
	if data.is_empty():
		print("ConversationOverlay: Empty conversation data, emitting completion immediately")
		emit_conversation_completed()
		return
		
	conversation_data = data
	current_dialogue_index = 0
	is_conversation_active = true
	
	# Show the conversation UI
	self.visible = true
	
	# Display the first dialogue
	display_current_dialogue()

# Display the current dialogue based on the index
func display_current_dialogue() -> void:
	if current_dialogue_index >= conversation_data.size():
		end_conversation()
		return
		
	var dialogue = conversation_data[current_dialogue_index]
	character_name_label.text = dialogue.get("character", "???")
	speech_text_label.text = dialogue.get("text", "")
	print("ConversationOverlay: Displayed dialogue for character: ", character_name_label.text)

# Advance to the next dialogue
func next_dialogue() -> void:
	current_dialogue_index += 1
	print("ConversationOverlay: Moving to next dialogue, index=", current_dialogue_index)
	if current_dialogue_index >= conversation_data.size():
		end_conversation()
	else:
		display_current_dialogue()

# End the conversation
func end_conversation() -> void:
	is_conversation_active = false
	self.visible = false
	print("ConversationOverlay: Conversation completed, about to emit signal")
	emit_conversation_completed()

# Helper function to emit the signal with additional debugging
func emit_conversation_completed() -> void:
	print("ConversationOverlay: EMITTING conversation_completed signal")
	# Print signal connections again to verify
	var conns = get_signal_connection_list("conversation_completed")
	print("ConversationOverlay: conversation_completed connections count: ", conns.size())
	for conn in conns:
		print("  - Connected to: ", conn["target"], " method: ", conn["method"])
	
	# Actually emit the signal
	conversation_completed.emit()
	
	# Force a direct call to RoundManager if possible (as a fallback)
	var round_manager = get_tree().get_first_node_in_group("RoundManager")
	if round_manager and round_manager.has_method("_on_conversation_completed"):
		print("ConversationOverlay: Directly calling RoundManager._on_conversation_completed as fallback")
		round_manager._on_conversation_completed()

# Input handling to advance dialogue
func _input(event: InputEvent) -> void:
	if not is_conversation_active:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		next_dialogue()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		next_dialogue()
