extends Spatial

var Interactable = load("res://entities/Interactable/Interactable.tscn")

func _ready() -> void:
	call_deferred("make_interactable")
	
func make_interactable():
	var interactable = Interactable.instance()
	interactable.make_interactable(self)

func use(item):
	if item.is_in_group("Plants"):
		var current_need = item.current_need
		if current_need and current_need.name == "water" and current_need.kinds.has("champagne"):
			item.satisfy_need()
			return
		print("The plant doesn't want champagne water!")
	else:
		print("you can't use this on that")
