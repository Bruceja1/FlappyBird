extends CharacterBody2D

const GRAVITY = 1200
const JUMP_VELOCITY = -320.0

signal hit
signal idle_state_broken

var viewport_size
enum State { Alive, Dead, Idle, Frozen }
var current_state : State
var rotation_speed : float = 0.08
var rotation_threshold : int = 170
var default_pos : Vector2
var default_rot : int

var distance : int = 3 # How far up and down the player moves in idle state
var delta_distance : int = 1 # Amount of pixels per movement in idle state
var time_interval : float = 0.04 # Time between each pixel movement
var completed_loop : bool = true # Prevents _physics_process() from calling this 
								 # function when previous animation loop hasn't finished
var pause_time : float = 0.1 # How long the animation pauses for on the highest and 
							 # lowest points


func _ready() -> void:
	add_to_group("Player")
	default_pos = position
	default_rot = rotation
	viewport_size = get_viewport_rect().size
	$AnimatedSprite2D.play("fly")
	print(viewport_size.x, viewport_size.y)
	current_state = State.Frozen
	hide()
	
func _physics_process(delta: float) -> void:
	if current_state != State.Frozen and current_state != State.Idle:
		player_falling(delta)
		player_jump(delta)

		rotate_sprite(rotation_speed)
	
	if current_state == State.Idle:
		player_idle(delta)
		return
		
	move_and_slide()

func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if current_state == State.Alive:
			game_over()
		
func player_jump(delta: float):
	if Input.is_action_just_pressed("jump") && current_state == State.Alive:
		$JumpSound.play()
		velocity.y = JUMP_VELOCITY
		position.y = clamp(position.y, 0, viewport_size.y)
		# Up position of the sprite
		$AnimatedSprite2D.rotation = deg_to_rad(-20)

func game_over():
	if current_state != State.Dead:
		current_state = State.Dead
		velocity.y = 0
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1
		hit.emit()
		print("Game over!")
		
func rotate_sprite(rotation_speed):
		if velocity.y > rotation_threshold:
			$AnimatedSprite2D.rotation = move_toward($AnimatedSprite2D.rotation, deg_to_rad(90), rotation_speed)

# When idle state it awaits input, after which it will go into flapping ('Alive') state
func player_idle(delta) -> void:
	if Input.is_action_just_pressed("jump"):
		current_state = State.Alive
		idle_state_broken.emit()
		player_jump(delta)
	move_idle()
		
# Idle up and down movement
func move_idle():
	if !completed_loop:
		return
	
	completed_loop = false
	
	# Move up
	while position.y > default_pos.y - distance:
		# This if check makes sure this while loop terminates immediately 
		# when the player changed states anywhere between move_idle() being called
		# and this while loop starting
		if current_state != State.Idle:
			completed_loop = true
			return
		position.y -= delta_distance
		await get_tree().create_timer(time_interval).timeout
	await get_tree().create_timer(pause_time).timeout
	
	# Move down
	while position.y < default_pos.y + distance:
		if current_state != State.Idle:
			completed_loop = true
			return
		position.y += delta_distance
		await get_tree().create_timer(time_interval).timeout	
	await get_tree().create_timer(pause_time).timeout
	
	# Move back to original position
	while position.y > default_pos.y:
		if current_state != State.Idle:
			completed_loop = true
			return
		position.y -= delta_distance
		await get_tree().create_timer(time_interval).timeout
	
	completed_loop = true
		
func reset_player() -> void:
	current_state = State.Frozen
	position = default_pos
	$AnimatedSprite2D.rotation = default_rot
	print("rotation is now ", rotation)
	$AnimatedSprite2D.play("fly")
	hide()
		
func pause() -> void:
	current_state = State.Frozen
	velocity.y = 0 # Prevents player from flying up infinitely on its own
	$AnimatedSprite2D.pause()

func unpause() -> void:
	current_state = State.Alive
	$AnimatedSprite2D.play("fly")
