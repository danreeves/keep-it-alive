extends Area

var ray_length = 1000

var picking_up = false
var is_colliding = false

var world = null
var player = null
var camera = null

func _ready() -> void:
	world = get_parent()
	player = world.find_node("Player")
	camera = world.find_node("Camera")

func _process(delta: float) -> void:
	if picking_up and is_colliding and not is_picked_up():
		if not player.is_holding_item:
			call_deferred("reparent", self, player)
		else:
			picking_up = false
	if not picking_up and is_picked_up():
		call_deferred("reparent", self, world)
		is_colliding = true

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == 2:
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * ray_length
				var collide_with_bodies = false
				var collide_with_area = true
				var collision = get_world().direct_space_state.intersect_ray(from, to, [], 0x7FFFFFFF, collide_with_bodies, collide_with_area)
				if not collision.empty():
					if collision.collider == self:
						picking_up = not is_picked_up()
						
func is_picked_up() -> bool:
	return get_parent() == player

func reparent(node, new_parent):
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	if new_parent == world:
		node.translation = player.translation + Vector3(1,2,0)
		node.translation.y = 0
		player.drop()
	else:
		node.translation = Vector3(1,2,0)
		player.pickup()

func _on_Area_body_entered(body: Node) -> void:
	if body == player:
		is_colliding = true

func _on_Area_body_exited(body: Node) -> void:
	if body == player:
		is_colliding = false
