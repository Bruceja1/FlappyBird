extends CharacterBody2D

const GRAVITY = 1200
const JUMP_VELOCITY = -320.0

signal hit

var viewport_size
enum State { Alive, Dead }
var current_state : State
var rotation_speed : float = 0.08
var rotation_threshold : int = 170

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	$AnimatedSprite2D.play("fly")
	print(viewport_size.x, viewport_size.y)
	current_state = State.Alive

func _physics_process(delta: float) -> void:
	player_falling(delta)
	player_jump(delta)
	
	rotate_sprite(rotation_speed)
	
	move_and_slide()

func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if current_state != State.Dead:
			game_over()
		
func player_jump(delta: float):
	if Input.is_action_just_pressed("jump") && current_state != State.Dead:
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

func display_flash():
	pass
