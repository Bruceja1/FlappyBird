extends CanvasLayer

signal start_button_pressed

# How far up and down the gametitle moves
var distance : int = 20
var default_pos : Vector2
var delta_distance : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_pos = $GameTitle.position
	$GameTitle/Flappy.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	#move_title()
	pass
	
func move_title() -> void:
	print("Default pos is ", default_pos)
	if $GameTitle.position.y > default_pos.y - distance:
		$GameTitle.position.y -= delta_distance
	else:
		while $GameTitle.position.y < default_pos.y + distance:
			$GameTitle.position.y += delta_distance
		
	print("Current pos is ", $GameTitle.position.y)

func _on_start_button_pressed() -> void:
	start_button_pressed.emit()
	
func _on_game_reset() -> void:
	show()
