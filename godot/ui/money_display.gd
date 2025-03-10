extends Control

@onready var money_label: Label = $CurrentMoney
var economy_manager: EconomyManager = null

func _ready() -> void:
	# Add to the UI group for click detection
	add_to_group("UI")
	
	# Find the economy manager
	await get_tree().process_frame
	economy_manager = get_tree().get_first_node_in_group("EconomyManager")
	
	if economy_manager:
		# Connect to the money_changed signal
		economy_manager.money_changed.connect(_on_money_changed)
		
		# Initialize the money display
		update_display(economy_manager.get_money())
	else:
		print("Error: EconomyManager not found!")

func _on_money_changed(new_amount: int) -> void:
	update_display(new_amount)

func update_display(amount: int) -> void:
	if money_label:
		money_label.text = "$" + str(amount) 
