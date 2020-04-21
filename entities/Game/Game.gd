extends Spatial

var Plant = load("res://entities/Plant/Plant.tscn")
var Interactable = load("res://entities/Interactable/Interactable.tscn")

func _ready() -> void:
	call_deferred("init")

func init() -> void:
	var first_plant = Plant.instance()
	add_child(first_plant)
	
	var interactable_container = Interactable.instance()
	interactable_container.make_interactable(first_plant)
	
	var player = find_node("Player")
	interactable_container.picking_up = true
	interactable_container.reparent(interactable_container, player)
	
	first_plant.init(1)
	
