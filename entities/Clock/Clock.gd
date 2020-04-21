extends Node2D

var Plant = load("res://entities/Plant/Plant.tscn")
var Interactable = load("res://entities/Interactable/Interactable.tscn")

var timer = 0
var clock_hand = null
var screen_wipe = null
var paused = false
var player = null
var wake_up_point = null
var world = null
var day = 1
var new_day_timer = 0
var plants_checked_for_day = true
var camera_rig = null
var ding_dong = null

func _ready() -> void:
	world = get_tree().get_root().get_node("Game")
	player = world.find_node("Player")
	camera_rig = world.find_node("CameraRig")
	wake_up_point = world.find_node("WakeUpPoint")
	clock_hand = find_node("ClockHand")
	screen_wipe = find_node("ScreenWipe")
	screen_wipe.modulate = Color(1, 1, 1, 0.0)
	ding_dong = find_node("DingDong")
	
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
		player.rotation_degrees.y = 85.0
		print(camera_rig.camera_rotation)
		camera_rig.camera_rotation.y = -280.0
		get_new_plant()
		
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

func get_new_plant():
	day += 1
	var new_plant = Plant.instance()
	add_child(new_plant)
	
	var interactable_container = Interactable.instance()
	interactable_container.make_interactable(new_plant)

	interactable_container.picking_up = true
	interactable_container.reparent(interactable_container, player)
	
	new_plant.init(day)
	ding_dong.play()
