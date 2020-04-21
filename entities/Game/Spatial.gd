extends Spatial

var player = null
var mouse_down = false
var camera_rotation = Vector2(0, 0)

func _ready() -> void:
	player = get_parent().find_node("Player")

func _process(delta: float) -> void:
	translation = player.translation
	rotation.y = camera_rotation.y
#	rotation.x = camera_rotation.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 3:
			if event.is_pressed():
				mouse_down = true
			else:
				mouse_down = false
	
	if event is InputEventMouseMotion:
		if mouse_down:
#			camera_rotation.x += (event.relative.y * -1 / 100)
			camera_rotation.y += (event.relative.x * 1 / 100)
			
#	if event is InputEventMouseButton:
#		if event.is_pressed():
#			if event.button_index == 4:
#				# Up
#				camera_rotation.x += -0.1
#			if event.button_index == 5:
#				# Down
#				camera_rotation.x += 0.1
