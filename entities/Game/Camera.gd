extends Camera

var player = null

func _ready() -> void:
	player = get_parent().get_parent().find_node("Player")

func _process(delta: float) -> void:
	if player:
		look_at(player.translation, Vector3(0, 1, 0))
		
#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if event.is_pressed():
#			if event.button_index == 4:
#				# Up
#				translation.x += -2.5
#			if event.button_index == 5:
#				# Down
#				translation.x += 2.5
