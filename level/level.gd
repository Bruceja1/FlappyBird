extends Node2D

@export var pipe_scene : PackedScene
@export var fadeout_scene : PackedScene
@export var flash_scene : PackedScene

signal reset_game
signal start_game
signal game_over

const DEFAULT_GROUND_SPEED : int = 2

var save_path = "user://flappybird.save"

var score : int = 0
var goldscore : int = 0
var silverscore: int = 0
var bronzescore: int = 0

var low_pipe_pos : int = 560
var high_pipe_pos : int = 256
var pipe_x_pos : int = 390
var ground_speed : int = DEFAULT_GROUND_SPEED
var moving_marker_default_pos : Vector2
# When ground moves past this x, ground position will reset to create infinite ground scrolling effect
var ground_x_threshold : int = -410
var screen_size : Vector2


# To calculate how long the transitions (fade out and flash) last,
# use this formula: length = a8 / delta_increment * time_interval
# Make sure time_interval is not too small or else the transitions won't work on phones
var transition_time_interval : float = 0.01
var transition_delta_increment : float = 0.05
var transition_a : float = 1.0

func _ready() -> void:
	load_data()
	screen_size = get_viewport_rect().size
	$GameOverHUD.screen_size = screen_size
	moving_marker_default_pos = $MovingGroundMarker.position
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move_ground()
	pipe_passthrough()
	
func _on_start_game() -> void:
	$MenuSound.play()
	# Small timer so button animation can play
	await get_tree().create_timer(0.05).timeout
	fade_out()
	$TitleScreenHUD.hide()
	# Small timer so that the player and HUD don't appear during the fade out
	await get_tree().create_timer(0.5).timeout
	$MainGameHUD.show_elements()
	$Player.show()
	await $StartGameHUD.fade_in_icons()
	$Player.current_state = $Player.State.Idle
	
# Triggers when 'OK' button is pressed on game over screen
func _on_reset_game() -> void:
	$MenuSound.play()
	# pipes disappear
	for item in self.get_children():
		if item.is_in_group("Pipe"):
			item.queue_free()		
	fade_out()
	$GameOverHUD.hide_elements()
	score = 0
	$MainGameHUD.update_score(score)
	# Ground moves again
	ground_speed = DEFAULT_GROUND_SPEED
	# Hide player and reset position
	$Player.reset_player()
	# Trigger title screen HUD after small delay so it doesn't appear during fade out
	await get_tree().create_timer(0.5).timeout
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
		if item.is_in_group("Pipe"):
			item.pipe_speed = 0
	display_flash()
	$MainGameHUD.game_over()
	update_highscores()
	$GameOverHUD.game_over_screen(score, goldscore, silverscore, bronzescore)
 	
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
	for item in self.get_children():
		if item.is_in_group("Pipe"):
			# Check if player is dead to prevent score increasing infinitely while player is dead
			if item.position.x == $Player.position.x and $Player.current_state != $Player.State.Dead:
				score += 1
				$CoinSound.play()
				$MainGameHUD.update_score(score)
			
func display_flash() -> void: 
	var flash = flash_scene.instantiate()
	flash.size = screen_size
	flash.z_index = 5
	# Set the opacity to high value. a8 goes from 0-255
	flash.modulate.a = transition_a
	add_child(flash)
	# Gradually decrease the opacity to create flash effect
	while flash.modulate.a != 0:
		await get_tree().create_timer(transition_time_interval).timeout
		flash.modulate.a -= transition_delta_increment
	flash.queue_free()

func fade_out() -> void:
	var fade_out = fadeout_scene.instantiate()
	fade_out.size = screen_size
	fade_out.z_index = 5
	fade_out.modulate.a = 0
	add_child(fade_out)
	while fade_out.modulate.a < transition_a:
		await get_tree().create_timer(transition_time_interval).timeout
		fade_out.modulate.a += transition_delta_increment
	# Here the screen is completely black
	await get_tree().create_timer(0.1).timeout	
	while fade_out.modulate.a > 0:
		await get_tree().create_timer(transition_time_interval).timeout
		fade_out.modulate.a -= transition_delta_increment
	fade_out.queue_free()

func pause_game() -> void:
	$MainGameHUD/PauseButton.hide()
	$MainGameHUD/UnPauseButton.show()
	$Player.pause()
	for item in self.get_children():
		if item.is_in_group("Pipe"):
			item.pipe_speed = 0
	$TimerPipe.paused = true
	ground_speed = 0
	
func unpause_game() -> void:
	$MainGameHUD/PauseButton.show()
	$MainGameHUD/UnPauseButton.hide()
	$Player.unpause()
	for item in self.get_children():
		if item.is_in_group("Pipe"):
			item.pipe_speed = item.DEFAULT_SPEED
	$TimerPipe.paused = false
	ground_speed = DEFAULT_GROUND_SPEED

func update_highscores() -> void:
	if score > goldscore:
		goldscore = score
	elif score > silverscore:
		silverscore = score
	elif score > bronzescore:
		bronzescore = score
	save()

func save() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(goldscore)
	file.store_var(silverscore)
	file.store_var(bronzescore)
	
func load_data() -> void:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		goldscore = file.get_var(goldscore)
		silverscore = file.get_var(silverscore)
		bronzescore = file.get_var(bronzescore)
	else:
		print("Could not load save data!")
