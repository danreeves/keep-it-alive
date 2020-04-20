extends Spatial

var Interactable = load("res://entities/Interactable/Interactable.tscn")

func _ready() -> void:
	call_deferred("make_interactable")
	
func make_interactable():
	var interactable = Interactable.instance()
	interactable.make_interactable(self)
