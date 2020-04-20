extends Spatial

export (bool) var debug = false

const num_plants = 12
const num_pots = 8

const all_needs = [
	{
		"difficulty": 1,
		"name": "light",
		"kinds": ["sun", "lamp", "candle"],
	},
	{
		"difficulty": 1,
		"name": "water",
		"kinds": ["tap", "filtered", "sparkling", "champagne"],
	},
	{
		"difficulty": 1,
		"name": "food",
		"kinds": ["pizza", "ramen"],
	},
]

var difficulty = 1
var needs = []
var interval = 45
var start_offset = 10
var timer = null
var current_need = null
var need_sprite = null
var lives = 3
var plant_model = null

func _ready() -> void:
	add_to_group("Plants")
	randomize()
	var plant_num = int(rand_range(1, num_plants))
	randomize()
	var pot_num = int(rand_range(1, num_pots))
	var PlantModel = load("res://entities/Plant/Models/Plants/Plant_%d.tscn" % [plant_num])
	var PotModel = load("res://entities/Plant/Models/Pots/Pot_%d.tscn" % [pot_num])
	plant_model = PlantModel.instance()
	var pot = PotModel.instance()
	need_sprite = Sprite3D.new()
	need_sprite.offset = Vector2(100, 100)
	need_sprite.billboard = SpatialMaterial.BILLBOARD_ENABLED
	add_child(plant_model)
	add_child(pot)
	add_child(need_sprite)

func _process(_delta: float) -> void:
	if debug:
		if timer:
			print(timer.time_left)
	pass
	
func init(diff: int) -> void:
	difficulty = diff
	get_needs_for_difficulty(difficulty)
	get_interval_for_difficulty(difficulty)

	randomize()
	start_offset = rand_range(5, 25)
	
	var start_offset_timer = Timer.new()
	add_child(start_offset_timer)
	start_offset_timer.connect("timeout", self, "start_interval", [start_offset_timer])
	start_offset_timer.start(start_offset)
	
func get_needs_for_difficulty(diff):
	# super random
	randomize()
	all_needs.shuffle()
	
	match diff:
		1:
			var curr_needs = all_needs.duplicate(true)
			needs = [curr_needs.pop_front()]
		2:
			var curr_needs = all_needs.duplicate(true)
			needs = [curr_needs.pop_front(), curr_needs.pop_front()]
		3:
			var curr_needs = all_needs.duplicate(true)
			needs = [curr_needs.pop_front(), curr_needs.pop_front()]
			for need in needs:
				randomize()
				need.kinds.shuffle()
				need.kinds = [need.kinds.pop_front()]
	print(needs)

func get_interval_for_difficulty(diff):
	match diff:
		1:
			interval = 45
		2:
			interval = 40
		3:
			interval = 35
		4:
			interval = 30
		5:
			interval = 25
		_:
			interval = 20

func start_interval(start_offset_timer):
	remove_child(start_offset_timer)
	start_offset_timer.queue_free()

	# Start need interval
	timer = Timer.new()
	timer.name = "NeedTimer"
	add_child(timer)
	timer.connect("timeout", self, "set_current_need")
	timer.start(interval)
	
	# Create first need
	set_current_need()

func set_current_need():
	if current_need:
		return
	if needs.size() < 1:
		return
		
	# Pause the need timer
	timer.paused = true
	
	# Get a random new need
	randomize()
	needs.shuffle()
	current_need = needs.front()
	need_sprite.visible = true
	need_sprite.texture = load("res://img/e%sicons.png" % [current_need.name])

func satisfy_need():
	current_need = null
	timer.paused = false
	need_sprite.visible = true
	need_sprite.texture = load("res://img/ehearticons.png")
	var alert_timer = Timer.new()
	add_child(alert_timer)
	alert_timer.connect("timeout", self, "alert_need_satisfied", [alert_timer])
	alert_timer.start(2)

func alert_need_satisfied(alert_timer):
	need_sprite.visible = false
	alert_timer.queue_free()

func lose_life():
	lives -= 1
	if lives == 0:
		current_need = null
		remove_child(timer)
		remove_child(plant_model)
		timer.queue_free()
		plant_model.queue_free()
