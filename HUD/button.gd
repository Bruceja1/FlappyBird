extends TextureButton

var pressed_distance : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Move button down when pressed
func _on_pressed() -> void:
	var default_pos = position
	position.y += pressed_distance
	await get_tree().create_timer(0.1).timeout
	position = default_pos
