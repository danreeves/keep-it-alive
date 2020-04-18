extends KinematicBody
const ray_length = 100000000

var go_to = null
var path_colliders = []

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
		print(move.length())
		move_and_slide(move * 50 * delta)
		
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			var camera = get_parent().find_node("Camera")
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			var collision = get_world().direct_space_state.intersect_ray(from, to)
			if not collision.empty():
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
