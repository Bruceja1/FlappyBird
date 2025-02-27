extends CanvasLayer

signal start_button_pressed

var distance : int = 5 # How far up and down the game title moves
var default_pos : Vector2
var delta_distance : int = 1
var time_interval : float = 0.04 # Time between each pixel movement
var completed_loop : bool = true # Prevents _physics_process() from calling this function over and over even when
								 # when the animation loop hasn't finished	
var pause_time : float = 0.2 # How long the text pauses on the highest and lowest points

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_pos = $GameTitle.position
	$GameTitle/Flappy.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move_title()
	
	
func move_title() -> void:
	if !completed_loop:
		return
	
	completed_loop = false
	
	# Move up
	while $GameTitle.position.y > default_pos.y - distance:
		$GameTitle.position.y -= delta_distance
		await get_tree().create_timer(time_interval).timeout
	await get_tree().create_timer(pause_time).timeout
	
	# Move down
	while $GameTitle.position.y < default_pos.y + distance:
		$GameTitle.position.y += delta_distance
		await get_tree().create_timer(time_interval).timeout	
	await get_tree().create_timer(pause_time).timeout
	
	# Move back to original position
	while $GameTitle.position.y > default_pos.y:
		$GameTitle.position.y -= delta_distance
		await get_tree().create_timer(time_interval).timeout
	
	completed_loop = true
	
func _on_start_button_pressed() -> void:
	start_button_pressed.emit()
	
func _on_game_reset() -> void:
	show()
