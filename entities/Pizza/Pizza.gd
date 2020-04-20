extends Spatial

var Interactable = load("res://entities/Interactable/Interactable.tscn")

func _ready() -> void:
	call_deferred("make_interactable")
	
func make_interactable():
	var interactable = Interactable.instance()
	interactable.make_interactable(self)
#	interactable.debug = true

func use(plant):
	print("calling use")
	var current_need = plant.current_need
	if current_need and current_need.name == "food" and plant.difficulty == 1:
		plant.satisfy_need()
		print("Satisfying need")
	else:
		print("The plant doesn't want pizza!! dumb plant")
