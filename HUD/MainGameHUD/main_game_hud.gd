extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(score : int) -> void:
	$ScoreLabel.text = str(score)

func game_over() -> void:
	# Time between getting hit and the score at the top disappearing
	await get_tree().create_timer(1).timeout
	hide()
