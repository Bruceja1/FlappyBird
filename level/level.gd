extends Node2D

@export var pipe_scene : PackedScene
@export var ground_scene : PackedScene

var low_pipe_pos : int = 560
var high_pipe_pos : int = 256
var pipe_x_pos : int = 390
var ground_speed : int = 2
var moving_marker_default_pos : Vector2
# When ground moves past this x, new ground will spawn to create infinite ground scrolling effect
var ground_x_threshold : int = -410
var screen_size : Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$HUD.screen_size = screen_size
	$TimerPipe.start()
	moving_marker_default_pos = $MovingGroundMarker.position
	

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move_ground()
	pipe_passthrough()

func _on_player_hit() -> void:
	print("Player was hit!")
	$TimerPipe.stop()
	ground_speed = 0
	# Get each current pipe instance and set all of their speeds to 0
	for item in self.get_children():
		# CAUTION: if the Area2D is not a pipe, this will probably crash the game!
		if item.get_class() == "Area2D":
			item.pipe_speed = 0
	display_flash()
	$HUD.game_over()
 	
func _on_pipe_timer_timeout() -> void:
	var pipe = pipe_scene.instantiate()
	
	pipe.position.x = pipe_x_pos
	
	# Pipes spawn at random heights
	pipe.position.y = randi_range(low_pipe_pos, high_pipe_pos)
	
	add_child(pipe)
	
func move_ground() -> void:
	$Ground.position.x -= ground_speed
	$MovingGroundMarker.position.x -= ground_speed
	
	# Simulate infinitely moving ground by resetting its position when it moves past a certain marker
	if $MovingGroundMarker.position.x < $GroundMarker2.position.x:
		$Ground.position = $GroundMarker1.position
		$MovingGroundMarker.position = moving_marker_default_pos
		
# Check when the player passes through a pipe and then update score
func pipe_passthrough() -> void:
	# look for all active nodes in the scene tree
	for item in self.get_children():
		# if item is pipe, check if pos.x is equal to playerpos.x
		if item.is_in_group("Pipe"):
			if item.position.x == $Player.position.x:
				$HUD.update_score()
			
func display_flash() -> void: 
	var flash = ColorRect.new()
	flash.size = screen_size
	flash.color = Color.WHITE
	flash.z_index = 5
	# Set the opacity to high value. a8 goes from 0-255
	flash.modulate.a8 = 150
	add_child(flash)
	# Gradually decrease the opacity to create flash effect
	while flash.modulate.a8 != 0:
		await get_tree().create_timer(0.001).timeout
		flash.modulate.a8 -= 5
	remove_child(flash)
