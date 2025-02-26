extends Node2D

@export var pipe_scene : PackedScene
@export var ground_scene : PackedScene

signal reset_game
signal start_game
signal game_over

const default_ground_speed : int = 2

var low_pipe_pos : int = 560
var high_pipe_pos : int = 256
var pipe_x_pos : int = 390
var ground_speed : int = default_ground_speed
var moving_marker_default_pos : Vector2
# When ground moves past this x, new ground will spawn to create infinite ground scrolling effect
var ground_x_threshold : int = -410
var screen_size : Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$GameOverHUD.screen_size = screen_size
	moving_marker_default_pos = $MovingGroundMarker.position
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move_ground()
	pipe_passthrough()
	
func _on_start_game() -> void:
	$TitleScreenHUD.hide()
	await fade_out()
	$MainGameHUD.show()
	$Player.show()
	$Player.current_state = $Player.State.Idle
	$StartGameHUD.fade_in_icons()
	
# Triggers when 'OK' button is pressed on game over screen
func _on_reset_game() -> void:
	# pipes disappear
	for item in self.get_children():
		# CAUTION: if the Area2D is not a pipe, this will probably crash the game!
		if item.get_class() == "Area2D":
			remove_child(item)
	$GameOverHUD/GameOver.hide()
	$GameOverHUD/ScoreSheet.hide()
	$GameOverHUD/Buttons.hide()
	await fade_out()
	$MainGameHUD.reset_score()
	# Ground moves again
	ground_speed = default_ground_speed
	# Hide Game over HUD
	# Hide player and reset position
	print("Player position was ", $Player.position)
	$Player.reset_player()
	print("Player position is now ", $Player.position)
	
	
	# Trigger title screen HUD
	reset_game.emit()
	
func _on_idle_state_broken() -> void:
	$StartGameHUD.fade_out_icons()
	$TimerPipe.start()
	
func _on_player_hit() -> void:
	print("Player was hit!")
	$GameOver.play()
	$TimerPipe.stop()
	ground_speed = 0
	# Get each current pipe instance and set all of their speeds to 0
	for item in self.get_children():
		# CAUTION: if the Area2D is not a pipe, this will probably crash the game!
		if item.get_class() == "Area2D":
			item.pipe_speed = 0
	display_flash()
	$MainGameHUD.game_over()
	game_over.emit()
 	
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
				$CoinSound.play()
				$MainGameHUD.update_score()
			
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

func fade_out() -> void:
	var fade_out = ColorRect.new()
	fade_out.size = screen_size
	fade_out.color = Color.BLACK
	fade_out.z_index = 5
	fade_out.modulate.a8 = 0
	add_child(fade_out)
	while fade_out.modulate.a8 < 255:
		await get_tree().create_timer(0.001).timeout
		fade_out.modulate.a8 += 5
	while fade_out.modulate.a8 > 0:
		await get_tree().create_timer(0.001).timeout
		fade_out.modulate.a8 -= 5
	remove_child(fade_out)

func _on_score_updated() -> void:
	$GameOverHUD.score += 1
