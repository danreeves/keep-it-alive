extends Node2D

var timer = 0
var clock_hand = null
var screen_wipe = null
var paused = false
var player = null
var wake_up_point = null
var world

var new_day_timer = 0
var plants_checked_for_day = true

func _ready() -> void:
	world = get_tree().get_root().get_node("Game")
	player = world.find_node("Player")
	wake_up_point = world.find_node("WakeUpPoint")
	clock_hand = find_node("ClockHand")
	screen_wipe = find_node("ScreenWipe")
	screen_wipe.modulate = Color(1, 1, 1, 0.0)
	
func _process(delta: float) -> void:
	if not paused:
		timer += delta
		
	clock_hand.rotation_degrees = int((360/60) * timer)
	
	if timer > 50:
		screen_wipe.modulate = Color(1, 1, 1, (1.0 - (60 - timer) / 10))
		
	if timer >= 60:
		timer = 0
		plants_checked_for_day = false
		paused = true
		if player.is_holding_item:
			var interactable = player.held_item.get_parent()
			interactable.reparent(interactable, world)
		player.go_to = null
		player.translation = wake_up_point.translation
		
		new_day_timer += delta
		
	if not plants_checked_for_day:
		var plants = get_tree().get_nodes_in_group("Plants")
		for plant in plants:
			if plant.current_need:
				plant.lose_life()
		plants_checked_for_day = true
				
	if new_day_timer > 0:
		new_day_timer += delta * 3
		screen_wipe.modulate = Color(1, 1, 1, (10 - new_day_timer) / 10)

	if new_day_timer >= 10:
		timer = 0
		new_day_timer = 0
		screen_wipe.modulate = Color(1, 1, 1, 0)
		paused = false
