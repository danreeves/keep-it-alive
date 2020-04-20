extends KinematicBody
const ray_length = 100000000

var go_to = null
var path_colliders = []
var is_holding_item = false
var held_item = null

func _ready() -> void:
	pass

func _path_collision(node: Node, area: Area) -> void:
	if node == self:
		if area.is_in_group("pathing-colliders"):
			go_to = null
			area.queue_free()
	
func _process(delta: float) -> void:
	if go_to:
		var move = (go_to - get_translation())
		
		# Goofy way of maintaining a minimum speed
		while(move.length() < 5.5):
			move = move * 1.1
			
		# Goofy way of maintaining a maximum speed
		while(move.length() > 15):
			move = move * 0.9
			
		var _linear_velocity = move_and_slide(move * 50 * delta)
		look_at(go_to, Vector3(0,1,0))
		rotation.x = 0
		rotation.z = 0
		
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var camera = get_parent().find_node("Camera")
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			var collide_with_bodies = true
			var collide_with_area = true
			var collision = get_world().direct_space_state.intersect_ray(from, to, [], 0x7FFFFFFF, collide_with_bodies, collide_with_area)
			if not collision.empty():
#				var holding_usable = is_holding_item and held_item
#				var is_usable = collision.collider.is_in_group("Usables")
				var is_interactable = collision.collider.is_in_group("Interactables")
				if is_interactable:
					var is_picked_up = collision.collider.is_picked_up()
					var is_colliding = collision.collider.is_colliding()
					if is_picked_up or is_colliding:
						return
					else:
						go_to = collision.collider.translation
						go_to.y = 0
						return
					
				go_to = collision.position
				go_to.y = 0
				
				# Clean up old areas
				for enemy in get_tree().get_nodes_in_group("pathing-colliders"):
					enemy.queue_free()
				
				var area = Area.new()
				var collisionshape = CollisionShape.new()
				var boxshape = BoxShape.new()
				boxshape.set_extents(Vector3(0.1, 1, 0.1))
				collisionshape.shape = boxshape
				area.add_child(collisionshape)
				area.set_translation(Vector3(go_to.x, 2.5, go_to.z))
				area.set_monitoring(true)
				area.add_to_group("pathing-colliders")
				get_parent().add_child(area)
				area.connect("body_entered", self, "_path_collision", [area])

func pickup(item):
	print("pickup: ", item)
	is_holding_item = true
	held_item = item
	find_node("Rain").visible = false
	find_node("Rain_Holding").visible = true
	
func drop():
	print_debug("wot")
	is_holding_item = false
	held_item = null
	find_node("Rain").visible = true
	find_node("Rain_Holding").visible = false
