extends Spatial

const all_needs = [
#	{
#		"difficulty": 1,
#		"name": "light",
#		"kinds": ["sun", "lamp", "candle", "flashlight"],
#	},
	{
		"difficulty": 1,
		"name": "water",
		"kinds": ["tap", "filtered", "sparkling", "champagne"],
	},
#	{
#		"difficulty": 1,
#		"name": "food",
#		"kinds": ["pizza", "tacos"],
#	},
#	{
#		"difficulty": 1,
#		"name": "fertalizer",
#		"kinds": ["fertalizer", "coffee grounds", "banana peels", "poop"],
#	},
]

var difficulty = 1
var needs = []
var interval = 45
var start_offset = 10
var timer = null
var current_need = null

func _ready() -> void:
	var PlantModel = load("res://entities/Plant/Models/Plant1.tscn")
	var model = PlantModel.instance()
	add_child(model)

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
	print("Starting timer for %d seconds" % [start_offset])
	
func get_needs_for_difficulty(diff):
	# super random
	randomize()
	all_needs.shuffle()
	
	match diff:
		1:
			var level_1_needs = []
			for need in all_needs:
				if need.difficulty == 1:
					level_1_needs.append(need)
			needs = [level_1_needs.pop_front()]
		2:
			var level_1_needs = []
			for need in all_needs:
				if need.difficulty == 1:
					level_1_needs.append(need)
			needs = [level_1_needs.pop_front(), level_1_needs.pop_front()]

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
	print("Start Interval Over")
	remove_child(start_offset_timer)
	start_offset_timer.queue_free()

	# Start need interval
	timer = Timer.new()
	timer.name = "NeedTimer"
	add_child(timer)
	timer.connect("timeout", self, "set_current_need")
	timer.start(interval)
	print("Plant need interval started, %d seconds" % [interval], self)
	
	# Create first need
	set_current_need()

func set_current_need():
	if current_need:
		print("Plant already has a need", self, current_need)
		return
	if needs.size() < 1:
		print("Plant has no needs", self)
		return
		
	# Pause the need timer
	timer.paused = true
	
	# Get a random new need
	randomize()
	needs.shuffle()
	current_need = needs.front()
	print("í ¼í½ƒPlant has a new need!", self, current_need)
	# @TODO: Add plant alert

func satisfy_need():
	print(current_need.name, ' satisfied')
	current_need = null
	timer.paused = false
	print("restarting timer. %d seconds left" % [timer.time_left])
	# @TODO: Remove plant alert
