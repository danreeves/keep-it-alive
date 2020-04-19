extends Area

var ray_length = 1000

var picking_up = false

var world = null
var player = null
var camera = null

func is_colliding():
	return self.translation.distance_to(player.translation) < 1.5

func _ready() -> void:
	world = get_parent()
	player = world.find_node("Player")
	camera = world.find_node("Camera")
	add_to_group("Interactables")

func _process(_delta: float) -> void:
	if picking_up and is_colliding() and not is_picked_up():
		if not player.is_holding_item:
			# When picking up an item cancel player movement
			# Clean up old nav colliders
			for enemy in get_tree().get_nodes_in_group("pathing-colliders"):
				enemy.queue_free()
			player.go_to = null
			call_deferred("reparent", self, player)
		else:
			picking_up = false
	if not picking_up and is_picked_up():
		# When dropping an item cancel player movement
		# Clean up old nav colliders
		for enemy in get_tree().get_nodes_in_group("pathing-colliders"):
			enemy.queue_free()
		player.go_to = null
		call_deferred("reparent", self, player)
		call_deferred("reparent", self, world)

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
	var old_global_position = global_transform.origin
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	if new_parent == world:
		node.translation = old_global_position
		node.translation.y = 1
		node.rotation = player.rotation
		player.drop()
	else:
		node.translation = Vector3(0, 4, -1)
		node.rotation = Vector3(0, 0, 0)
		player.pickup()
