extends Area

export (bool) var debug = false

var ray_length = 1000

var picking_up = false

var world = null
var player = null
var camera = null
var item = null
var is_using = false

func is_colliding():
	var location_on_floor = self.translation
	location_on_floor.y = 0
	return location_on_floor.distance_to(player.translation) < 3

func _ready() -> void:
	world = get_tree().get_root().get_node("Game")
	player = world.find_node("Player")
	camera = world.find_node("Camera")
	add_to_group("Interactables")

func _physics_process(_delta: float) -> void:
	if is_using and is_colliding() and player.is_holding_item and not is_picked_up():
		if player.held_item.has_method("use"):
			player.held_item.use(item)
			is_using = false
			return
	
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
		return
			
	if not picking_up and is_picked_up():
		# When dropping an item cancel player movement
		# Clean up old nav colliders
		for enemy in get_tree().get_nodes_in_group("pathing-colliders"):
			enemy.queue_free()
		player.go_to = null
		call_deferred("reparent", self, world)
		return

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
					if player.is_holding_item:
						if collision.collider == self:
							if self.is_picked_up():
								picking_up = not is_picked_up()
							else:
								if player.held_item.has_method("use"):
									is_using = true
					else:
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
		node.translation.y = 0
		node.rotation = player.rotation
		player.drop()
		is_using = false
		picking_up = false
	
	if new_parent == player:
		node.translation = Vector3(0, 4, -1.5)
		node.rotation = Vector3(0, 0, 0)
		player.pickup(item)

func make_interactable(node):
	var interactable = self
	var current_position = node.global_transform.origin
	var current_rotation = node.rotation
	
	interactable.add_to_group("Usables")
	var parent = node.get_parent()
	parent.remove_child(node)
	interactable.add_child(node)
	parent.add_child(interactable)
	interactable.translation = current_position
	interactable.rotation = current_rotation
	node.translation = Vector3(0, 0, 0)
	node.rotation = Vector3(0, 0,0 )
	
	item = node

func _on_Interactable_body_entered(body: Node) -> void:
	# Set the ys to 0 so the check doesnt care about things being off the ground
	var player_go_to = player.go_to
	if player_go_to:
		player_go_to.y = 0
	var current_location = translation
	current_location.y = 0
	if body == player and ((is_using or picking_up) or player_go_to == current_location):
		# When dropping an item cancel player movement
		# Clean up old nav colliders
		for enemy in get_tree().get_nodes_in_group("pathing-colliders"):
			enemy.queue_free()
		player.go_to = null

func _on_Interactable_mouse_entered() -> void:
	find_node("Hover").visible = true


func _on_Interactable_mouse_exited() -> void:
	find_node("Hover").visible = false
