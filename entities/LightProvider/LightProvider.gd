extends Area

var timer = null

func _ready() -> void:
	timer = Timer.new()
	timer.connect("timeout", self, "check_for_plants")
	add_child(timer)
	timer.start(1)

func check_for_plants():
	print("checking for plants...")
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "LightConsumer":
			var plant = body.get_parent()
			if plant.is_in_group("Plants"):
				if plant.current_need:
					if plant.current_need.name == "light":
						plant.satisfy_need()
						return
			print("Plant didn't want light")
